import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';

export type QuizDocument = Quiz & Document;

@Schema({ _id: false })
export class OptionSub {
  @Prop({ required: true })
  id: string;

  @Prop({ required: true })
  text: string;

  @Prop({ required: true, default: false })
  isCorrect: boolean;

  @Prop({ default: '' })
  explanation?: string;
}

@Schema({ timestamps: true })
export class QuestionSub {
  _id?: mongoose.Types.ObjectId;

  @Prop({ required: true })
  prompt: string;

  @Prop({
    required: true,
    enum: ['single_choice', 'multiple_choice', 'true_false'],
    default: 'single_choice',
  })
  type: string;

  @Prop()
  imageUrl?: string;

  @Prop({ type: [OptionSub], required: true })
  options: OptionSub[];

  @Prop({ required: true, default: 1 })
  points: number;
}

export const QuestionSubSchema = SchemaFactory.createForClass(QuestionSub);

@Schema({ timestamps: true })
export class Quiz {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true, index: true })
  courseId: mongoose.Types.ObjectId;

  @Prop({ type: mongoose.Schema.Types.ObjectId, index: true })
  lessonId?: mongoose.Types.ObjectId;

  @Prop({ required: true })
  title: string;

  @Prop({ required: true, default: 70 })
  passingScorePercent: number;

  @Prop({ default: 0 })
  timeLimitMinutes: number; // 0 = untimed

  @Prop({ default: 0 })
  maxAttemptsAllowed: number; // 0 = unlimited

  @Prop({ default: false })
  shuffleQuestions: boolean;

  @Prop({ type: [QuestionSubSchema], default: [] })
  questions: QuestionSub[];

  @Prop({ type: String, default: null })
  createdBy?: string;

  @Prop({ type: String, default: null })
  updatedBy?: string;
}

export const QuizSchema = SchemaFactory.createForClass(Quiz);
QuizSchema.index({ courseId: 1 });

