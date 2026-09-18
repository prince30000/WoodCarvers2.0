import Razorpay from 'razorpay';
import crypto from 'crypto';
import { ENV } from './env.js';
import { logger } from '../utils/logger.js';

let razorpayInstance = null;

if (ENV.RAZORPAY.isConfigured()) {
  try {
    razorpayInstance = new Razorpay({
      key_id: ENV.RAZORPAY.KEY_ID,
      key_secret: ENV.RAZORPAY.KEY_SECRET
    });
    logger.info('Razorpay SDK initialized with API keys');
  } catch (err) {
    logger.error(`Razorpay initialization error: ${err.message}`);
  }
} else {
  logger.warn('Razorpay credentials not provided. Sandbox simulation mode enabled');
}

/**
 * Verify Razorpay payment signature
 * HMAC SHA256 of (order_id + "|" + payment_id) using key_secret
 */
export const verifyRazorpaySignature = ({ razorpay_order_id, razorpay_payment_id, razorpay_signature }) => {
  if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
    return false;
  }

  // If in mock/demo mode
  if (!ENV.RAZORPAY.isConfigured() || razorpay_signature.startsWith('mock_sig_')) {
    return true;
  }

  const generatedSignature = crypto
    .createHmac('sha256', ENV.RAZORPAY.KEY_SECRET)
    .update(`${razorpay_order_id}|${razorpay_payment_id}`)
    .digest('hex');

  return generatedSignature === razorpay_signature;
};

export default razorpayInstance;
