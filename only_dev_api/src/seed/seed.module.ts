import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { User, UserSchema } from '../features/users/schemas/user.schema.js';
import { Role, RoleSchema } from '../features/roles/schemas/role.schema.js';
import { Category, CategorySchema } from '../features/home/schemas/category.schema.js';
import { Banner, BannerSchema } from '../features/home/schemas/banner.schema.js';
import { Course, CourseSchema } from '../features/courses/schemas/course.schema.js';
import { Section, SectionSchema } from '../features/courses/schemas/section.schema.js';
import { Quiz, QuizSchema } from '../features/quizzes/schemas/quiz.schema.js';
import { Enrollment, EnrollmentSchema } from '../features/enrollments/schemas/enrollment.schema.js';
import {
  UserCourseProgress,
  UserCourseProgressSchema,
} from '../features/enrollments/schemas/progress.schema.js';
import { RolesModule } from '../features/roles/roles.module.js';
import { RedisModule } from '../common/redis/redis.module.js';
import { SeedService } from './seed.service.js';
import { SeedController } from './seed.controller.js';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Role.name, schema: RoleSchema },
      { name: Category.name, schema: CategorySchema },
      { name: Banner.name, schema: BannerSchema },
      { name: Course.name, schema: CourseSchema },
      { name: Section.name, schema: SectionSchema },
      { name: Quiz.name, schema: QuizSchema },
      { name: Enrollment.name, schema: EnrollmentSchema },
      { name: UserCourseProgress.name, schema: UserCourseProgressSchema },
    ]),
    RolesModule,
    RedisModule,
  ],
  controllers: [SeedController],
  providers: [SeedService],
  exports: [SeedService],
})
export class SeedModule {}

