import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model } from 'mongoose';
import { Enrollment, EnrollmentDocument } from '../schemas/enrollment.schema.js';
import { UserCourseProgress, UserCourseProgressDocument } from '../schemas/progress.schema.js';
import { Course, CourseDocument } from '../../courses/schemas/course.schema.js';
import { CreateEnrollmentDto, UpdateProgressDto } from '../dto/enrollment.dto.js';
import { RedisService } from '../../../common/redis/redis.service.js';

@Injectable()
export class EnrollmentsService {
  constructor(
    @InjectModel(Enrollment.name) private enrollmentModel: Model<EnrollmentDocument>,
    @InjectModel(UserCourseProgress.name)
    private progressModel: Model<UserCourseProgressDocument>,
    @InjectModel(Course.name) private courseModel: Model<CourseDocument>,
    private readonly redisService: RedisService,
  ) {}

  async enroll(userId: string, dto: CreateEnrollmentDto): Promise<EnrollmentDocument> {
    const userObjId = new mongoose.Types.ObjectId(userId);
    const courseObjId = new mongoose.Types.ObjectId(dto.courseId);

    const course = await this.courseModel.findById(courseObjId);
    if (!course) {
      throw new NotFoundException('Course not found');
    }

    const existing = await this.enrollmentModel.findOne({
      userId: userObjId,
      courseId: courseObjId,
      status: 'active',
    });

    if (existing) {
      return existing;
    }

    // Create Enrollment record
    const enrollment = new this.enrollmentModel({
      userId: userObjId,
      courseId: courseObjId,
      enrollmentType: dto.enrollmentType || (course.price === 0 ? 'free' : 'paid'),
      status: 'active',
      pricePaid: dto.pricePaid || {
        amount: course.price,
        currency: course.currency,
        paymentMethod: course.price === 0 ? 'free_promo' : 'manual',
      },
      enrolledAt: new Date(),
    });

    const saved = await enrollment.save();

    // Initialize User Progress record if not exists
    await this.progressModel.findOneAndUpdate(
      { userId: userObjId, courseId: courseObjId },
      {
        $setOnInsert: {
          userId: userObjId,
          courseId: courseObjId,
          completedLessonIds: [],
          lastPlaybackPositions: [],
          percentComplete: 0,
          isCompleted: false,
        },
      },
      { upsert: true, new: true },
    );

    // Increment enrollment count on course
    await this.courseModel.findByIdAndUpdate(courseObjId, {
      $inc: { enrollmentCounts: 1 },
    });

    // Invalidate caches
    await this.redisService.del(`user:${userId}:enrolled_courses`);
    await this.redisService.delByPattern('catalog:courses:*');

    return saved;
  }

  async isEnrolled(userId: string, courseId: string): Promise<{ isEnrolled: boolean; isRegistered: boolean; enrollmentId?: string }> {
    const userObjId = new mongoose.Types.ObjectId(userId);
    const courseObjId = new mongoose.Types.ObjectId(courseId);

    const enrollment = await this.enrollmentModel.findOne({
      userId: userObjId,
      courseId: courseObjId,
      status: 'active',
    });

    const registered = !!enrollment;
    return {
      isEnrolled: registered,
      isRegistered: registered,
      enrollmentId: enrollment ? enrollment._id.toString() : undefined,
    };
  }

  async getUserEnrolledCourses(userId: string): Promise<any[]> {
    const userObjId = new mongoose.Types.ObjectId(userId);

    const enrollments = await this.enrollmentModel
      .find({ userId: userObjId, status: 'active' })
      .populate({
        path: 'courseId',
        populate: {
          path: 'instructorId',
          select: 'fullName avatarUrl headline',
        },
      })
      .sort({ enrolledAt: -1 })
      .lean()
      .exec();

    // Attach student progress to each enrolled course
    const results = await Promise.all(
      enrollments.map(async (enr) => {
        const course = enr.courseId as any;
        if (!course) return null;

        const progress = await this.progressModel
          .findOne({ userId: userObjId, courseId: course._id })
          .lean()
          .exec();

        return {
          enrollmentId: enr._id,
          enrolledAt: enr.enrolledAt,
          enrollmentType: enr.enrollmentType,
          course,
          progress: progress || {
            percentComplete: 0,
            completedLessonIds: [],
            isCompleted: false,
            lastAccessedLessonId: null,
          },
        };
      }),
    );

    return results.filter(Boolean);
  }

  async getProgress(userId: string, courseId: string): Promise<UserCourseProgressDocument> {
    const userObjId = new mongoose.Types.ObjectId(userId);
    const courseObjId = new mongoose.Types.ObjectId(courseId);

    let progress = await this.progressModel.findOne({ userId: userObjId, courseId: courseObjId });
    if (!progress) {
      progress = await this.progressModel.create({
        userId: userObjId,
        courseId: courseObjId,
        completedLessonIds: [],
        lastPlaybackPositions: [],
        percentComplete: 0,
        isCompleted: false,
      });
    }

    return progress;
  }

  async updateProgress(
    userId: string,
    courseId: string,
    dto: UpdateProgressDto,
  ): Promise<UserCourseProgressDocument> {
    const userObjId = new mongoose.Types.ObjectId(userId);
    const courseObjId = new mongoose.Types.ObjectId(courseId);
    const lessonObjId = new mongoose.Types.ObjectId(dto.lessonId);

    const [course, progress] = await Promise.all([
      this.courseModel.findById(courseObjId),
      this.getProgress(userId, courseId),
    ]);

    if (!course) throw new NotFoundException('Course not found');

    progress.lastAccessedLessonId = lessonObjId;

    // 1. Update playback position
    if (dto.positionSeconds !== undefined) {
      const existingPosIndex = progress.lastPlaybackPositions.findIndex(
        (p) => p.lessonId.toString() === dto.lessonId,
      );

      if (existingPosIndex >= 0) {
        progress.lastPlaybackPositions[existingPosIndex].positionSeconds = dto.positionSeconds;
        progress.lastPlaybackPositions[existingPosIndex].updatedAt = new Date();
      } else {
        progress.lastPlaybackPositions.push({
          lessonId: lessonObjId,
          positionSeconds: dto.positionSeconds,
          updatedAt: new Date(),
        });
      }
    }

    // 2. Mark lesson completed if requested
    if (dto.markCompleted) {
      const alreadyCompleted = progress.completedLessonIds.some(
        (id) => id.toString() === dto.lessonId,
      );
      if (!alreadyCompleted) {
        progress.completedLessonIds.push(lessonObjId);
      }
    }

    // 3. Recalculate percentComplete
    const totalLessons = course.totalLessons || 1;
    const completedCount = progress.completedLessonIds.length;
    const percent = Math.min(100, Math.round((completedCount / totalLessons) * 100));

    progress.percentComplete = percent;
    if (percent >= 100 && !progress.isCompleted) {
      progress.isCompleted = true;
      progress.completedAt = new Date();
    }

    return progress.save();
  }
}

