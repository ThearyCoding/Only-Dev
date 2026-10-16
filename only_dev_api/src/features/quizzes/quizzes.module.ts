import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Quiz, QuizSchema } from './schemas/quiz.schema.js';
import { QuizSubmission, QuizSubmissionSchema } from './schemas/quiz-submission.schema.js';
import { QuizzesService } from './service/quizzes.service.js';
import { QuizzesController } from './controller/quizzes.controller.js';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Quiz.name, schema: QuizSchema },
      { name: QuizSubmission.name, schema: QuizSubmissionSchema },
    ]),
  ],
  controllers: [QuizzesController],
  providers: [QuizzesService],
  exports: [QuizzesService, MongooseModule],
})
export class QuizzesModule {}

