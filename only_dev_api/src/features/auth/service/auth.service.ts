import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import bcrypt from 'bcryptjs';
import { UsersService } from '../../users/service/users.service.js';
import { RegisterDto, LoginDto, RefreshTokenDto, SocialAuthDto } from '../dto/auth.dto.js';
import { UserDocument } from '../../users/schemas/user.schema.js';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.usersService.findByEmail(dto.email);
    if (existing) {
      throw new ConflictException('An account with this email already exists');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(dto.password, salt);

    // If this is the very first user on the platform, grant SUPER_ADMIN
    const totalUsers = await this.usersService.findAll({ limit: 1 });
    const initialRole = totalUsers.total === 0 ? 'SUPER_ADMIN' : 'STUDENT';

    const user = await this.usersService.create({
      email: dto.email,
      passwordHash,
      fullName: dto.fullName,
      headline: dto.headline || '',
      role: initialRole,
      customPermissions: [],
      authProviders: [{ provider: 'local' }],
    });

    const tokens = await this.generateTokens(user);

    return {
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        customPermissions: user.customPermissions,
        avatarUrl: user.avatarUrl,
      },
      ...tokens,
    };
  }

  async login(dto: LoginDto) {
    const user = await this.usersService.findByEmail(dto.email, true);
    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid email or password');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('This account has been suspended. Please contact support.');
    }

    const isMatch = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('Invalid email or password');
    }

    user.lastLoginAt = new Date();
    await user.save();

    const tokens = await this.generateTokens(user);

    return {
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        customPermissions: user.customPermissions,
        avatarUrl: user.avatarUrl,
        headline: user.headline,
      },
      ...tokens,
    };
  }

  async socialAuth(dto: SocialAuthDto) {
    let user = await this.usersService.findByEmail(dto.email);

    if (!user) {
      // Create user with social provider
      user = await this.usersService.create({
        email: dto.email,
        fullName: dto.fullName,
        avatarUrl: dto.avatarUrl || '',
        role: 'STUDENT',
        authProviders: [{ provider: dto.provider, providerId: dto.idToken }],
        isEmailVerified: true,
      });
    } else {
      // Link provider if not present
      const hasProvider = user.authProviders?.some((p) => p.provider === dto.provider);
      if (!hasProvider) {
        user.authProviders.push({ provider: dto.provider, providerId: dto.idToken });
        await user.save();
      }
    }

    user.lastLoginAt = new Date();
    await user.save();

    const tokens = await this.generateTokens(user);

    return {
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        customPermissions: user.customPermissions,
        avatarUrl: user.avatarUrl,
      },
      ...tokens,
    };
  }

  async refreshTokens(dto: RefreshTokenDto) {
    try {
      const refreshSecret = this.configService.get<string>(
        'JWT_REFRESH_SECRET',
        'super_secret_jwt_refresh_key_2026',
      );

      const decoded = await this.jwtService.verifyAsync(dto.refreshToken, {
        secret: refreshSecret,
      });

      const user = await this.usersService.findById(decoded.sub);
      if (!user || !user.isActive) {
        throw new UnauthorizedException('User account no longer active');
      }

      return this.generateTokens(user);
    } catch (err: any) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }

  private async generateTokens(user: UserDocument) {
    const payload = {
      sub: user._id.toString(),
      email: user.email,
      role: user.role,
      customPermissions: user.customPermissions || [],
    };

    const accessSecret = this.configService.get<string>(
      'JWT_SECRET',
      'super_secret_jwt_key_2026',
    );
    const accessExpiresIn = this.configService.get<string>('JWT_EXPIRES_IN', '1d');

    const refreshSecret = this.configService.get<string>(
      'JWT_REFRESH_SECRET',
      'super_secret_jwt_refresh_key_2026',
    );
    const refreshExpiresIn = this.configService.get<string>('JWT_REFRESH_EXPIRES_IN', '7d');

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: accessSecret,
        expiresIn: accessExpiresIn as any,
      }),
      this.jwtService.signAsync(payload, {
        secret: refreshSecret,
        expiresIn: refreshExpiresIn as any,
      }),
    ]);

    return {
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      expiresIn: accessExpiresIn,
    };
  }
}

