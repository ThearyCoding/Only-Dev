import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';

export type EnrollmentDocument = Enrollment & Document;

@Schema({ _id: false })
export class PricePaidSub {
  @Prop({ default: 0 })
  amount: number;

  @Prop({ default: 'USD', enum: ['USD', 'KHR'] })
  currency: string;

  @Prop({ default: 'free_promo' })
  paymentMethod?: string;

  @Prop()
  transactionId?: string;
}

@Schema({ timestamps: true })
export class Enrollment {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true })
  userId: mongoose.Types.ObjectId;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true, index: true })
  courseId: mongoose.Types.ObjectId;

  @Prop({
    required: true,
    enum: ['free', 'paid', 'gift', 'admin_grant'],
    default: 'free',
  })
  enrollmentType: string;

  @Prop({
    required: true,
    enum: ['active', 'suspended', 'refunded', 'expired'],
    default: 'active',
    index: true,
  })
  status: string;

  @Prop({ type: PricePaidSub, default: {} })
  pricePaid: PricePaidSub;

  @Prop({ default: Date.now })
  enrolledAt: Date;

  @Prop()
  expiresAt?: Date; // null = lifetime access
}

export const EnrollmentSchema = SchemaFactory.createForClass(Enrollment);

// Compound unique index: a user can only have one active enrollment per course
EnrollmentSchema.index({ userId: 1, courseId: 1 }, { unique: true });

