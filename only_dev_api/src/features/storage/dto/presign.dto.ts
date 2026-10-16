import { IsString, IsNotEmpty, IsIn, IsNumber, IsOptional } from 'class-validator';

export class PresignRequestDto {
  @IsString()
  @IsNotEmpty()
  fileName: string;

  @IsString()
  @IsNotEmpty()
  contentType: string; // e.g. 'video/mp4', 'image/jpeg', 'application/pdf'

  @IsString()
  @IsIn(['videos', 'thumbnails', 'avatars', 'attachments', 'resources'])
  folder: string;

  @IsNumber()
  @IsOptional()
  fileSizeBytes?: number;
}

