import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { RedisModule } from './common/redis/redis.module.js';
import { RolesModule } from './features/roles/roles.module.js';
import { UsersModule } from './features/users/users.module.js';
import { AuthModule } from './features/auth/auth.module.js';
import { CoursesModule } from './features/courses/courses.module.js';
import { EnrollmentsModule } from './features/enrollments/enrollments.module.js';
import { QuizzesModule } from './features/quizzes/quizzes.module.js';
import { StorageModule } from './features/storage/storage.module.js';
import { HomeModule } from './features/home/home.module.js';
import { SeedModule } from './seed/seed.module.js';
import { AppController } from './app.controller.js';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // MongoDB connection via Mongoose
    MongooseModule.forRootAsync({
      imports: ConfigModule ? [ConfigModule] : [],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        uri: configService.get<string>(
          'MONGODB_URI',
          'mongodb://localhost:27017/e_learning_db',
        ),
      }),
    }),

    // Global Redis caching & token blacklist
    RedisModule,

    // Feature Modules
    RolesModule,
    UsersModule,
    AuthModule,
    CoursesModule,
    EnrollmentsModule,
    QuizzesModule,
    StorageModule,
    HomeModule,
    SeedModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
