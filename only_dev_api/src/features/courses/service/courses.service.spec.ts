import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';
import mongoose from 'mongoose';
import { CoursesService } from './courses.service.js';
import { Course } from '../schemas/course.schema.js';
import { Section } from '../schemas/section.schema.js';
import { Enrollment } from '../../enrollments/schemas/enrollment.schema.js';
import { RedisService } from '../../../common/redis/redis.service.js';

describe('CoursesService - findById with Enrollment Check', () => {
  let service: CoursesService;
  let mockCourseModel: any;
  let mockSectionModel: any;
  let mockEnrollmentModel: any;
  let mockRedisService: any;

  const validCourseId = new mongoose.Types.ObjectId().toString();
  const validUserId = new mongoose.Types.ObjectId().toString();
  const validEnrollmentId = new mongoose.Types.ObjectId().toString();

  const sampleCourse = {
    _id: validCourseId,
    title: 'Flutter & NestJS Masterclass',
    price: 0,
    status: 'published',
  };

  beforeEach(async () => {
    mockCourseModel = {
      findById: vi.fn(),
      find: vi.fn(),
      findOne: vi.fn(),
    };

    mockSectionModel = {
      find: vi.fn(),
    };

    mockEnrollmentModel = {
      findOne: vi.fn(),
    };

    mockRedisService = {
      get: vi.fn(),
      set: vi.fn(),
      del: vi.fn(),
      delByPattern: vi.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CoursesService,
        {
          provide: getModelToken(Course.name),
          useValue: mockCourseModel,
        },
        {
          provide: getModelToken(Section.name),
          useValue: mockSectionModel,
        },
        {
          provide: getModelToken(Enrollment.name),
          useValue: mockEnrollmentModel,
        },
        {
          provide: RedisService,
          useValue: mockRedisService,
        },
      ],
    }).compile();

    service = module.get<CoursesService>(CoursesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findById', () => {
    it('should return course details with isEnrolled=false when no userId is passed', async () => {
      mockCourseModel.findById.mockReturnValue({
        populate: vi.fn().mockReturnValue({
          lean: vi.fn().mockReturnValue({
            exec: vi.fn().mockResolvedValue(sampleCourse),
          }),
        }),
      });

      mockSectionModel.find.mockReturnValue({
        sort: vi.fn().mockReturnValue({
          lean: vi.fn().mockReturnValue({
            exec: vi.fn().mockResolvedValue([]),
          }),
        }),
      });

      const result = await service.findById(validCourseId, true);

      expect(result).toBeDefined();
      expect(result.title).toBe('Flutter & NestJS Masterclass');
      expect(result.isEnrolled).toBe(false);
      expect(result.isRegistered).toBe(false);
      expect(result.enrollmentId).toBeUndefined();
      expect(mockEnrollmentModel.findOne).not.toHaveBeenCalled();
    });

    it('should return isEnrolled=true and enrollmentId when user has active enrollment', async () => {
      mockCourseModel.findById.mockReturnValue({
        populate: vi.fn().mockReturnValue({
          lean: vi.fn().mockReturnValue({
            exec: vi.fn().mockResolvedValue(sampleCourse),
          }),
        }),
      });

      mockSectionModel.find.mockReturnValue({
        sort: vi.fn().mockReturnValue({
          lean: vi.fn().mockReturnValue({
            exec: vi.fn().mockResolvedValue([]),
          }),
        }),
      });

      mockEnrollmentModel.findOne.mockReturnValue({
        lean: vi.fn().mockReturnValue({
          exec: vi.fn().mockResolvedValue({
            _id: validEnrollmentId,
            userId: validUserId,
            courseId: validCourseId,
            status: 'active',
            enrolledAt: new Date(),
          }),
        }),
      });

      const result = await service.findById(validCourseId, true, validUserId);

      expect(result).toBeDefined();
      expect(result.isEnrolled).toBe(true);
      expect(result.isRegistered).toBe(true);
      expect(result.enrollmentId).toBe(validEnrollmentId);
      expect(mockEnrollmentModel.findOne).toHaveBeenCalled();
    });

    it('should return isEnrolled=false when user is not enrolled', async () => {
      mockCourseModel.findById.mockReturnValue({
        populate: vi.fn().mockReturnValue({
          lean: vi.fn().mockReturnValue({
            exec: vi.fn().mockResolvedValue(sampleCourse),
          }),
        }),
      });

      mockSectionModel.find.mockReturnValue({
        sort: vi.fn().mockReturnValue({
          lean: vi.fn().mockReturnValue({
            exec: vi.fn().mockResolvedValue([]),
          }),
        }),
      });

      mockEnrollmentModel.findOne.mockReturnValue({
        lean: vi.fn().mockReturnValue({
          exec: vi.fn().mockResolvedValue(null),
        }),
      });

      const result = await service.findById(validCourseId, true, validUserId);

      expect(result).toBeDefined();
      expect(result.isEnrolled).toBe(false);
      expect(result.isRegistered).toBe(false);
      expect(result.enrollmentId).toBeUndefined();
    });

    it('should throw NotFoundException if course is not found', async () => {
      mockCourseModel.findById.mockReturnValue({
        populate: vi.fn().mockReturnValue({
          lean: vi.fn().mockReturnValue({
            exec: vi.fn().mockResolvedValue(null),
          }),
        }),
      });

      await expect(service.findById(validCourseId, true)).rejects.toThrow(NotFoundException);
    });
  });
});

