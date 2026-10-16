import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator.js';
import { PERMISSIONS_KEY } from '../decorators/permissions.decorator.js';
import { RolesService } from '../../features/roles/service/roles.service.js';

@Injectable()
export class DynamicRbacGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private readonly rolesService: RolesService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    const requiredPermissions = this.reflector.getAllAndOverride<string[]>(PERMISSIONS_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // If endpoint has neither role nor permission constraint, allow
    if ((!requiredRoles || requiredRoles.length === 0) && (!requiredPermissions || requiredPermissions.length === 0)) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || !user.role) {
      throw new ForbiddenException('Access denied. No authenticated user role found.');
    }

    // 1. SUPER_ADMIN always has full unrestricted access
    if (user.role.toUpperCase() === 'SUPER_ADMIN') {
      return true;
    }

    // 2. Fetch dynamic role permissions from DB / Redis cache
    const rolePermissions = await this.rolesService.getPermissionsForRole(user.role);
    const customPermissions = user.customPermissions || [];

    // Effective permissions = role permissions + user-specific override permissions
    const effectivePermissions = new Set<string>([...rolePermissions, ...customPermissions]);

    // Wildcard permission check
    if (effectivePermissions.has('*')) {
      return true;
    }

    // 3. Evaluate Role requirement if specified
    if (requiredRoles && requiredRoles.length > 0) {
      const matchRole = requiredRoles.map((r) => r.toUpperCase()).includes(user.role.toUpperCase());
      if (!matchRole) {
        throw new ForbiddenException(
          `Access denied. Requires one of roles: [${requiredRoles.join(', ')}]. Your current role is '${user.role}'`,
        );
      }
    }

    // 4. Evaluate Granular Permissions requirement if specified
    if (requiredPermissions && requiredPermissions.length > 0) {
      const missingPermissions = requiredPermissions.filter(
        (perm) => !effectivePermissions.has(perm),
      );

      if (missingPermissions.length > 0) {
        throw new ForbiddenException(
          `Access denied. Missing required permission(s): [${missingPermissions.join(', ')}]`,
        );
      }
    }

    return true;
  }
}

