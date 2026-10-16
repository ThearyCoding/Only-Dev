import {
  Injectable,
  NotFoundException,
  BadRequestException,
  OnModuleInit,
  Logger,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Role, RoleDocument } from '../schemas/role.schema.js';
import { CreateRoleDto, UpdateRoleDto } from '../dto/create-role.dto.js';
import { PLATFORM_PERMISSIONS } from '../constants/permissions.constant.js';
import { RedisService } from '../../../common/redis/redis.service.js';

@Injectable()
export class RolesService implements OnModuleInit {
  private readonly logger = new Logger(RolesService.name);

  constructor(
    @InjectModel(Role.name) private roleModel: Model<RoleDocument>,
    private readonly redisService: RedisService,
  ) {}

  async onModuleInit() {
    await this.seedDefaultRoles();
  }

  /**
   * Seed default system roles if they don't already exist.
   * Admins can also create custom roles anytime.
   */
  async seedDefaultRoles(): Promise<void> {
    const defaultRoles = [
      {
        name: 'SUPER_ADMIN',
        displayName: 'Super Administrator',
        description: 'Root access to all features, settings, billing, and role creation',
        permissions: ['*'], // Wildcard matches all permissions
        isSystem: true,
      },
      {
        name: 'ADMIN',
        displayName: 'Administrator',
        description: 'Platform management, course publishing, and user moderation',
        permissions: [
          'courses:read_published',
          'courses:create',
          'courses:update_any',
          'courses:publish',
          'storage:upload_video',
          'storage:upload_attachment',
          'enrollments:create',
          'enrollments:manage_any',
          'quizzes:attempt',
          'quizzes:manage_own',
          'quizzes:grade',
          'users:read',
          'users:ban',
          'roles:read',
          'roles:manage',
          'analytics:view',
        ],
        isSystem: true,
      },
      {
        name: 'INSTRUCTOR',
        displayName: 'Instructor / Teacher',
        description: 'Creates and manages own courses, curriculums, and quizzes',
        permissions: [
          'courses:read_published',
          'courses:create',
          'courses:update_own',
          'storage:upload_video',
          'storage:upload_attachment',
          'quizzes:manage_own',
          'quizzes:grade',
          'enrollments:create',
          'quizzes:attempt',
        ],
        isSystem: true,
      },
      {
        name: 'ASSISTANT',
        displayName: 'Teaching Assistant',
        description: 'Assists instructors with grading and student questions',
        permissions: [
          'courses:read_published',
          'quizzes:grade',
          'enrollments:create',
          'quizzes:attempt',
        ],
        isSystem: true,
      },
      {
        name: 'STUDENT',
        displayName: 'Student / Learner',
        description: 'Default user role for browsing courses, learning, and taking quizzes',
        permissions: [
          'courses:read_published',
          'enrollments:create',
          'quizzes:attempt',
        ],
        isSystem: true,
      },
    ];

    for (const def of defaultRoles) {
      const exists = await this.roleModel.findOne({ name: def.name });
      if (!exists) {
        await this.roleModel.create(def);
        this.logger.log(`Seeded default role: ${def.name}`);
      }
    }
  }

  async findAll(): Promise<Role[]> {
    return this.roleModel.find({ isActive: true }).exec();
  }

  async findByName(name: string): Promise<RoleDocument> {
    const role = await this.roleModel.findOne({ name: name.toUpperCase(), isActive: true }).exec();
    if (!role) {
      throw new NotFoundException(`Role '${name}' not found`);
    }
    return role;
  }

  async getPermissionsForRole(roleName: string): Promise<string[]> {
    const cacheKey = `rbac:role:${roleName.toUpperCase()}:perms`;
    const cached = await this.redisService.get<string[]>(cacheKey);
    if (cached) return cached;

    const role = await this.roleModel.findOne({ name: roleName.toUpperCase(), isActive: true }).exec();
    if (!role) return [];

    await this.redisService.set(cacheKey, role.permissions, 3600); // 1 hour cache
    return role.permissions;
  }

  async create(createRoleDto: CreateRoleDto): Promise<Role> {
    const upperName = createRoleDto.name.toUpperCase();
    const exists = await this.roleModel.findOne({ name: upperName });
    if (exists) {
      throw new BadRequestException(`Role with name '${upperName}' already exists`);
    }

    const created = await this.roleModel.create({
      ...createRoleDto,
      name: upperName,
      isSystem: false,
    });

    return created;
  }

  async update(id: string, updateRoleDto: UpdateRoleDto): Promise<Role> {
    const role = await this.roleModel.findById(id);
    if (!role) {
      throw new NotFoundException(`Role not found`);
    }

    if (updateRoleDto.displayName) role.displayName = updateRoleDto.displayName;
    if (updateRoleDto.description !== undefined) role.description = updateRoleDto.description;
    if (updateRoleDto.permissions) role.permissions = updateRoleDto.permissions;

    const updated = await role.save();

    // Invalidate Redis cache
    await this.redisService.del(`rbac:role:${role.name}:perms`);

    return updated;
  }

  async delete(id: string): Promise<{ success: boolean; message: string }> {
    const role = await this.roleModel.findById(id);
    if (!role) {
      throw new NotFoundException(`Role not found`);
    }
    if (role.isSystem) {
      throw new BadRequestException(`Cannot delete system-defined role '${role.name}'`);
    }

    role.isActive = false;
    await role.save();

    await this.redisService.del(`rbac:role:${role.name}:perms`);

    return { success: true, message: `Role ${role.name} has been archived` };
  }

  getAvailablePermissions() {
    return PLATFORM_PERMISSIONS;
  }
}

