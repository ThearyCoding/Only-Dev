import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { QuizzesService } from '../service/quizzes.service.js';
import { CreateQuizDto, SubmitQuizDto } from '../dto/quiz.dto.js';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard.js';
import { DynamicRbacGuard } from '../../../common/guards/roles.guard.js';
import { CurrentUser, CurrentUserPayload } from '../../../common/decorators/current-user.decorator.js';
import { RequirePermissions } from '../../../common/decorators/permissions.decorator.js';

@Controller('quizzes')
@UseGuards(JwtAuthGuard, DynamicRbacGuard)
export class QuizzesController {
  constructor(private readonly quizzesService: QuizzesService) {}

  @Post()
  @RequirePermissions('quizzes:manage_own')
  async createQuiz(@Body() dto: CreateQuizDto) {
    return this.quizzesService.create(dto);
  }

  @Get('course/:courseId')
  async getQuizzesByCourse(@Param('courseId') courseId: string) {
    return this.quizzesService.findByCourseId(courseId);
  }

  @Get(':id')
  async getQuizForTaking(@Param('id') id: string) {
    return this.quizzesService.getQuizForStudent(id);
  }

  @Post(':id/submit')
  async submitQuiz(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') quizId: string,
    @Body() dto: SubmitQuizDto,
  ) {
    return this.quizzesService.submitAttempt(quizId, user.userId, dto);
  }

  @Get(':id/attempts')
  async getMyAttempts(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') quizId: string,
  ) {
    return this.quizzesService.getUserSubmissions(quizId, user.userId);
  }
}

