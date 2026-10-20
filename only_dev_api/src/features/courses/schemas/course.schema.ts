import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';

export type CourseDocument = Course & Document;

@Schema({ timestamps: true })
export class Course {
  @Prop({ required: true, trim: true })
  title: string;

  @Prop({ required: true, lowercase: true, trim: true, index: true })
  slug: string;

  @Prop({ default: '' })
  shortDescription: string;

  @Prop({ required: true })
  description: string;

  @Prop({ required: true })
  thumbnailUrl: string;

  @Prop({ default: '' })
  blurHash?: string;

  @Prop({
    required: true,
    enum: ['beginner', 'intermediate', 'advanced', 'all_levels'],
    default: 'all_levels',
  })
  level: string;

  @Prop({ required: true, index: true })
  category: string;

  @Prop({ default: '' })
  subCategory?: string;

  @Prop({ type: [String], default: [] })
  tags: string[];

  @Prop({ required: true, default: 0 })
  price: number;

  @Prop({ default: 'USD', enum: ['USD', 'KHR'] })
  currency: string;

  @Prop({ default: 0 })
  discountPercentage: number;

  @Prop({
    required: true,
    enum: ['draft', 'pending_approval', 'published', 'archived'],
    default: 'draft',
    index: true,
  })
  status: string;

  // Single users table reference
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true })
  instructorId: mongoose.Types.ObjectId;

  @Prop({ type: [mongoose.Schema.Types.ObjectId], ref: 'User', default: [] })
  coInstructors: mongoose.Types.ObjectId[];

  @Prop({ default: 0 })
  ratingAvg: number;

  @Prop({ default: 0 })
  ratingCount: number;

  // Modern naming replacing registerCounts
  @Prop({ default: 0 })
  enrollmentCounts: number;

  @Prop({ default: 0 })
  totalDurationSeconds: number;

  @Prop({ default: 0 })
  totalLessons: number;

  @Prop({ type: String, default: null })
  createdBy?: string;

  @Prop({ type: String, default: null })
  updatedBy?: string;
}

export const CourseSchema = SchemaFactory.createForClass(Course);

CourseSchema.index({ status: 1, category: 1, createdAt: -1 });
CourseSchema.index({ title: 'text', description: 'text', tags: 'text' });

