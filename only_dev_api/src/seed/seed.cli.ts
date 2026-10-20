import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module.js';
import { SeedService } from './seed.service.js';

async function bootstrap() {
  console.log('🚀 Bootstrapping NestJS Seed Application Context...');
  try {
    const app = await NestFactory.createApplicationContext(AppModule, {
      logger: ['log', 'error', 'warn'],
    });

    const seedService = app.get(SeedService);
    const result = await seedService.runSeed();

    console.log('\n========================================');
    console.log('🎉 DATABASE SEEDING COMPLETED SUCCESSFULLY');
    console.log('========================================');
    console.log('Records Summary:');
    console.table(result.counts);

    console.log('\nSample Test Accounts (Password: password123):');
    console.table(result.sampleAccounts);

    await app.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Database seeding failed:', error);
    process.exit(1);
  }
}

bootstrap();

