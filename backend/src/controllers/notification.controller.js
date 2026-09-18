import Notification from '../models/Notification.js';
import { successResponse } from '../utils/apiResponse.js';

export const getMyNotifications = async (req, res, next) => {
  try {
    const notifications = await Notification.find({ user: req.user._id })
      .sort({ createdAt: -1 })
      .limit(30);

    const unreadCount = await Notification.countDocuments({ user: req.user._id, isRead: false });

    return successResponse(res, 'Notifications fetched', {
      notifications,
      unreadCount
    });
  } catch (error) {
    next(error);
  }
};

export const markNotificationRead = async (req, res, next) => {
  try {
    const { id } = req.params;
    if (id === 'all') {
      await Notification.updateMany({ user: req.user._id, isRead: false }, { isRead: true });
    } else {
      await Notification.findOneAndUpdate({ _id: id, user: req.user._id }, { isRead: true });
    }
    return successResponse(res, 'Notification marked as read');
  } catch (error) {
    next(error);
  }
};
