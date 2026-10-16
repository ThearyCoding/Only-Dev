import {
  IsString,
  IsOptional,
  IsEmail,
  IsArray,
  IsObject,
  IsBoolean,
  MinLength,
} from 'class-validator';

export class UpdateProfileDto {
  @IsString()
  @IsOptional()
  fullName?: string;

  @IsString()
  @IsOptional()
  avatarUrl?: string;

  @IsString()
  @IsOptional()
  headline?: string;

  @IsString()
  @IsOptional()
  bio?: string;

  @IsString()
  @IsOptional()
  phoneNumber?: string;

  @IsObject()
  @IsOptional()
  socialLinks?: {
    website?: string;
    linkedin?: string;
    github?: string;
    youtube?: string;
  };
}

export class UpdateUserRoleDto {
  @IsString()
  role: string; // Any valid system or custom role
}

export class UpdateUserPermissionsDto {
  @IsArray()
  @IsString({ each: true })
  customPermissions: string[];
}

export class ChangePasswordDto {
  @IsString()
  @MinLength(6)
  currentPassword: string;

  @IsString()
  @MinLength(6)
  newPassword: string;
}

