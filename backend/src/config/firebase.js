import admin from 'firebase-admin';
import { ENV } from './env.js';
import { logger } from '../utils/logger.js';

let firebaseApp = null;

if (ENV.FIREBASE.isConfigured()) {
  try {
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: ENV.FIREBASE.PROJECT_ID,
        clientEmail: ENV.FIREBASE.CLIENT_EMAIL,
        privateKey: ENV.FIREBASE.PRIVATE_KEY
      })
    });
    logger.info('Firebase Admin SDK initialized for FCM push notifications');
  } catch (err) {
    logger.error(`Firebase Admin initialization error: ${err.message}`);
  }
} else {
  logger.warn('Firebase FCM credentials not configured. Simulated push notification mode active');
}

export default firebaseApp;
