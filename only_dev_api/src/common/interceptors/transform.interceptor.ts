import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface ApiResponse<T> {
  success: boolean;
  status_code: number;
  data: T;
  timestamp: string;
}

function toSnakeCase(str: string): string {
  const prefix = str.startsWith('_') ? '_' : '';
  const cleanStr = str.replace(/^_+/, '');
  return prefix + cleanStr.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`);
}

export function keysToSnakeCase(obj: any): any {
  if (obj === null || obj === undefined) return obj;
  if (obj instanceof Date) return obj;
  if (Array.isArray(obj)) {
    return obj.map(keysToSnakeCase);
  }
  if (typeof obj === 'object') {
    if (typeof obj.toObject === 'function') {
      return keysToSnakeCase(obj.toObject());
    }
    if (typeof obj.toJSON === 'function') {
      return keysToSnakeCase(obj.toJSON());
    }
    if (obj.constructor === Object) {
      const newObj: Record<string, any> = {};
      for (const key of Object.keys(obj)) {
        newObj[toSnakeCase(key)] = keysToSnakeCase(obj[key]);
      }
      return newObj;
    }
  }
  return obj;
}

@Injectable()
export class TransformInterceptor<T>
  implements NestInterceptor<T, ApiResponse<T>>
{
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<ApiResponse<T>> {
    const ctx = context.switchToHttp();
    const response = ctx.getResponse();
    const statusCode = response.statusCode;

    return next.handle().pipe(
      map((data) => ({
        success: true,
        status_code: statusCode,
        data: keysToSnakeCase(data),
        timestamp: new Date().toISOString(),
      })),
    );
  }
}

