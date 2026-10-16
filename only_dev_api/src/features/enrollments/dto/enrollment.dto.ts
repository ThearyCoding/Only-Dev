import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsBoolean,
  IsIn,
} from 'class-validator';

export class CreateEnrollmentDto {
  @IsString()
  @IsNotEmpty()
  courseId: string;

  @IsString()
  @IsOptional()
  @IsIn(['free', 'paid', 'gift', 'admin_grant'])
  enrollmentType?: string;

  @IsOptional()
  pricePaid?: {
    amount?: number;
    currency?: string;
    paymentMethod?: string;
    transactionId?: string;
  };
}

export class UpdateProgressDto {
  @IsString()
  @IsNotEmpty()
  lessonId: string;

  @IsNumber()
  @IsOptional()
  positionSeconds?: number;

  @IsBoolean()
  @IsOptional()
  markCompleted?: boolean;
}

