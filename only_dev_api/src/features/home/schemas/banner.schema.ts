import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type BannerDocument = Banner & Document;

@Schema({ timestamps: true })
export class Banner {
  @Prop({ required: true })
  imageUrl: string;

  @Prop({ default: '' })
  targetUrl?: string;

  @Prop({ default: 0 })
  order: number;

  @Prop({ default: true, index: true })
  isActive: boolean;

  @Prop({ type: String, default: null })
  createdBy?: string;

  @Prop({ type: String, default: null })
  updatedBy?: string;
}

export const BannerSchema = SchemaFactory.createForClass(Banner);
BannerSchema.index({ isActive: 1, order: 1 });

