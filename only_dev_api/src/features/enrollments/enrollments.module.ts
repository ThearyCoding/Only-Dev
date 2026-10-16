import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Enrollment, EnrollmentSchema } from './schemas/enrollment.schema.js';
import { UserCourseProgress, UserCourseProgressSchema } from './schemas/progress.schema.js';
import { EnrollmentsService } from './service/enrollments.service.js';
import { EnrollmentsController } from './controller/enrollments.controller.js';
import { CoursesModule } from '../courses/courses.module.js';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Enrollment.name, schema: EnrollmentSchema },
      { name: UserCourseProgress.name, schema: UserCourseProgressSchema },
    ]),
    CoursesModule,
  ],
  controllers: [EnrollmentsController],
  providers: [EnrollmentsService],
  exports: [EnrollmentsService, MongooseModule],
})
export class EnrollmentsModule {}

