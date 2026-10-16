import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { RolesService } from '../service/roles.service.js';
import { CreateRoleDto, UpdateRoleDto } from '../dto/create-role.dto.js';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard.js';
import { DynamicRbacGuard } from '../../../common/guards/roles.guard.js';
import { RequirePermissions } from '../../../common/decorators/permissions.decorator.js';

@Controller('roles')
@UseGuards(JwtAuthGuard, DynamicRbacGuard)
export class RolesController {
  constructor(private readonly rolesService: RolesService) {}

  @Get('permissions/available')
  @RequirePermissions('roles:read')
  getAvailablePermissions() {
    return this.rolesService.getAvailablePermissions();
  }

  @Get()
  @RequirePermissions('roles:read')
  async getAllRoles() {
    return this.rolesService.findAll();
  }

  @Get(':name')
  @RequirePermissions('roles:read')
  async getRoleByName(@Param('name') name: string) {
    return this.rolesService.findByName(name);
  }

  @Post()
  @RequirePermissions('roles:manage')
  async createRole(@Body() createRoleDto: CreateRoleDto) {
    return this.rolesService.create(createRoleDto);
  }

  @Put(':id')
  @RequirePermissions('roles:manage')
  async updateRole(
    @Param('id') id: string,
    @Body() updateRoleDto: UpdateRoleDto,
  ) {
    return this.rolesService.update(id, updateRoleDto);
  }

  @Delete(':id')
  @RequirePermissions('roles:manage')
  async deleteRole(@Param('id') id: string) {
    return this.rolesService.delete(id);
  }
}

