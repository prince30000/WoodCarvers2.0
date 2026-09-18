import cloudinary from '../config/cloudinary.js';
import { ENV } from '../config/env.js';
import { logger } from '../utils/logger.js';

export const uploadImage = async (fileBuffer, folder = 'woodcarvers/products') => {
  if (!ENV.CLOUDINARY.isConfigured()) {
    // Return high quality simulation url
    const mockId = `mock_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    logger.info(`Cloudinary Mock: simulated upload for ${mockId}`);
    return {
      url: `https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80&mock=${mockId}`,
      publicId: `woodcarvers/mock/${mockId}`,
      format: 'jpg',
      bytes: fileBuffer ? fileBuffer.length : 1024
    };
  }

  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      {
        folder,
        resource_type: 'auto',
        transformation: [
          { quality: 'auto:good' },
          { fetch_format: 'auto' }
        ]
      },
      (error, result) => {
        if (error) {
          logger.error('Cloudinary upload stream error:', error);
          return reject(error);
        }
        resolve({
          url: result.secure_url,
          publicId: result.public_id,
          format: result.format,
          bytes: result.bytes
        });
      }
    );

    uploadStream.end(fileBuffer);
  });
};

export const deleteImage = async (publicId) => {
  if (!publicId || publicId.startsWith('woodcarvers/mock/') || !ENV.CLOUDINARY.isConfigured()) {
    logger.info(`Cloudinary: skipped delete for mock or unconfigured ${publicId}`);
    return { result: 'ok' };
  }

  try {
    const res = await cloudinary.uploader.destroy(publicId);
    return res;
  } catch (error) {
    logger.error(`Cloudinary delete error for ${publicId}:`, error);
    throw error;
  }
};
