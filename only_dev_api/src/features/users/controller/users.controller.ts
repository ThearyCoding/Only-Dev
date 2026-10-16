import {
  Controller,
  Get,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { UsersService } from '../service/users.service.js';
import { UpdateProfileDto, UpdateUserRoleDto, UpdateUserPermissionsDto } from '../dto/user.dto.js';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard.js';
import { DynamicRbacGuard } from '../../../common/guards/roles.guard.js';
import { CurrentUser, CurrentUserPayload } from '../../../common/decorators/current-user.decorator.js';
import { RequirePermissions } from '../../../common/decorators/permissions.decorator.js';

@Controller('users')
@UseGuards(JwtAuthGuard, DynamicRbacGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  async getMyProfile(@CurrentUser() user: CurrentUserPayload) {
    return this.usersService.findById(user.userId);
  }

  @Patch('me')
  async updateMyProfile(
    @CurrentUser() user: CurrentUserPayload,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.usersService.updateProfile(user.userId, dto);
  }

  @Get()
  @RequirePermissions('users:read')
  async listUsers(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('role') role?: string,
    @Query('search') search?: string,
  ) {
    return this.usersService.findAll({ page, limit, role, search });
  }

  @Get(':id')
  @RequirePermissions('users:read')
  async getUserById(@Param('id') id: string) {
    return this.usersService.findById(id);
  }

  @Patch(':id/role')
  @RequirePermissions('users:manage_roles')
  async updateUserRole(
    @Param('id') targetUserId: string,
    @Body() dto: UpdateUserRoleDto,
  ) {
    return this.usersService.updateUserRole(targetUserId, dto);
  }

  @Patch(':id/permissions')
  @RequirePermissions('users:manage_roles')
  async updateCustomPermissions(
    @Param('id') targetUserId: string,
    @Body() dto: UpdateUserPermissionsDto,
  ) {
    return this.usersService.updateCustomPermissions(targetUserId, dto);
  }

  @Patch(':id/ban')
  @RequirePermissions('users:ban')
  async toggleBan(
    @Param('id') targetUserId: string,
    @Body('isBanned') isBanned: boolean,
  ) {
    return this.usersService.setBanStatus(targetUserId, !!isBanned);
  }
}

