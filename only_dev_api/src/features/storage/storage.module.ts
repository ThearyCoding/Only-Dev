import { Module } from '@nestjs/common';
import { StorageService } from './service/storage.service.js';
import { StorageController } from './controller/storage.controller.js';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [ConfigModule],
  controllers: [StorageController],
  providers: [StorageService],
  exports: [StorageService],
})
export class StorageModule {}

