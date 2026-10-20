import { Controller, Get, UseGuards } from '@nestjs/common';
import { HomeService, HomeScreenResponse } from '../service/home.service.js';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard.js';
import { DynamicRbacGuard } from '../../../common/guards/roles.guard.js';
import { Public } from '../../../common/decorators/public.decorator.js';

@Controller('home')
@UseGuards(JwtAuthGuard, DynamicRbacGuard)
export class HomeController {
  constructor(private readonly homeService: HomeService) {}

  @Public()
  @Get()
  async getHomeScreen(): Promise<HomeScreenResponse> {
    return this.homeService.getHomeScreenData();
  }

  // Alias route supporting GET /home/get-home
  @Public()
  @Get('get-home')
  async getHomeAlias(): Promise<HomeScreenResponse> {
    return this.homeService.getHomeScreenData();
  }
}

