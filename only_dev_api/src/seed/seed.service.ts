import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model } from 'mongoose';
import bcrypt from 'bcryptjs';
import { User, UserDocument } from '../features/users/schemas/user.schema.js';
import { Role, RoleDocument } from '../features/roles/schemas/role.schema.js';
import { Category, CategoryDocument } from '../features/home/schemas/category.schema.js';
import { Banner, BannerDocument } from '../features/home/schemas/banner.schema.js';
import { Course, CourseDocument } from '../features/courses/schemas/course.schema.js';
import { Section, SectionDocument } from '../features/courses/schemas/section.schema.js';
import { Quiz, QuizDocument } from '../features/quizzes/schemas/quiz.schema.js';
import { Enrollment, EnrollmentDocument } from '../features/enrollments/schemas/enrollment.schema.js';
import { UserCourseProgress, UserCourseProgressDocument } from '../features/enrollments/schemas/progress.schema.js';
import { RedisService } from '../common/redis/redis.service.js';
import { RolesService } from '../features/roles/service/roles.service.js';
import {
  SEED_CATEGORIES,
  SEED_BANNERS,
  SEED_USERS,
  SEED_COURSES,
  SEED_QUIZZES,
} from './seed.data.js';

export interface SeedResult {
  success: boolean;
  message: string;
  counts: {
    roles: number;
    users: number;
    categories: number;
    banners: number;
    courses: number;
    sections: number;
    lessons: number;
    quizzes: number;
    enrollments: number;
  };
  sampleAccounts: {
    admin: { email: string; pass: string; role: string };
    instructor: { email: string; pass: string; role: string };
    student: { email: string; pass: string; role: string };
  };
}

@Injectable()
export class SeedService {
  private readonly logger = new Logger(SeedService.name);

  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    @InjectModel(Role.name) private readonly roleModel: Model<RoleDocument>,
    @InjectModel(Category.name) private readonly categoryModel: Model<CategoryDocument>,
    @InjectModel(Banner.name) private readonly bannerModel: Model<BannerDocument>,
    @InjectModel(Course.name) private readonly courseModel: Model<CourseDocument>,
    @InjectModel(Section.name) private readonly sectionModel: Model<SectionDocument>,
    @InjectModel(Quiz.name) private readonly quizModel: Model<QuizDocument>,
    @InjectModel(Enrollment.name) private readonly enrollmentModel: Model<EnrollmentDocument>,
    @InjectModel(UserCourseProgress.name)
    private readonly progressModel: Model<UserCourseProgressDocument>,
    private readonly rolesService: RolesService,
    private readonly redisService: RedisService,
  ) {}

  async runSeed(): Promise<SeedResult> {
    this.logger.log('Starting comprehensive database seeding...');

    // 1. Roles
    await this.rolesService.seedDefaultRoles();
    const rolesCount = await this.roleModel.countDocuments();
    this.logger.log(`Verified ${rolesCount} system roles.`);

    // 2. Users
    const defaultPassword = 'password123';
    const passwordHash = await bcrypt.hash(defaultPassword, 10);
    const userMap = new Map<string, mongoose.Types.ObjectId>();

    for (const u of SEED_USERS) {
      let existingUser = await this.userModel.findOne({ email: u.email });
      if (!existingUser) {
        existingUser = await this.userModel.create({
          ...u,
          passwordHash,
          isActive: true,
          isEmailVerified: true,
        });
        this.logger.log(`Created user: ${u.email} (${u.role})`);
      } else {
        existingUser.fullName = u.fullName;
        existingUser.headline = u.headline;
        existingUser.bio = u.bio;
        existingUser.avatarUrl = u.avatarUrl;
        existingUser.role = u.role;
        existingUser.passwordHash = passwordHash;
        await existingUser.save();
        this.logger.log(`Updated user: ${u.email} (${u.role})`);
      }
      userMap.set(u.email, existingUser._id as mongoose.Types.ObjectId);
    }

    // 3. Categories
    for (const cat of SEED_CATEGORIES) {
      await this.categoryModel.findOneAndUpdate(
        { slug: cat.slug },
        { ...cat, isActive: true },
        { upsert: true, new: true },
      );
    }
    const categoriesCount = await this.categoryModel.countDocuments();
    this.logger.log(`Seeded ${categoriesCount} categories.`);

    // 4. Banners
    await this.bannerModel.deleteMany({});
    for (const banner of SEED_BANNERS) {
      await this.bannerModel.create({ ...banner, isActive: true });
    }
    const bannersCount = await this.bannerModel.countDocuments();
    this.logger.log(`Seeded ${bannersCount} promotional banners.`);

    // 5. Courses & Sections
    let totalSectionsCount = 0;
    let totalLessonsCount = 0;
    const courseMap = new Map<string, mongoose.Types.ObjectId>();

    for (const cData of SEED_COURSES) {
      const instructorId =
        userMap.get(cData.instructorEmail) ||
        userMap.get('angela@onlydev.com') ||
        (await this.userModel.findOne({ role: 'INSTRUCTOR' }))?._id;

      let totalDuration = 0;
      let totalLessons = 0;

      for (const sec of cData.sections) {
        totalLessons += sec.lessons.length;
        for (const les of sec.lessons) {
          totalDuration += les.durationSeconds;
        }
      }

      // Upsert course
      let course = await this.courseModel.findOne({ slug: cData.slug });
      if (!course) {
        course = await this.courseModel.create({
          title: cData.title,
          slug: cData.slug,
          shortDescription: cData.shortDescription,
          description: cData.description,
          thumbnailUrl: cData.thumbnailUrl,
          blurHash: cData.blurHash,
          level: cData.level,
          category: cData.categorySlug,
          tags: cData.tags,
          price: cData.price,
          currency: cData.currency,
          discountPercentage: cData.discountPercentage,
          status: cData.status,
          instructorId,
          ratingAvg: cData.ratingAvg,
          ratingCount: cData.ratingCount,
          enrollmentCounts: cData.enrollmentCounts,
          totalDurationSeconds: totalDuration,
          totalLessons: totalLessons,
        });
      } else {
        course.title = cData.title;
        course.shortDescription = cData.shortDescription;
        course.description = cData.description;
        course.thumbnailUrl = cData.thumbnailUrl;
        course.blurHash = cData.blurHash;
        course.level = cData.level;
        course.category = cData.categorySlug;
        course.tags = cData.tags;
        course.price = cData.price;
        course.currency = cData.currency;
        course.discountPercentage = cData.discountPercentage;
        course.status = cData.status;
        course.ratingAvg = cData.ratingAvg;
        course.ratingCount = cData.ratingCount;
        course.enrollmentCounts = cData.enrollmentCounts;
        course.totalDurationSeconds = totalDuration;
        course.totalLessons = totalLessons;
        await course.save();
      }

      const courseId = course._id as mongoose.Types.ObjectId;
      courseMap.set(cData.slug, courseId);

      // Remove existing sections for this course to ensure clean state
      await this.sectionModel.deleteMany({ courseId });

      let secOrder = 1;
      for (const sData of cData.sections) {
        let lessonOrder = 1;
        const lessons = sData.lessons.map((les) => ({
          _id: new mongoose.Types.ObjectId(),
          title: les.title,
          type: les.type,
          order: lessonOrder++,
          isFreePreview: les.isFreePreview,
          video: {
            source: 'r2',
            rawUrl: les.videoUrl,
            hlsUrl: les.hlsUrl,
            durationSeconds: les.durationSeconds,
            thumbnailUrl: les.thumbnailUrl,
          },
          resources: [],
        }));

        await this.sectionModel.create({
          courseId,
          title: sData.title,
          learningObjective: sData.learningObjective,
          order: secOrder++,
          lessons,
        });

        totalSectionsCount++;
        totalLessonsCount += lessons.length;
      }

      this.logger.log(
        `Seeded course: "${cData.title}" with ${cData.sections.length} sections and ${totalLessons} lessons.`,
      );
    }

    const coursesCount = await this.courseModel.countDocuments();

    // 6. Quizzes
    for (const q of SEED_QUIZZES) {
      const courseId = courseMap.get(q.courseSlug);
      if (courseId) {
        await this.quizModel.findOneAndUpdate(
          { courseId, title: q.title },
          {
            courseId,
            title: q.title,
            passingScorePercent: q.passingScorePercent,
            timeLimitMinutes: q.timeLimitMinutes,
            maxAttemptsAllowed: q.maxAttemptsAllowed,
            shuffleQuestions: q.shuffleQuestions,
            questions: q.questions,
          },
          { upsert: true, new: true },
        );
      }
    }
    const quizzesCount = await this.quizModel.countDocuments();
    this.logger.log(`Seeded ${quizzesCount} interactive quizzes.`);

    // 7. Enrollments & Progress for Student
    const studentId = userMap.get('student@onlydev.com');
    let enrollmentsCount = 0;

    if (studentId) {
      const flutterCourseId = courseMap.get('master-flutter-3-riverpod-production');
      const nestCourseId = courseMap.get('modern-fullstack-nestjs-microservices');
      const dockerCourseId = courseMap.get('docker-kubernetes-cloud-architecture');

      // Flutter Course: 45% Ongoing
      if (flutterCourseId) {
        await this.enrollmentModel.findOneAndUpdate(
          { userId: studentId, courseId: flutterCourseId },
          {
            userId: studentId,
            courseId: flutterCourseId,
            enrollmentType: 'free',
            status: 'active',
            pricePaid: { amount: 0, currency: 'USD', paymentMethod: 'free_promo' },
            enrolledAt: new Date(),
          },
          { upsert: true, new: true },
        );

        // Fetch section lessons to mark first 2 completed
        const sections = (await this.sectionModel.find({ courseId: flutterCourseId }).sort({ order: 1 })) || [];
        const completedIds: mongoose.Types.ObjectId[] = [];
        let firstLessonId: mongoose.Types.ObjectId | undefined;

        if (Array.isArray(sections) && sections.length > 0 && (sections[0].lessons || []).length > 0) {
          firstLessonId = sections[0].lessons[0]._id as mongoose.Types.ObjectId;
          completedIds.push(firstLessonId);
          if (sections[0].lessons.length > 1) {
            completedIds.push(sections[0].lessons[1]._id as mongoose.Types.ObjectId);
          }
        }

        await this.progressModel.findOneAndUpdate(
          { userId: studentId, courseId: flutterCourseId },
          {
            userId: studentId,
            courseId: flutterCourseId,
            completedLessonIds: completedIds,
            lastAccessedLessonId: firstLessonId,
            lastPlaybackPositions: firstLessonId
              ? [{ lessonId: firstLessonId, positionSeconds: 24, updatedAt: new Date() }]
              : [],
            percentComplete: 45,
            isCompleted: false,
          },
          { upsert: true, new: true },
        );
        enrollmentsCount++;
      }

      // NestJS Course: 100% Completed
      if (nestCourseId) {
        await this.enrollmentModel.findOneAndUpdate(
          { userId: studentId, courseId: nestCourseId },
          {
            userId: studentId,
            courseId: nestCourseId,
            enrollmentType: 'paid',
            status: 'active',
            pricePaid: { amount: 49.99, currency: 'USD', paymentMethod: 'card' },
            enrolledAt: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000),
          },
          { upsert: true, new: true },
        );

        const nestSections = (await this.sectionModel.find({ courseId: nestCourseId })) || [];
        const allLessonIds = Array.isArray(nestSections)
          ? nestSections.flatMap((s) => (s.lessons || []).map((l: any) => l._id as mongoose.Types.ObjectId))
          : [];

        await this.progressModel.findOneAndUpdate(
          { userId: studentId, courseId: nestCourseId },
          {
            userId: studentId,
            courseId: nestCourseId,
            completedLessonIds: allLessonIds,
            percentComplete: 100,
            isCompleted: true,
            completedAt: new Date(),
          },
          { upsert: true, new: true },
        );
        enrollmentsCount++;
      }

      // Docker Course: 15% Ongoing
      if (dockerCourseId) {
        await this.enrollmentModel.findOneAndUpdate(
          { userId: studentId, courseId: dockerCourseId },
          {
            userId: studentId,
            courseId: dockerCourseId,
            enrollmentType: 'free',
            status: 'active',
            pricePaid: { amount: 0, currency: 'USD', paymentMethod: 'free_promo' },
            enrolledAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
          },
          { upsert: true, new: true },
        );

        const dockerSections = (await this.sectionModel.find({ courseId: dockerCourseId })) || [];
        const firstLesson = Array.isArray(dockerSections) && dockerSections[0]?.lessons?.[0]?._id
          ? (dockerSections[0].lessons[0]._id as mongoose.Types.ObjectId)
          : undefined;

        await this.progressModel.findOneAndUpdate(
          { userId: studentId, courseId: dockerCourseId },
          {
            userId: studentId,
            courseId: dockerCourseId,
            completedLessonIds: firstLesson ? [firstLesson] : [],
            lastAccessedLessonId: firstLesson,
            percentComplete: 15,
            isCompleted: false,
          },
          { upsert: true, new: true },
        );
        enrollmentsCount++;
      }

      this.logger.log(`Created ${enrollmentsCount} active student enrollments with progress.`);
    }

    // 8. Invalidate Redis Caches
    try {
      await this.redisService.del('screen:home');
      await this.redisService.delByPattern('catalog:courses:*');
      this.logger.log('Redis caches successfully invalidated.');
    } catch (e: any) {
      this.logger.warn(`Redis cache invalidation skipped: ${e.message}`);
    }

    this.logger.log('✅ Seeding completed successfully!');

    return {
      success: true,
      message: 'Database seeded successfully with courses, sections, real videos, and quizzes.',
      counts: {
        roles: rolesCount,
        users: SEED_USERS.length,
        categories: categoriesCount,
        banners: bannersCount,
        courses: coursesCount,
        sections: totalSectionsCount,
        lessons: totalLessonsCount,
        quizzes: quizzesCount,
        enrollments: enrollmentsCount,
      },
      sampleAccounts: {
        admin: { email: 'admin@onlydev.com', pass: defaultPassword, role: 'SUPER_ADMIN' },
        instructor: { email: 'angela@onlydev.com', pass: defaultPassword, role: 'INSTRUCTOR' },
        student: { email: 'student@onlydev.com', pass: defaultPassword, role: 'STUDENT' },
      },
    };
  }
}
