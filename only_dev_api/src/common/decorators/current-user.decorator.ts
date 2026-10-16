import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export class CurrentUserPayload {
  userId: string;
  email: string;
  role: string;
  permissions?: string[];
  customPermissions?: string[];
}

export const CurrentUser = createParamDecorator(
  (data: keyof CurrentUserPayload | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as CurrentUserPayload;
    return data ? user?.[data] : user;
  },
);
