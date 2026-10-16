import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';

export type SectionDocument = Section & Document;

@Schema({ _id: false })
export class VideoSub {
  @Prop({ default: 'r2', enum: ['r2', 'youtube', 'vimeo'] })
  source: string;

  @Prop()
  rawUrl?: string; // Direct Cloudflare R2 CDN URL

  @Prop()
  hlsUrl?: string; // Optional HLS adaptive bitrate stream URL

  @Prop({ default: 0 })
  durationSeconds: number;

  @Prop()
  thumbnailUrl?: string;
}

@Schema({ _id: false })
export class ArticleSub {
  @Prop({ default: '' })
  contentMarkdown: string;

  @Prop({ default: 5 })
  readTimeMinutes: number;
}

@Schema({ _id: false })
export class ResourceSub {
  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  fileUrl: string;

  @Prop({ default: '' })
  r2Key?: string;

  @Prop({ default: 0 })
  fileSizeBytes: number;

  @Prop({ default: '' })
  extension: string;
}

@Schema({ timestamps: true })
export class Lesson {
  _id?: mongoose.Types.ObjectId;

  @Prop({ required: true })
  title: string;

  @Prop({
    required: true,
    enum: ['video', 'article', 'quiz', 'resource'],
    default: 'video',
  })
  type: string;

  @Prop({ default: 0 })
  order: number;

  @Prop({ default: false })
  isFreePreview: boolean;

  @Prop({ type: VideoSub, default: {} })
  video?: VideoSub;

  @Prop({ type: ArticleSub, default: {} })
  article?: ArticleSub;

  @Prop({ type: [ResourceSub], default: [] })
  resources: ResourceSub[];

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'Quiz' })
  quizId?: mongoose.Types.ObjectId;
}

export const LessonSchema = SchemaFactory.createForClass(Lesson);

@Schema({ timestamps: true })
export class Section {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true, index: true })
  courseId: mongoose.Types.ObjectId;

  @Prop({ required: true })
  title: string;

  @Prop({ default: '' })
  learningObjective?: string;

  @Prop({ default: 0 })
  order: number;

  @Prop({ type: [LessonSchema], default: [] })
  lessons: Lesson[];
}

export const SectionSchema = SchemaFactory.createForClass(Section);
SectionSchema.index({ courseId: 1, order: 1 });

