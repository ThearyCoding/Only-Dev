import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { PresignRequestDto } from '../dto/presign.dto.js';
import crypto from 'crypto';

@Injectable()
export class StorageService implements OnModuleInit {
  private readonly logger = new Logger(StorageService.name);
  private s3Client: S3Client;
  private bucketName: string;
  private publicBaseUrl: string;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    const accountId = this.configService.get<string>('R2_ACCOUNT_ID', 'dummy_account');
    const accessKeyId = this.configService.get<string>('R2_ACCESS_KEY_ID', 'dummy_key');
    const secretAccessKey = this.configService.get<string>('R2_SECRET_ACCESS_KEY', 'dummy_secret');

    this.bucketName = this.configService.get<string>('R2_BUCKET_NAME', 'elearning-media');
    this.publicBaseUrl = this.configService.get<string>(
      'R2_PUBLIC_URL',
      'https://media.yourdomain.com',
    );

    this.s3Client = new S3Client({
      region: 'auto',
      endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });

    this.logger.log(`Initialized Cloudflare R2 client for bucket '${this.bucketName}'`);
  }

  async generatePresignedUploadUrl(
    userId: string,
    dto: PresignRequestDto,
  ): Promise<{ uploadUrl: string; publicUrl: string; r2Key: string; expiresInSeconds: number }> {
    const extension = dto.fileName.includes('.')
      ? dto.fileName.substring(dto.fileName.lastIndexOf('.'))
      : '';
    const randomHex = crypto.randomBytes(8).toString('hex');
    const cleanName = dto.fileName
      .replace(extension, '')
      .replace(/[^a-zA-Z0-9-_]/g, '_');

    // Structured storage key: e.g. "videos/user_123/1697460000000-a1b2c3d4-flutter_intro.mp4"
    const r2Key = `${dto.folder}/user_${userId}/${Date.now()}-${randomHex}-${cleanName}${extension}`;

    const command = new PutObjectCommand({
      Bucket: this.bucketName,
      Key: r2Key,
      ContentType: dto.contentType,
    });

    const expiresInSeconds = 900; // 15 minutes
    const uploadUrl = await getSignedUrl(this.s3Client, command, {
      expiresIn: expiresInSeconds,
    });

    const publicUrl = `${this.publicBaseUrl.replace(/\/$/, '')}/${r2Key}`;

    return {
      uploadUrl,
      publicUrl,
      r2Key,
      expiresInSeconds,
    };
  }

  async deleteObject(r2Key: string): Promise<void> {
    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: r2Key,
      });
      await this.s3Client.send(command);
    } catch (err: any) {
      this.logger.warn(`Failed to delete R2 object '${r2Key}': ${err.message}`);
    }
  }
}

