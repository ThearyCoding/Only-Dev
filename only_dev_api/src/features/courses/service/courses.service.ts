import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model } from 'mongoose';
import { Course, CourseDocument } from '../schemas/course.schema.js';
import { Section, SectionDocument } from '../schemas/section.schema.js';
import { CreateCourseDto, UpdateCourseDto, CreateSectionDto, CreateLessonDto } from '../dto/course.dto.js';
import { Enrollment, EnrollmentDocument } from '../../enrollments/schemas/enrollment.schema.js';
import { RedisService } from '../../../common/redis/redis.service.js';

@Injectable()
export class CoursesService {
  constructor(
    @InjectModel(Course.name) private courseModel: Model<CourseDocument>,
    @InjectModel(Section.name) private sectionModel: Model<SectionDocument>,
    @InjectModel(Enrollment.name) private enrollmentModel: Model<EnrollmentDocument>,
    private readonly redisService: RedisService,
  ) {}

  private slugify(text: string): string {
    return text
      .toLowerCase()
      .trim()
      .replace(/[^\w\s-]/g, '')
      .replace(/[\s_-]+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  async findAll(query: {
    page?: number;
    limit?: number;
    category?: string;
    level?: string;
    search?: string;
    status?: string;
  }): Promise<{ courses: any[]; total: number; page: number; totalPages: number }> {
    const page = Math.max(1, Number(query.page || 1));
    const limit = Math.max(1, Math.min(100, Number(query.limit || 20)));

    const filter: any = {
      status: query.status || 'published',
    };

    if (query.category) {
      filter.category = query.category;
    }
    if (query.level) {
      filter.level = query.level;
    }
    if (query.search) {
      const regex = new RegExp(query.search, 'i');
      filter.$or = [{ title: regex }, { description: regex }, { tags: regex }];
    }

    const cacheKey = `catalog:courses:${JSON.stringify(filter)}:p${page}:l${limit}`;
    const cached = await this.redisService.get<any>(cacheKey);
    if (cached) return cached;

    const [courses, total] = await Promise.all([
      this.courseModel
        .find(filter)
        .populate('instructorId', 'fullName avatarUrl headline bio')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean()
        .exec(),
      this.courseModel.countDocuments(filter),
    ]);

    const result = {
      courses,
      total,
      page,
      totalPages: Math.ceil(total / limit),
    };

    await this.redisService.set(cacheKey, result, 300); // 5 minutes cache
    return result;
  }

  async findById(courseId: string, includeCurriculum = true, userId?: string): Promise<any> {
    if (!mongoose.isValidObjectId(courseId)) {
      throw new NotFoundException('Course not found');
    }

    const course = await this.courseModel
      .findById(courseId)
      .populate('instructorId', 'fullName avatarUrl headline bio')
      .lean()
      .exec();

    if (!course) {
      throw new NotFoundException('Course not found');
    }

    let sections: SectionDocument[] = [];
    if (includeCurriculum) {
      sections = await this.sectionModel
        .find({ courseId: new mongoose.Types.ObjectId(courseId) })
        .sort({ order: 1 })
        .lean()
        .exec();
    }

    let isEnrolled = false;
    let enrollmentId: string | undefined;
    let enrolledAt: Date | undefined;

    if (userId && mongoose.isValidObjectId(userId)) {
      const enrollment = await this.enrollmentModel
        .findOne({
          userId: new mongoose.Types.ObjectId(userId),
          courseId: new mongoose.Types.ObjectId(courseId),
          status: 'active',
        })
        .lean()
        .exec();

      if (enrollment) {
        isEnrolled = true;
        enrollmentId = enrollment._id.toString();
        enrolledAt = enrollment.enrolledAt;
      }
    }

    return {
      ...course,
      sections,
      isEnrolled,
      isRegistered: isEnrolled,
      enrollmentId,
      enrolledAt,
    };
  }

  async create(dto: CreateCourseDto, instructorId: string): Promise<CourseDocument> {
    const baseSlug = dto.slug ? this.slugify(dto.slug) : this.slugify(dto.title);
    const uniqueSlug = `${baseSlug}-${Date.now().toString(36)}`;

    const course = new this.courseModel({
      ...dto,
      slug: uniqueSlug,
      instructorId: new mongoose.Types.ObjectId(instructorId),
      status: 'draft',
      enrollmentCounts: 0,
      ratingAvg: 0,
      ratingCount: 0,
    });

    const saved = await course.save();
    await this.redisService.delByPattern('catalog:courses:*');
    return saved;
  }

  async update(
    courseId: string,
    dto: UpdateCourseDto,
    userId: string,
    userRole: string,
  ): Promise<CourseDocument> {
    const course = await this.courseModel.findById(courseId);
    if (!course) throw new NotFoundException('Course not found');

    const isOwner = course.instructorId.toString() === userId;
    const isSuperOrAdmin = userRole === 'SUPER_ADMIN' || userRole === 'ADMIN';

    if (!isOwner && !isSuperOrAdmin) {
      throw new ForbiddenException('You do not have permission to edit this course');
    }

    Object.assign(course, dto);
    const updated = await course.save();

    await this.redisService.delByPattern('catalog:courses:*');
    return updated;
  }

  async publish(courseId: string): Promise<CourseDocument> {
    const course = await this.courseModel.findById(courseId);
    if (!course) throw new NotFoundException('Course not found');

    course.status = 'published';
    const updated = await course.save();

    await this.redisService.delByPattern('catalog:courses:*');
    return updated;
  }

  async addSection(courseId: string, dto: CreateSectionDto): Promise<SectionDocument> {
    const course = await this.courseModel.findById(courseId);
    if (!course) throw new NotFoundException('Course not found');

    const section = new this.sectionModel({
      courseId: new mongoose.Types.ObjectId(courseId),
      title: dto.title,
      learningObjective: dto.learningObjective || '',
      order: dto.order ?? (await this.sectionModel.countDocuments({ courseId })),
      lessons: dto.lessons || [],
    });

    const saved = await section.save();
    await this.recalculateCourseStats(courseId);
    return saved;
  }

  async addLessonToSection(
    sectionId: string,
    dto: CreateLessonDto,
  ): Promise<SectionDocument> {
    const section = await this.sectionModel.findById(sectionId);
    if (!section) throw new NotFoundException('Section not found');

    section.lessons.push({
      title: dto.title,
      type: dto.type,
      order: dto.order ?? section.lessons.length,
      isFreePreview: !!dto.isFreePreview,
      video: dto.video as any,
      article: dto.article as any,
      resources: (dto.resources as any) || [],
      quizId: dto.quizId ? new mongoose.Types.ObjectId(dto.quizId) : undefined,
    });

    const saved = await section.save();
    await this.recalculateCourseStats(section.courseId.toString());
    return saved;
  }

  private async recalculateCourseStats(courseId: string): Promise<void> {
    const sections = await this.sectionModel.find({ courseId: new mongoose.Types.ObjectId(courseId) });
    let totalLessons = 0;
    let totalDuration = 0;

    for (const sec of sections) {
      totalLessons += sec.lessons.length;
      for (const lesson of sec.lessons) {
        if (lesson.video?.durationSeconds) {
          totalDuration += lesson.video.durationSeconds;
        }
      }
    }

    await this.courseModel.findByIdAndUpdate(courseId, {
      totalLessons,
      totalDurationSeconds: totalDuration,
    });

    await this.redisService.delByPattern('catalog:courses:*');
  }

  async delete(courseId: string): Promise<{ success: boolean; message: string }> {
    const course = await this.courseModel.findById(courseId);
    if (!course) throw new NotFoundException('Course not found');

    await Promise.all([
      this.courseModel.findByIdAndDelete(courseId),
      this.sectionModel.deleteMany({ courseId: new mongoose.Types.ObjectId(courseId) }),
    ]);

    await this.redisService.delByPattern('catalog:courses:*');
    return { success: true, message: 'Course and curriculum successfully deleted' };
  }
}

