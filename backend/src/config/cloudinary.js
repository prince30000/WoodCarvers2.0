import { v2 as cloudinary } from 'cloudinary';
import { ENV } from './env.js';
import { logger } from '../utils/logger.js';

if (ENV.CLOUDINARY.isConfigured()) {
  cloudinary.config({
    cloud_name: ENV.CLOUDINARY.CLOUD_NAME,
    api_key: ENV.CLOUDINARY.API_KEY,
    api_secret: ENV.CLOUDINARY.API_SECRET,
    secure: true
  });
  logger.info('Cloudinary initialized with production credentials');
} else {
  logger.warn('Cloudinary not fully configured in .env. Mock/local media mode active');
}

export default cloudinary;
