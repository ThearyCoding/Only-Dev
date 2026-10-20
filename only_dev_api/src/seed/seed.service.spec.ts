import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { SeedService } from './seed.service.js';
import { User } from '../features/users/schemas/user.schema.js';
import { Role } from '../features/roles/schemas/role.schema.js';
import { Category } from '../features/home/schemas/category.schema.js';
import { Banner } from '../features/home/schemas/banner.schema.js';
import { Course } from '../features/courses/schemas/course.schema.js';
import { Section } from '../features/courses/schemas/section.schema.js';
import { Quiz } from '../features/quizzes/schemas/quiz.schema.js';
import { Enrollment } from '../features/enrollments/schemas/enrollment.schema.js';
import { UserCourseProgress } from '../features/enrollments/schemas/progress.schema.js';
import { RolesService } from '../features/roles/service/roles.service.js';
import { RedisService } from '../common/redis/redis.service.js';
import { REAL_VIDEOS, SEED_COURSES, SEED_CATEGORIES } from './seed.data.js';

describe('SeedService & SeedData', () => {
  let service: SeedService;

  beforeEach(async () => {
    const findQuery: any = Promise.resolve([]);
    findQuery.sort = vi.fn().mockResolvedValue([]);
    const mockModel = {
      findOne: vi.fn(),
      find: vi.fn().mockReturnValue(findQuery),
      findOneAndUpdate: vi.fn(),
      deleteMany: vi.fn().mockResolvedValue({ deletedCount: 0 }),
      create: vi.fn().mockImplementation((doc) => ({ ...doc, _id: 'mock_id' })),
      countDocuments: vi.fn().mockResolvedValue(5),
    };

    const mockRolesService = {
      seedDefaultRoles: vi.fn().mockResolvedValue(undefined),
    };

    const mockRedisService = {
      get: vi.fn(),
      set: vi.fn(),
      del: vi.fn(),
      delByPattern: vi.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SeedService,
        { provide: getModelToken(User.name), useValue: mockModel },
        { provide: getModelToken(Role.name), useValue: mockModel },
        { provide: getModelToken(Category.name), useValue: mockModel },
        { provide: getModelToken(Banner.name), useValue: mockModel },
        { provide: getModelToken(Course.name), useValue: mockModel },
        { provide: getModelToken(Section.name), useValue: mockModel },
        { provide: getModelToken(Quiz.name), useValue: mockModel },
        { provide: getModelToken(Enrollment.name), useValue: mockModel },
        { provide: getModelToken(UserCourseProgress.name), useValue: mockModel },
        { provide: RolesService, useValue: mockRolesService },
        { provide: RedisService, useValue: mockRedisService },
      ],
    }).compile();

    service = module.get<SeedService>(SeedService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('Real Video Data Verification', () => {
    it('should have valid streaming video sources with positive duration', () => {
      expect(REAL_VIDEOS).toBeDefined();
      expect(REAL_VIDEOS.oceans.rawUrl).toMatch(/^https:\/\/.+\.mp4$/);
      expect(REAL_VIDEOS.oceans.durationSeconds).toBeGreaterThan(0);
      expect(REAL_VIDEOS.sintel.rawUrl).toMatch(/^https:\/\/.+\.mp4$/);
      expect(REAL_VIDEOS.surf720p.rawUrl).toMatch(/^https:\/\/.+\.mp4$/);
      expect(REAL_VIDEOS.muxHls.hlsUrl).toMatch(/^https:\/\/.+\.m3u8$/);
    });

    it('should have courses with sections and real video lessons', () => {
      expect(SEED_COURSES.length).toBeGreaterThanOrEqual(4);
      for (const course of SEED_COURSES) {
        expect(course.title).toBeTruthy();
        expect(course.slug).toBeTruthy();
        expect(course.thumbnailUrl).toMatch(/^https:\/\//);
        expect(course.sections.length).toBeGreaterThan(0);

        for (const section of course.sections) {
          expect(section.lessons.length).toBeGreaterThan(0);
          for (const lesson of section.lessons) {
            expect(lesson.title).toBeTruthy();
            expect(lesson.videoUrl).toMatch(/^https:\/\//);
            expect(lesson.durationSeconds).toBeGreaterThan(0);
          }
        }
      }
    });

    it('should have categories with valid slugs and image URLs', () => {
      expect(SEED_CATEGORIES.length).toBeGreaterThanOrEqual(5);
      for (const cat of SEED_CATEGORIES) {
        expect(cat.title).toBeTruthy();
        expect(cat.slug).toBeTruthy();
        expect(cat.imageUrl).toMatch(/^https:\/\//);
        expect(cat.blurHash).toBeTruthy();
      }
    });
  });

  describe('runSeed', () => {
    it('should run seed routine and return counts and sample accounts', async () => {
      const result = await service.runSeed();
      expect(result.success).toBe(true);
      expect(result.counts).toBeDefined();
      expect(result.sampleAccounts).toBeDefined();
      expect(result.sampleAccounts.admin.email).toBe('admin@onlydev.com');
      expect(result.sampleAccounts.instructor.email).toBe('angela@onlydev.com');
      expect(result.sampleAccounts.student.email).toBe('student@onlydev.com');
    });
  });
});
