import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type CategoryDocument = Category & Document;

@Schema({ timestamps: true })
export class Category {
  @Prop({ required: true, trim: true })
  title: string;

  @Prop({ required: true, unique: true, lowercase: true, trim: true, index: true })
  slug: string;

  @Prop({ required: true })
  imageUrl: string;

  @Prop({ default: '' })
  blurHash?: string;

  @Prop({ default: 0 })
  order: number;

  @Prop({ default: true, index: true })
  isActive: boolean;

  @Prop({ type: String, default: null })
  createdBy?: string;

  @Prop({ type: String, default: null })
  updatedBy?: string;
}

export const CategorySchema = SchemaFactory.createForClass(Category);
CategorySchema.index({ isActive: 1, order: 1 });

