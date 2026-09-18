import razorpayInstance, { verifyRazorpaySignature } from '../config/razorpay.js';
import Order from '../models/Order.js';
import Payment from '../models/Payment.js';
import Product from '../models/Product.js';
import Cart from '../models/Cart.js';
import { sendUserNotification } from './notification.service.js';
import { ENV } from '../config/env.js';
import { logger } from '../utils/logger.js';

export const createRazorpayOrder = async (orderId, userId) => {
  const order = await Order.findById(orderId);
  if (!order) {
    throw new Error('Order not found');
  }

  if (order.payment.status === 'PAID') {
    throw new Error('This order has already been paid for.');
  }

  const amountInPaise = Math.round(order.total * 100);

  let razorpayOrder;

  if (ENV.RAZORPAY.isConfigured() && razorpayInstance) {
    try {
      razorpayOrder = await razorpayInstance.orders.create({
        amount: amountInPaise,
        currency: 'INR',
        receipt: `rcpt_${order.orderNumber}`,
        notes: {
          orderId: order._id.toString(),
          orderNumber: order.orderNumber,
          userId: userId.toString()
        }
      });
    } catch (err) {
      logger.error('Razorpay SDK order creation error:', err);
      throw new Error(`Razorpay Error: ${err.error?.description || err.message}`);
    }
  } else {
    // Sandbox / Mock simulation mode
    razorpayOrder = {
      id: `order_mock_${Date.now()}`,
      entity: 'order',
      amount: amountInPaise,
      currency: 'INR',
      receipt: `rcpt_${order.orderNumber}`,
      status: 'created'
    };
    logger.info(`Razorpay Sandbox simulation order created: ${razorpayOrder.id}`);
  }

  // Update order with razorpayOrderId
  order.payment.razorpayOrderId = razorpayOrder.id;
  await order.save();

  // Create initial Payment entry
  await Payment.create({
    order: order._id,
    user: userId,
    razorpayOrderId: razorpayOrder.id,
    amount: order.total,
    currency: 'INR',
    status: 'CREATED'
  });

  return {
    orderId: order._id,
    orderNumber: order.orderNumber,
    razorpayOrderId: razorpayOrder.id,
    amount: amountInPaise,
    currency: 'INR',
    keyId: ENV.RAZORPAY.KEY_ID || 'rzp_test_mock_key'
  };
};

export const verifyAndFinalizePayment = async ({
  orderId,
  razorpay_order_id,
  razorpay_payment_id,
  razorpay_signature,
  userId
}) => {
  const order = await Order.findById(orderId);
  if (!order) {
    throw new Error('Order not found');
  }

  // Verify signature
  const isValid = verifyRazorpaySignature({
    razorpay_order_id,
    razorpay_payment_id,
    razorpay_signature
  });

  if (!isValid) {
    // Record failed payment
    await Payment.findOneAndUpdate(
      { razorpayOrderId: razorpay_order_id },
      {
        status: 'FAILED',
        errorDetails: { reason: 'Invalid signature verification' }
      }
    );
    throw new Error('Cryptographic payment signature verification failed. Please try again or contact support.');
  }

  // Payment is genuinely verified!
  order.payment.status = 'PAID';
  order.payment.razorpayPaymentId = razorpay_payment_id;
  order.payment.razorpaySignature = razorpay_signature;
  order.payment.paidAt = new Date();
  order.status = 'Paid';

  order.timeline.push({
    status: 'Paid',
    timestamp: new Date(),
    note: `Payment verified via Razorpay. Txn ID: ${razorpay_payment_id}`
  });

  // Decrement stock for purchased products
  for (const item of order.items) {
    await Product.findByIdAndUpdate(item.product, {
      $inc: { stock: -item.quantity }
    });
  }

  await order.save();

  // Update payment status in Payment ledger
  await Payment.findOneAndUpdate(
    { razorpayOrderId: razorpay_order_id },
    {
      status: 'CAPTURED',
      razorpayPaymentId: razorpay_payment_id,
      razorpaySignature: razorpay_signature
    }
  );

  // Clear customer cart
  await Cart.findOneAndUpdate({ user: userId }, { items: [], subtotal: 0, total: 0 });

  // Send Notification
  await sendUserNotification({
    userId,
    title: 'Payment Successful! 🪵✨',
    body: `Payment of ₹${order.total} for order #${order.orderNumber} was successfully processed. Our artisans will begin crafting your package.`,
    type: 'PAYMENT',
    data: { orderId: order._id.toString() }
  });

  return order;
};
