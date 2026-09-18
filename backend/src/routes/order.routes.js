import express from 'express';
import {
  checkout,
  getMyOrders,
  getOrderById,
  cancelMyOrder
} from '../controllers/order.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

const router = express.Router();

router.use(authenticate);

router.post('/checkout', checkout);
router.get('/my-orders', getMyOrders);
router.get('/:id', getOrderById);
router.put('/:id/cancel', cancelMyOrder);

export default router;
