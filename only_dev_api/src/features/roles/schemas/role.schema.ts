import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type RoleDocument = Role & Document;

@Schema({ timestamps: true })
export class Role {
  @Prop({ required: true, unique: true, uppercase: true, trim: true })
  name: string; // e.g., 'SUPER_ADMIN', 'ADMIN', 'INSTRUCTOR', 'ASSISTANT', 'STUDENT', or custom e.g., 'CONTENT_EDITOR'

  @Prop({ required: true, trim: true })
  displayName: string; // e.g., 'Content Editor'

  @Prop({ default: '' })
  description: string;

  @Prop({ type: [String], default: [] })
  permissions: string[]; // e.g. ['courses:create', 'courses:update_own', 'storage:upload_video']

  @Prop({ default: false })
  isSystem: boolean; // System roles cannot be deleted, but permissions can be tailored

  @Prop({ default: true })
  isActive: boolean;
}

export const RoleSchema = SchemaFactory.createForClass(Role);
RoleSchema.index({ name: 1 }, { unique: true });

