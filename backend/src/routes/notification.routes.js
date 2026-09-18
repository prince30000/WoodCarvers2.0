import express from 'express';
import { getMyNotifications, markNotificationRead } from '../controllers/notification.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

const router = express.Router();

router.use(authenticate);

router.get('/', getMyNotifications);
router.put('/:id/read', markNotificationRead);

export default router;
