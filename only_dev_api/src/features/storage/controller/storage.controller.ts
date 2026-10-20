import {
  Controller,
  Post,
  Body,
  UseGuards,
  ForbiddenException,
} from '@nestjs/common';
import { StorageService } from '../service/storage.service.js';
import { PresignRequestDto } from '../dto/presign.dto.js';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard.js';
import { DynamicRbacGuard } from '../../../common/guards/roles.guard.js';
import { CurrentUser, CurrentUserPayload } from '../../../common/decorators/current-user.decorator.js';

@Controller('storage')
@UseGuards(JwtAuthGuard, DynamicRbacGuard)
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @Post('presign')
  async getPresignedUploadUrl(
    @CurrentUser() user: CurrentUserPayload,
    @Body() dto: PresignRequestDto,
  ) {
    // Basic folder permission rules:
    // Any authenticated user can upload their own avatar, post images, thumbnails, etc.
    if (dto.folder !== 'videos') {
      return this.storageService.generatePresignedUploadUrl(user.userId, dto);
    }

    // Video uploads require INSTRUCTOR or higher, or storage:upload_video permission
    if (dto.folder === 'videos') {
      const allowedRoles = ['INSTRUCTOR', 'ADMIN', 'SUPER_ADMIN'];
      const hasRole = allowedRoles.includes(user.role.toUpperCase());
      const hasPermission = user.customPermissions?.includes('storage:upload_video');
      if (!hasRole && !hasPermission) {
        throw new ForbiddenException('Only instructors or administrators can upload lesson videos');
      }
    }

    return this.storageService.generatePresignedUploadUrl(user.userId, dto);
  }
}

