import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Banner, BannerSchema } from './schemas/banner.schema.js';
import { Category, CategorySchema } from './schemas/category.schema.js';
import { CoursesModule } from '../courses/courses.module.js';
import { HomeService } from './service/home.service.js';
import { HomeController } from './controller/home.controller.js';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Banner.name, schema: BannerSchema },
      { name: Category.name, schema: CategorySchema },
    ]),
    CoursesModule,
  ],
  controllers: [HomeController],
  providers: [HomeService],
  exports: [HomeService],
})
export class HomeModule {}

