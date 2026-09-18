import express from 'express';
import { createPayment, verifyPayment } from '../controllers/payment.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

const router = express.Router();

router.use(authenticate);

router.post('/create-order', createPayment);
router.post('/verify', verifyPayment);

export default router;
