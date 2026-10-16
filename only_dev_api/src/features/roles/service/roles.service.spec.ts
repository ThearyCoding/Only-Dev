import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { RolesService } from './roles.service.js';
import { Role } from '../schemas/role.schema.js';
import { RedisService } from '../../../common/redis/redis.service.js';

describe('RolesService', () => {
  let service: RolesService;
  let mockRoleModel: any;
  let mockRedisService: any;

  beforeEach(async () => {
    mockRoleModel = {
      findOne: vi.fn(),
      find: vi.fn(),
      findById: vi.fn(),
      create: vi.fn(),
    };

    mockRedisService = {
      get: vi.fn(),
      set: vi.fn(),
      del: vi.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RolesService,
        {
          provide: getModelToken(Role.name),
          useValue: mockRoleModel,
        },
        {
          provide: RedisService,
          useValue: mockRedisService,
        },
      ],
    }).compile();

    service = module.get<RolesService>(RolesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getAvailablePermissions', () => {
    it('should return the platform permissions catalog', () => {
      const permissions = service.getAvailablePermissions();
      expect(Array.isArray(permissions)).toBe(true);
      expect(permissions.length).toBeGreaterThan(0);
      expect(permissions[0]).toHaveProperty('category');
      expect(permissions[0]).toHaveProperty('key');
      expect(permissions[0]).toHaveProperty('name');
    });
  });

  describe('create', () => {
    it('should throw BadRequestException if role already exists', async () => {
      mockRoleModel.findOne.mockResolvedValue({ name: 'TEST_ROLE' });

      await expect(
        service.create({
          name: 'test_role',
          displayName: 'Test Role',
          permissions: ['course:read'],
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should create and return a new role', async () => {
      mockRoleModel.findOne.mockResolvedValue(null);
      const newRole = {
        name: 'CUSTOM_ROLE',
        displayName: 'Custom Role',
        permissions: ['course:read'],
        isSystem: false,
      };
      mockRoleModel.create.mockResolvedValue(newRole);

      const result = await service.create({
        name: 'custom_role',
        displayName: 'Custom Role',
        permissions: ['course:read'],
      });

      expect(result.name).toBe('CUSTOM_ROLE');
      expect(mockRoleModel.create).toHaveBeenCalled();
    });
  });

  describe('delete', () => {
    it('should throw NotFoundException if role not found', async () => {
      mockRoleModel.findById.mockResolvedValue(null);

      await expect(service.delete('nonexistent_id')).rejects.toThrow(NotFoundException);
    });

    it('should throw BadRequestException if trying to delete a system role', async () => {
      mockRoleModel.findById.mockResolvedValue({
        name: 'ADMIN',
        isSystem: true,
      });

      await expect(service.delete('admin_id')).rejects.toThrow(BadRequestException);
    });

    it('should archive a non-system role and invalidate Redis cache', async () => {
      const mockRole = {
        name: 'CUSTOM_ROLE',
        isSystem: false,
        isActive: true,
        save: vi.fn().mockResolvedValue(true),
      };
      mockRoleModel.findById.mockResolvedValue(mockRole);

      const result = await service.delete('custom_id');
      expect(mockRole.isActive).toBe(false);
      expect(mockRole.save).toHaveBeenCalled();
      expect(mockRedisService.del).toHaveBeenCalledWith('rbac:role:CUSTOM_ROLE:perms');
      expect(result.success).toBe(true);
    });
  });
});
