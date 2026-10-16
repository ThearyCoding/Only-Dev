import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model } from 'mongoose';
import { Quiz, QuizDocument } from '../schemas/quiz.schema.js';
import { QuizSubmission, QuizSubmissionDocument } from '../schemas/quiz-submission.schema.js';
import { CreateQuizDto, SubmitQuizDto } from '../dto/quiz.dto.js';

@Injectable()
export class QuizzesService {
  constructor(
    @InjectModel(Quiz.name) private quizModel: Model<QuizDocument>,
    @InjectModel(QuizSubmission.name)
    private submissionModel: Model<QuizSubmissionDocument>,
  ) {}

  async create(dto: CreateQuizDto): Promise<QuizDocument> {
    const quiz = new this.quizModel({
      ...dto,
      courseId: new mongoose.Types.ObjectId(dto.courseId),
      lessonId: dto.lessonId ? new mongoose.Types.ObjectId(dto.lessonId) : undefined,
    });
    return quiz.save();
  }

  async findByCourseId(courseId: string): Promise<QuizDocument[]> {
    return this.quizModel.find({ courseId: new mongoose.Types.ObjectId(courseId) }).exec();
  }

  async getQuizForStudent(quizId: string): Promise<any> {
    const quiz = await this.quizModel.findById(quizId).lean().exec();
    if (!quiz) {
      throw new NotFoundException('Quiz not found');
    }

    // Mask isCorrect and explanation so students cannot inspect payload to cheat
    const sanitizedQuestions = quiz.questions.map((q) => ({
      _id: q._id,
      prompt: q.prompt,
      type: q.type,
      imageUrl: q.imageUrl,
      points: q.points,
      options: q.options.map((opt) => ({
        id: opt.id,
        text: opt.text,
      })),
    }));

    return {
      _id: quiz._id,
      title: quiz.title,
      courseId: quiz.courseId,
      lessonId: quiz.lessonId,
      timeLimitMinutes: quiz.timeLimitMinutes,
      maxAttemptsAllowed: quiz.maxAttemptsAllowed,
      passingScorePercent: quiz.passingScorePercent,
      questions: sanitizedQuestions,
    };
  }

  async submitAttempt(
    quizId: string,
    userId: string,
    dto: SubmitQuizDto,
  ): Promise<any> {
    const quiz = await this.quizModel.findById(quizId);
    if (!quiz) throw new NotFoundException('Quiz not found');

    const userObjId = new mongoose.Types.ObjectId(userId);
    const quizObjId = new mongoose.Types.ObjectId(quizId);

    // Check existing attempts
    const previousAttemptsCount = await this.submissionModel.countDocuments({
      quizId: quizObjId,
      userId: userObjId,
    });

    if (
      quiz.maxAttemptsAllowed > 0 &&
      previousAttemptsCount >= quiz.maxAttemptsAllowed
    ) {
      throw new BadRequestException(
        `Maximum allowed attempts (${quiz.maxAttemptsAllowed}) reached for this quiz`,
      );
    }

    let totalScore = 0;
    let maxPossibleScore = 0;
    const evaluatedAnswers: any[] = [];

    // Evaluate each question
    for (const q of quiz.questions) {
      const qIdStr = q._id ? q._id.toString() : '';
      const points = q.points || 1;
      maxPossibleScore += points;

      const studentAns = dto.answers.find((a) => a.questionId === qIdStr);
      const selectedOptionIds = studentAns?.selectedOptionIds || [];

      const correctOptionIds = q.options
        .filter((opt) => opt.isCorrect)
        .map((opt) => opt.id);

      // Check if selected options match correct options exactly
      const isCorrect =
        selectedOptionIds.length === correctOptionIds.length &&
        selectedOptionIds.every((id) => correctOptionIds.includes(id));

      const pointsAwarded = isCorrect ? points : 0;
      totalScore += pointsAwarded;

      evaluatedAnswers.push({
        questionId: qIdStr,
        selectedOptionIds,
        isCorrect,
        pointsAwarded,
      });
    }

    const scorePercent =
      maxPossibleScore > 0 ? Math.round((totalScore / maxPossibleScore) * 100) : 0;
    const isPassed = scorePercent >= quiz.passingScorePercent;

    const submission = new this.submissionModel({
      quizId: quizObjId,
      userId: userObjId,
      attemptNumber: previousAttemptsCount + 1,
      answers: evaluatedAnswers,
      totalScore,
      maxPossibleScore,
      scorePercent,
      isPassed,
      timeTakenSeconds: dto.timeTakenSeconds || 0,
      submittedAt: new Date(),
    });

    await submission.save();

    return {
      submissionId: submission._id,
      attemptNumber: submission.attemptNumber,
      totalScore,
      maxPossibleScore,
      scorePercent,
      passingScorePercent: quiz.passingScorePercent,
      isPassed,
      timeTakenSeconds: submission.timeTakenSeconds,
      answers: evaluatedAnswers,
    };
  }

  async getUserSubmissions(quizId: string, userId: string): Promise<QuizSubmissionDocument[]> {
    return this.submissionModel
      .find({
        quizId: new mongoose.Types.ObjectId(quizId),
        userId: new mongoose.Types.ObjectId(userId),
      })
      .sort({ attemptNumber: -1 })
      .exec();
  }
}

