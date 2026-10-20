import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type UserDocument = User & Document;

@Schema({ _id: false })
export class AuthProviderSub {
  @Prop({ required: true, enum: ['local', 'google', 'apple'] })
  provider: string;

  @Prop()
  providerId?: string;
}

@Schema({ _id: false })
export class SocialLinksSub {
  @Prop({ default: '' })
  website?: string;

  @Prop({ default: '' })
  linkedin?: string;

  @Prop({ default: '' })
  github?: string;

  @Prop({ default: '' })
  youtube?: string;
}

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email: string;

  @Prop()
  passwordHash?: string;

  // Single unified table for ALL users, instructors, and admins:
  // Role links directly to dynamic roles (e.g. 'STUDENT', 'INSTRUCTOR', 'ADMIN', 'SUPER_ADMIN', or any custom role)
  @Prop({ required: true, default: 'STUDENT', uppercase: true, trim: true, index: true })
  role: string;

  // Specific custom permission overrides for this individual user
  @Prop({ type: [String], default: [] })
  customPermissions: string[];

  @Prop({ type: [AuthProviderSub], default: [{ provider: 'local' }] })
  authProviders: AuthProviderSub[];

  @Prop({ required: true, trim: true })
  fullName: string;

  @Prop({ default: '' })
  avatarUrl: string;

  @Prop({ default: '' })
  headline: string; // e.g. "Senior Flutter & Cloud Architect"

  @Prop({ default: '' })
  bio: string;

  @Prop({ default: '' })
  phoneNumber: string;

  @Prop({ type: SocialLinksSub, default: {} })
  socialLinks: SocialLinksSub;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ default: false })
  isEmailVerified: boolean;

  @Prop()
  lastLoginAt?: Date;

  @Prop({ type: String, default: null })
  createdBy?: string;

  @Prop({ type: String, default: null })
  updatedBy?: string;
}

export const UserSchema = SchemaFactory.createForClass(User);

// Indexes
UserSchema.index({ email: 1 }, { unique: true });
UserSchema.index({ role: 1 });
UserSchema.index({ createdAt: -1 });

