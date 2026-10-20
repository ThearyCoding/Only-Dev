import { Controller, Post, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { SeedService, SeedResult } from './seed.service.js';
import { REAL_VIDEOS } from './seed.data.js';

@Controller('seed')
export class SeedController {
  constructor(private readonly seedService: SeedService) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  async seedDatabase(): Promise<SeedResult> {
    return this.seedService.runSeed();
  }

  @Get('videos')
  getTestVideos() {
    return {
      message: 'Verified public streaming MP4 and HLS test videos for mobile video players (BetterPlayer, ExoPlayer, AVPlayer)',
      videos: REAL_VIDEOS,
    };
  }
}

