import Order from '../models/Order.js';
import Product from '../models/Product.js';
import Cart from '../models/Cart.js';
import { sendUserNotification } from './notification.service.js';
import { logger } from '../utils/logger.js';

export const createOrderFromCart = async ({ userId, shippingAddress, paymentMethod = 'RAZORPAY', notes = '' }) => {
  // 1. Fetch user's cart
  const cart = await Cart.findOne({ user: userId }).populate('items.product');
  if (!cart || cart.items.length === 0) {
    throw new Error('Your cart is empty. Add handcrafted wooden items before checkout.');
  }

  // 2. Validate stock and recalculate live prices directly from DB
  let calculatedSubtotal = 0;
  const orderItems = [];

  for (const cartItem of cart.items) {
    const product = await Product.findById(cartItem.product._id);
    if (!product || !product.isActive) {
      throw new Error(`Item "${cartItem.product.title}" is no longer available.`);
    }

    if (product.stock < cartItem.quantity) {
      throw new Error(`Insufficient stock for "${product.title}". Only ${product.stock} left in stock.`);
    }

    const unitPrice = product.discountedPrice || product.price;
    calculatedSubtotal += unitPrice * cartItem.quantity;

    const primaryImage = product.images.find(img => img.isPrimary) || product.images[0];

    orderItems.push({
      product: product._id,
      title: product.title,
      sku: product.sku,
      price: unitPrice,
      quantity: cartItem.quantity,
      image: primaryImage ? primaryImage.url : ''
    });
  }

  // Free shipping over 1999 INR, else 150 INR standard artisanal courier
  const shippingFee = calculatedSubtotal >= 1999 ? 0 : 150;
  const tax = Math.round(calculatedSubtotal * 0.05); // 5% GST on handcrafted decorative woodcraft
  const total = calculatedSubtotal + shippingFee + tax;

  // Generate unique human-readable order number WC-YYYYMM-XXXX
  const dateStr = new Date().toISOString().slice(0, 7).replace('-', '');
  const randomSuffix = Math.floor(1000 + Math.random() * 9000);
  const orderNumber = `WC-${dateStr}-${randomSuffix}`;

  // 3. Create the Order
  const order = await Order.create({
    orderNumber,
    user: userId,
    items: orderItems,
    shippingAddress,
    payment: {
      method: paymentMethod,
      status: paymentMethod === 'COD' ? 'PENDING' : 'PENDING'
    },
    subtotal: calculatedSubtotal,
    discount: 0,
    shippingFee,
    tax,
    total,
    status: paymentMethod === 'COD' ? 'Confirmed' : 'Payment Pending',
    timeline: [
      {
        status: 'Placed',
        timestamp: new Date(),
        note: 'Order placed by customer'
      }
    ],
    notes
  });

  // If COD, decrement stock immediately and send notification
  if (paymentMethod === 'COD') {
    for (const item of orderItems) {
      await Product.findByIdAndUpdate(item.product, {
        $inc: { stock: -item.quantity }
      });
    }

    // Clear cart
    cart.items = [];
    cart.subtotal = 0;
    cart.total = 0;
    await cart.save();

    await sendUserNotification({
      userId,
      title: 'Order Placed Successfully! 🪵',
      body: `Your order #${order.orderNumber} for handcrafted wooden pieces has been confirmed.`,
      type: 'ORDER_STATUS',
      data: { orderId: order._id.toString() }
    });
  }

  return order;
};

export const updateOrderStatus = async ({ orderId, newStatus, trackingNumber, carrier, note = '', updatedBy = 'Admin' }) => {
  const order = await Order.findById(orderId);
  if (!order) {
    throw new Error('Order not found');
  }

  const previousStatus = order.status;
  order.status = newStatus;

  if (trackingNumber) order.trackingNumber = trackingNumber;
  if (carrier) order.carrier = carrier;

  // Append to timeline
  order.timeline.push({
    status: newStatus,
    timestamp: new Date(),
    note: note || `Status updated from ${previousStatus} to ${newStatus} by ${updatedBy}`
  });

  await order.save();

  // Send Push Notification based on new status
  const statusMessages = {
    'Confirmed': 'Your handcrafted woodcraft order has been confirmed and queued for preparation.',
    'Processing': 'Our master artisans are carefully inspecting and preparing your wooden items.',
    'Packed': 'Your order has been securely packed in eco-cushioning and is ready for dispatch.',
    'Shipped': `Your order has shipped via ${carrier || 'Express Courier'}! Tracking: ${trackingNumber || 'Available shortly'}.`,
    'Out for Delivery': 'Your Wood Carvers package is out for delivery today!',
    'Delivered': 'Your handcrafted wooden pieces have been delivered! We hope they bring warm character to your space.',
    'Cancelled': 'Your order has been cancelled.',
    'Refunded': 'Your refund has been processed.'
  };

  if (statusMessages[newStatus]) {
    await sendUserNotification({
      userId: order.user,
      title: `Order Update: ${newStatus} 🪵`,
      body: statusMessages[newStatus],
      type: 'ORDER_STATUS',
      data: { orderId: order._id.toString() }
    });
  }

  return order;
};
