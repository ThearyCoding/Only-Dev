import { Global, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Role, RoleSchema } from './schemas/role.schema.js';
import { RolesService } from './service/roles.service.js';
import { RolesController } from './controller/roles.controller.js';
import { DynamicRbacGuard } from '../../common/guards/roles.guard.js';

@Global()
@Module({
  imports: [
    MongooseModule.forFeature([{ name: Role.name, schema: RoleSchema }]),
  ],
  controllers: [RolesController],
  providers: [RolesService, DynamicRbacGuard],
  exports: [RolesService, DynamicRbacGuard],
})
export class RolesModule {}

