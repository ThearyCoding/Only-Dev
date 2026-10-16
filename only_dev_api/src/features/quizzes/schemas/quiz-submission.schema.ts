import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';

export type QuizSubmissionDocument = QuizSubmission & Document;

@Schema({ _id: false })
export class AnswerSub {
  @Prop({ required: true })
  questionId: string;

  @Prop({ type: [String], default: [] })
  selectedOptionIds: string[];

  @Prop({ required: true, default: false })
  isCorrect: boolean;

  @Prop({ required: true, default: 0 })
  pointsAwarded: number;
}

@Schema({ timestamps: true })
export class QuizSubmission {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'Quiz', required: true, index: true })
  quizId: mongoose.Types.ObjectId;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true })
  userId: mongoose.Types.ObjectId;

  @Prop({ default: 1 })
  attemptNumber: number;

  @Prop({ type: [AnswerSub], default: [] })
  answers: AnswerSub[];

  @Prop({ required: true, default: 0 })
  totalScore: number;

  @Prop({ required: true, default: 0 })
  maxPossibleScore: number;

  @Prop({ required: true, default: 0 })
  scorePercent: number;

  @Prop({ required: true, default: false })
  isPassed: boolean;

  @Prop({ default: 0 })
  timeTakenSeconds: number;

  @Prop({ default: Date.now })
  submittedAt: Date;
}

export const QuizSubmissionSchema = SchemaFactory.createForClass(QuizSubmission);
QuizSubmissionSchema.index({ quizId: 1, userId: 1, attemptNumber: 1 });

