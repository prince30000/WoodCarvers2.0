import admin from 'firebase-admin';
import firebaseApp from '../config/firebase.js';
import Notification from '../models/Notification.js';
import User from '../models/User.js';
import { logger } from '../utils/logger.js';
import { ENV } from '../config/env.js';

export const sendUserNotification = async ({ userId, title, body, type = 'ORDER_STATUS', data = {} }) => {
  try {
    // 1. Create in-app notification record
    const notification = await Notification.create({
      user: userId,
      title,
      body,
      type,
      data: {
        orderId: data.orderId || '',
        url: data.url || ''
      }
    });

    // 2. Dispatch Push Notification if FCM is initialized and user has device tokens
    const user = await User.findById(userId).select('fcmTokens email name');
    if (!user) return notification;

    const tokens = (user.fcmTokens || []).map(t => t.token).filter(Boolean);

    if (tokens.length > 0 && ENV.FIREBASE.isConfigured() && firebaseApp) {
      const messagePayload = {
        notification: {
          title,
          body
        },
        data: {
          type,
          ...data
        },
        tokens
      };

      const response = await admin.messaging().sendEachForMulticast(messagePayload);
      logger.info(`FCM multicast dispatched: ${response.successCount} succeeded, ${response.failureCount} failed.`);
    } else {
      logger.info(`Simulated Push Notification to ${user.email}: [${title}] - ${body}`);
    }

    return notification;
  } catch (error) {
    logger.error('Error sending notification:', error);
    // Notification error shouldn't crash caller transaction
    return null;
  }
};

export const broadcastNotification = async ({ title, body, type = 'PROMOTION', data = {} }) => {
  try {
    if (ENV.FIREBASE.isConfigured() && firebaseApp) {
      await admin.messaging().send({
        topic: 'all_users',
        notification: { title, body },
        data: { type, ...data }
      });
      logger.info(`Broadcast notification sent to topic 'all_users'`);
    } else {
      logger.info(`Simulated Broadcast Notification: [${title}] - ${body}`);
    }
  } catch (error) {
    logger.error('Broadcast notification error:', error);
  }
};
