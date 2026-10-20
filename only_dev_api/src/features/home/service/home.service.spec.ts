import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { HomeService } from './home.service.js';
import { Banner } from '../schemas/banner.schema.js';
import { Category } from '../schemas/category.schema.js';
import { Course } from '../../courses/schemas/course.schema.js';
import { RedisService } from '../../../common/redis/redis.service.js';

describe('HomeService', () => {
  let service: HomeService;
  let mockBannerModel: any;
  let mockCategoryModel: any;
  let mockCourseModel: any;
  let mockRedisService: any;

  beforeEach(async () => {
    const createMockQuery = (data: any[]) => ({
      sort: vi.fn().mockReturnThis(),
      limit: vi.fn().mockReturnThis(),
      populate: vi.fn().mockReturnThis(),
      lean: vi.fn().mockReturnThis(),
      exec: vi.fn().mockResolvedValue(data),
    });

    mockBannerModel = {
      find: vi.fn().mockReturnValue(createMockQuery([{ _id: 'b1', imageUrl: 'https://banner1.jpg' }])),
    };

    mockCategoryModel = {
      find: vi.fn().mockReturnValue(createMockQuery([{ _id: 'c1', title: 'Flutter' }])),
    };

    mockCourseModel = {
      find: vi.fn().mockReturnValue(createMockQuery([{ _id: 'course1', title: 'Flutter Deep Dive' }])),
    };

    mockRedisService = {
      get: vi.fn().mockResolvedValue(null),
      set: vi.fn().mockResolvedValue('OK'),
      del: vi.fn().mockResolvedValue(1),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        HomeService,
        {
          provide: getModelToken(Banner.name),
          useValue: mockBannerModel,
        },
        {
          provide: getModelToken(Category.name),
          useValue: mockCategoryModel,
        },
        {
          provide: getModelToken(Course.name),
          useValue: mockCourseModel,
        },
        {
          provide: RedisService,
          useValue: mockRedisService,
        },
      ],
    }).compile();

    service = module.get<HomeService>(HomeService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getHomeScreenData', () => {
    it('should return cached data if available in Redis', async () => {
      const cachedData = {
        banners: [{ id: 'b_cached' }],
        categories: [],
        courses: [],
        recentCourses: [],
        popularCourses: [],
      };
      mockRedisService.get.mockResolvedValueOnce(cachedData);

      const result = await service.getHomeScreenData();

      expect(result).toEqual(cachedData);
      expect(mockRedisService.get).toHaveBeenCalledWith('screen:home');
      expect(mockBannerModel.find).not.toHaveBeenCalled();
    });

    it('should aggregate data from models and cache when no cache exists', async () => {
      const result = await service.getHomeScreenData();

      expect(result).toHaveProperty('banners');
      expect(result).toHaveProperty('categories');
      expect(result).toHaveProperty('courses');
      expect(result).toHaveProperty('recentCourses');
      expect(result).toHaveProperty('popularCourses');

      expect(mockBannerModel.find).toHaveBeenCalledWith({ isActive: true });
      expect(mockCategoryModel.find).toHaveBeenCalledWith({ isActive: true });
      expect(mockRedisService.set).toHaveBeenCalledWith('screen:home', expect.any(Object), 300);
    });
  });

  describe('invalidateHomeCache', () => {
    it('should delete screen:home cache from Redis', async () => {
      await service.invalidateHomeCache();
      expect(mockRedisService.del).toHaveBeenCalledWith('screen:home');
    });
  });
});

