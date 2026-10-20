import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Course, CourseSchema } from './schemas/course.schema.js';
import { Section, SectionSchema } from './schemas/section.schema.js';
import { Enrollment, EnrollmentSchema } from '../enrollments/schemas/enrollment.schema.js';
import { CoursesService } from './service/courses.service.js';
import { CoursesController } from './controller/courses.controller.js';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Course.name, schema: CourseSchema },
      { name: Section.name, schema: SectionSchema },
      { name: Enrollment.name, schema: EnrollmentSchema },
    ]),
  ],
  controllers: [CoursesController],
  providers: [CoursesService],
  exports: [CoursesService, MongooseModule],
})
export class CoursesModule {}

