import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { CoursesService } from '../service/courses.service.js';
import { CreateCourseDto, UpdateCourseDto, CreateSectionDto, CreateLessonDto } from '../dto/course.dto.js';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard.js';
import { DynamicRbacGuard } from '../../../common/guards/roles.guard.js';
import { Public } from '../../../common/decorators/public.decorator.js';
import { CurrentUser, CurrentUserPayload } from '../../../common/decorators/current-user.decorator.js';
import { RequirePermissions } from '../../../common/decorators/permissions.decorator.js';

@Controller('courses')
@UseGuards(JwtAuthGuard, DynamicRbacGuard)
export class CoursesController {
  constructor(private readonly coursesService: CoursesService) {}

  @Public()
  @Get()
  async getCourses(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('category') category?: string,
    @Query('level') level?: string,
    @Query('search') search?: string,
    @Query('status') status?: string,
  ) {
    return this.coursesService.findAll({ page, limit, category, level, search, status });
  }

  @Public()
  @Get(':id')
  async getCourseById(@Param('id') id: string) {
    return this.coursesService.findById(id, true);
  }

  @Post()
  @RequirePermissions('courses:create')
  async createCourse(
    @CurrentUser() user: CurrentUserPayload,
    @Body() dto: CreateCourseDto,
  ) {
    return this.coursesService.create(dto, user.userId);
  }

  @Put(':id')
  @RequirePermissions('courses:update_own')
  async updateCourse(
    @Param('id') id: string,
    @CurrentUser() user: CurrentUserPayload,
    @Body() dto: UpdateCourseDto,
  ) {
    return this.coursesService.update(id, dto, user.userId, user.role);
  }

  @Patch(':id/publish')
  @RequirePermissions('courses:publish')
  async publishCourse(@Param('id') id: string) {
    return this.coursesService.publish(id);
  }

  @Post(':id/sections')
  @RequirePermissions('courses:update_own')
  async addSection(
    @Param('id') courseId: string,
    @Body() dto: CreateSectionDto,
  ) {
    return this.coursesService.addSection(courseId, dto);
  }

  @Post('sections/:sectionId/lessons')
  @RequirePermissions('courses:update_own')
  async addLesson(
    @Param('sectionId') sectionId: string,
    @Body() dto: CreateLessonDto,
  ) {
    return this.coursesService.addLessonToSection(sectionId, dto);
  }

  @Delete(':id')
  @RequirePermissions('courses:delete_any')
  async deleteCourse(@Param('id') id: string) {
    return this.coursesService.delete(id);
  }
}

