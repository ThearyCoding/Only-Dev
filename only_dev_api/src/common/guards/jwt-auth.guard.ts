import { Injectable, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator.js';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      const request = context.switchToHttp().getRequest();
      const authHeader = request.headers?.authorization;
      if (authHeader && typeof authHeader === 'string' && authHeader.startsWith('Bearer ')) {
        try {
          await (super.canActivate(context) as Promise<boolean>);
        } catch {
          // Token invalid or expired: gracefully treat as unauthenticated guest
        }
      }
      return true;
    }

    return super.canActivate(context) as Promise<boolean>;
  }

  handleRequest(err: any, user: any, info: any, context?: ExecutionContext) {
    if (context) {
      const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
        context.getHandler(),
        context.getClass(),
      ]);
      if (isPublic) {
        if (err || !user) {
          return null;
        }
        return user;
      }
    }

    if (err || !user) {
      throw err || new UnauthorizedException('Authentication required. Missing or invalid Bearer token.');
    }
    return user;
  }
}

