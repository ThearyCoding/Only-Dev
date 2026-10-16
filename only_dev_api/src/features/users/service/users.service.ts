import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from '../schemas/user.schema.js';
import { UpdateProfileDto, UpdateUserRoleDto, UpdateUserPermissionsDto } from '../dto/user.dto.js';
import { RolesService } from '../../roles/service/roles.service.js';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    private readonly rolesService: RolesService,
  ) {}

  async findById(id: string): Promise<UserDocument> {
    const user = await this.userModel.findById(id).select('-passwordHash').exec();
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async findByEmail(email: string, includePassword = false): Promise<UserDocument | null> {
    const query = this.userModel.findOne({ email: email.toLowerCase() });
    if (!includePassword) {
      query.select('-passwordHash');
    }
    return query.exec();
  }

  async create(data: Partial<User>): Promise<UserDocument> {
    const upperRole = (data.role || 'STUDENT').toUpperCase();

    // Verify role exists
    await this.rolesService.findByName(upperRole);

    const user = new this.userModel({
      ...data,
      role: upperRole,
    });
    return user.save();
  }

  async updateProfile(userId: string, dto: UpdateProfileDto): Promise<UserDocument> {
    const user = await this.userModel.findById(userId);
    if (!user) throw new NotFoundException('User not found');

    if (dto.fullName) user.fullName = dto.fullName;
    if (dto.avatarUrl !== undefined) user.avatarUrl = dto.avatarUrl;
    if (dto.headline !== undefined) user.headline = dto.headline;
    if (dto.bio !== undefined) user.bio = dto.bio;
    if (dto.phoneNumber !== undefined) user.phoneNumber = dto.phoneNumber;
    if (dto.socialLinks) {
      user.socialLinks = {
        ...user.socialLinks,
        ...dto.socialLinks,
      };
    }

    await user.save();
    return this.findById(userId);
  }

  async updateUserRole(targetUserId: string, dto: UpdateUserRoleDto): Promise<UserDocument> {
    const upperRole = dto.role.toUpperCase();

    // Ensure the dynamic or system role exists in the database
    await this.rolesService.findByName(upperRole);

    const user = await this.userModel.findById(targetUserId);
    if (!user) throw new NotFoundException('User not found');

    user.role = upperRole;
    await user.save();

    return this.findById(targetUserId);
  }

  async updateCustomPermissions(
    targetUserId: string,
    dto: UpdateUserPermissionsDto,
  ): Promise<UserDocument> {
    const user = await this.userModel.findById(targetUserId);
    if (!user) throw new NotFoundException('User not found');

    user.customPermissions = dto.customPermissions;
    await user.save();

    return this.findById(targetUserId);
  }

  async findAll(query: {
    page?: number;
    limit?: number;
    role?: string;
    search?: string;
  }): Promise<{ users: UserDocument[]; total: number; page: number; totalPages: number }> {
    const page = Math.max(1, Number(query.page || 1));
    const limit = Math.max(1, Math.min(100, Number(query.limit || 20)));
    const filter: any = {};

    if (query.role) {
      filter.role = query.role.toUpperCase();
    }

    if (query.search) {
      const regex = new RegExp(query.search, 'i');
      filter.$or = [{ fullName: regex }, { email: regex }];
    }

    const [users, total] = await Promise.all([
      this.userModel
        .find(filter)
        .select('-passwordHash')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .exec(),
      this.userModel.countDocuments(filter),
    ]);

    return {
      users,
      total,
      page,
      totalPages: Math.ceil(total / limit),
    };
  }

  async setBanStatus(userId: string, isBanned: boolean): Promise<{ success: boolean; message: string }> {
    const user = await this.userModel.findById(userId);
    if (!user) throw new NotFoundException('User not found');

    user.isActive = !isBanned;
    await user.save();

    return {
      success: true,
      message: `User ${user.email} account has been ${isBanned ? 'suspended' : 'reactivated'}`,
    };
  }
}

