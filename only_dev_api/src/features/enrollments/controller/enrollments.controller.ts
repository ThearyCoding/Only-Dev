import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { EnrollmentsService } from '../service/enrollments.service.js';
import { CreateEnrollmentDto, UpdateProgressDto } from '../dto/enrollment.dto.js';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard.js';
import { CurrentUser, CurrentUserPayload } from '../../../common/decorators/current-user.decorator.js';

@Controller('enrollments')
@UseGuards(JwtAuthGuard)
export class EnrollmentsController {
  constructor(private readonly enrollmentsService: EnrollmentsService) {}

  @Post()
  async enroll(
    @CurrentUser() user: CurrentUserPayload,
    @Body() dto: CreateEnrollmentDto,
  ) {
    return this.enrollmentsService.enroll(user.userId, dto);
  }

  @Get('my-courses')
  async getMyEnrolledCourses(@CurrentUser() user: CurrentUserPayload) {
    return this.enrollmentsService.getUserEnrolledCourses(user.userId);
  }

  @Get('check/:courseId')
  async checkEnrollment(
    @CurrentUser() user: CurrentUserPayload,
    @Param('courseId') courseId: string,
  ) {
    return this.enrollmentsService.isEnrolled(user.userId, courseId);
  }

  @Get('progress/:courseId')
  async getCourseProgress(
    @CurrentUser() user: CurrentUserPayload,
    @Param('courseId') courseId: string,
  ) {
    return this.enrollmentsService.getProgress(user.userId, courseId);
  }

  @Post('progress/:courseId')
  async updateProgress(
    @CurrentUser() user: CurrentUserPayload,
    @Param('courseId') courseId: string,
    @Body() dto: UpdateProgressDto,
  ) {
    return this.enrollmentsService.updateProgress(user.userId, courseId, dto);
  }
}

