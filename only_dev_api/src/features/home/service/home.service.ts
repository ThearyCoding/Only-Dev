import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Banner, BannerDocument } from '../schemas/banner.schema.js';
import { Category, CategoryDocument } from '../schemas/category.schema.js';
import { Course, CourseDocument } from '../../courses/schemas/course.schema.js';
import { RedisService } from '../../../common/redis/redis.service.js';

export interface HomeScreenResponse {
  banners: any[];
  categories: any[];
  courses: any[];
  recentCourses: any[];
  popularCourses: any[];
}

@Injectable()
export class HomeService {
  constructor(
    @InjectModel(Banner.name) private readonly bannerModel: Model<BannerDocument>,
    @InjectModel(Category.name) private readonly categoryModel: Model<CategoryDocument>,
    @InjectModel(Course.name) private readonly courseModel: Model<CourseDocument>,
    private readonly redisService: RedisService,
  ) {}

  /**
   * Aggregates all data needed for the Home Screen into a single response payload.
   * Prevents mobile client from making multiple scattered HTTP calls.
   */
  async getHomeScreenData(): Promise<HomeScreenResponse> {
    const cacheKey = 'screen:home';
    const cached = await this.redisService.get<HomeScreenResponse>(cacheKey);
    if (cached) {
      return cached;
    }

    const [banners, categories, courses, recentCourses, popularCourses] =
      await Promise.all([
        this.bannerModel
          .find({ isActive: true })
          .sort({ order: 1, createdAt: -1 })
          .lean()
          .exec(),
        this.categoryModel
          .find({ isActive: true })
          .sort({ order: 1, createdAt: -1 })
          .lean()
          .exec(),
        this.courseModel
          .find({ status: 'published' })
          .populate('instructorId', 'fullName avatarUrl headline')
          .sort({ createdAt: -1 })
          .limit(10)
          .lean()
          .exec(),
        this.courseModel
          .find({ status: 'published' })
          .populate('instructorId', 'fullName avatarUrl headline')
          .sort({ createdAt: -1 })
          .limit(10)
          .lean()
          .exec(),
        this.courseModel
          .find({ status: 'published' })
          .populate('instructorId', 'fullName avatarUrl headline')
          .sort({ enrollmentCounts: -1, ratingAvg: -1 })
          .limit(10)
          .lean()
          .exec(),
      ]);

    const result: HomeScreenResponse = {
      banners,
      categories,
      courses,
      recentCourses,
      popularCourses,
    };

    // Cache home screen composite response for 5 minutes (300s)
    await this.redisService.set(cacheKey, result, 300);

    return result;
  }

  async invalidateHomeCache(): Promise<void> {
    await this.redisService.del('screen:home');
  }
}

