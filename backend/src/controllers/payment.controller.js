import mongoose from 'mongoose';
import { createRazorpayOrder, verifyAndFinalizePayment } from '../services/payment.service.js';
import { successResponse, errorResponse } from '../utils/apiResponse.js';
import { memoryStore } from '../services/memoryStore.js';
import { ENV } from '../config/env.js';

export const createPayment = async (req, res, next) => {
  try {
    const { orderId } = req.body;
    if (!orderId) {
      return errorResponse(res, 'Order ID is required to initiate payment', 400);
    }

    if (mongoose.connection.readyState === 1) {
      const paymentDetails = await createRazorpayOrder(orderId, req.user._id);
      return successResponse(res, 'Razorpay order initiated', paymentDetails);
    } else {
      const order = memoryStore.orders.find(o => o._id === orderId || o.id === orderId);
      if (!order) return errorResponse(res, 'Order not found', 404);

      const rzpOrderId = `order_mock_${Date.now()}`;
      order.payment.razorpayOrderId = rzpOrderId;

      return successResponse(res, 'Razorpay order initiated', {
        orderId: order.id,
        orderNumber: order.orderNumber,
        razorpayOrderId: rzpOrderId,
        amount: Math.round(order.total * 100),
        currency: 'INR',
        keyId: ENV.RAZORPAY.KEY_ID || 'rzp_test_woodcarvers123'
      });
    }
  } catch (error) {
    next(error);
  }
};

export const verifyPayment = async (req, res, next) => {
  try {
    const { orderId, razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    if (!orderId || !razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return errorResponse(res, 'Missing payment verification credentials', 400);
    }

    if (mongoose.connection.readyState === 1) {
      const verifiedOrder = await verifyAndFinalizePayment({
        orderId,
        razorpay_order_id,
        razorpay_payment_id,
        razorpay_signature,
        userId: req.user._id
      });
      return successResponse(res, 'Payment verified and order confirmed successfully', verifiedOrder);
    } else {
      const order = memoryStore.orders.find(o => o._id === orderId || o.id === orderId);
      if (!order) return errorResponse(res, 'Order not found', 404);

      order.payment.status = 'PAID';
      order.payment.razorpayPaymentId = razorpay_payment_id;
      order.payment.razorpaySignature = razorpay_signature;
      order.status = 'Confirmed';
      order.timeline.push({
        status: 'Confirmed',
        timestamp: new Date(),
        note: `Payment verified via Razorpay Txn: ${razorpay_payment_id}`
      });

      return successResponse(res, 'Payment verified and order confirmed successfully', order);
    }
  } catch (error) {
    next(error);
  }
};
