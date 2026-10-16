import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsArray,
  IsIn,
  Min,
  Max,
  IsBoolean,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateCourseDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsOptional()
  slug?: string;

  @IsString()
  @IsOptional()
  shortDescription?: string;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsString()
  @IsNotEmpty()
  thumbnailUrl: string;

  @IsString()
  @IsOptional()
  blurHash?: string;

  @IsString()
  @IsIn(['beginner', 'intermediate', 'advanced', 'all_levels'])
  level: string;

  @IsString()
  @IsNotEmpty()
  category: string;

  @IsString()
  @IsOptional()
  subCategory?: string;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  tags?: string[];

  @IsNumber()
  @Min(0)
  price: number;

  @IsString()
  @IsOptional()
  @IsIn(['USD', 'KHR'])
  currency?: string;

  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  discountPercentage?: number;
}

export class UpdateCourseDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  shortDescription?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  thumbnailUrl?: string;

  @IsString()
  @IsOptional()
  blurHash?: string;

  @IsString()
  @IsIn(['beginner', 'intermediate', 'advanced', 'all_levels'])
  @IsOptional()
  level?: string;

  @IsString()
  @IsOptional()
  category?: string;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  tags?: string[];

  @IsNumber()
  @Min(0)
  @IsOptional()
  price?: number;

  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  discountPercentage?: number;

  @IsString()
  @IsIn(['draft', 'pending_approval', 'published', 'archived'])
  @IsOptional()
  status?: string;
}

export class CreateLessonDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsIn(['video', 'article', 'quiz', 'resource'])
  type: string;

  @IsNumber()
  @IsOptional()
  order?: number;

  @IsBoolean()
  @IsOptional()
  isFreePreview?: boolean;

  @IsOptional()
  video?: {
    source?: string;
    rawUrl?: string;
    hlsUrl?: string;
    durationSeconds?: number;
    thumbnailUrl?: string;
  };

  @IsOptional()
  article?: {
    contentMarkdown?: string;
    readTimeMinutes?: number;
  };

  @IsArray()
  @IsOptional()
  resources?: {
    title: string;
    fileUrl: string;
    r2Key?: string;
    fileSizeBytes?: number;
    extension?: string;
  }[];

  @IsString()
  @IsOptional()
  quizId?: string;
}

export class CreateSectionDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsOptional()
  learningObjective?: string;

  @IsNumber()
  @IsOptional()
  order?: number;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateLessonDto)
  @IsOptional()
  lessons?: CreateLessonDto[];
}

