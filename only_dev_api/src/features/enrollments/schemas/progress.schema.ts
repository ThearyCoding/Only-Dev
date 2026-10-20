import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';

export type UserCourseProgressDocument = UserCourseProgress & Document;

@Schema({ _id: false })
export class PlaybackPositionSub {
  @Prop({ type: mongoose.Schema.Types.ObjectId, required: true })
  lessonId: mongoose.Types.ObjectId;

  @Prop({ required: true, default: 0 })
  positionSeconds: number;

  @Prop({ default: Date.now })
  updatedAt: Date;
}

@Schema({ timestamps: true })
export class UserCourseProgress {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true })
  userId: mongoose.Types.ObjectId;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true, index: true })
  courseId: mongoose.Types.ObjectId;

  @Prop({ type: [mongoose.Schema.Types.ObjectId], default: [] })
  completedLessonIds: mongoose.Types.ObjectId[];

  @Prop({ type: mongoose.Schema.Types.ObjectId })
  lastAccessedLessonId?: mongoose.Types.ObjectId;

  @Prop({ type: [PlaybackPositionSub], default: [] })
  lastPlaybackPositions: PlaybackPositionSub[];

  @Prop({ default: 0, min: 0, max: 100 })
  percentComplete: number;

  @Prop({ default: false })
  isCompleted: boolean;

  @Prop()
  completedAt?: Date;

  @Prop()
  certificateId?: string;

  @Prop({ type: String, default: null })
  createdBy?: string;

  @Prop({ type: String, default: null })
  updatedBy?: string;
}

export const UserCourseProgressSchema = SchemaFactory.createForClass(UserCourseProgress);

// Compound unique index: exactly 1 progress record per student per course
UserCourseProgressSchema.index({ userId: 1, courseId: 1 }, { unique: true });

