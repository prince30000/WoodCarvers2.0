import mongoose from 'mongoose';
import Order from '../models/Order.js';
import { createOrderFromCart, updateOrderStatus } from '../services/order.service.js';
import { successResponse, createdResponse, paginatedResponse, errorResponse } from '../utils/apiResponse.js';
import { memoryStore } from '../services/memoryStore.js';

export const checkout = async (req, res, next) => {
  try {
    const { shippingAddress, paymentMethod = 'RAZORPAY', notes = '' } = req.body;
    const userId = (req.user._id || req.user.id).toString();

    if (mongoose.connection.readyState === 1) {
      const order = await createOrderFromCart({
        userId,
        shippingAddress,
        paymentMethod,
        notes
      });
      return createdResponse(res, 'Order created successfully', order);
    } else {
      const cart = memoryStore.carts[userId] || { items: [] };
      const dateStr = new Date().toISOString().slice(0, 7).replace('-', '');
      const randomSuffix = Math.floor(1000 + Math.random() * 9000);
      const orderNumber = `WC-${dateStr}-${randomSuffix}`;

      const orderItems = cart.items.map(it => ({
        _id: `oi_${Date.now()}`,
        product: it.product?._id || it.product?.id,
        title: it.product?.title || 'Handcrafted Wooden Piece',
        sku: it.product?.sku || 'WC-WOOD',
        price: it.priceAtAddition,
        quantity: it.quantity,
        image: it.product?.images ? it.product.images[0].url : ''
      }));

      const subtotal = cart.subtotal || 2999;
      const shippingFee = subtotal >= 1999 ? 0 : 150;
      const tax = Math.round(subtotal * 0.05);
      const total = subtotal + shippingFee + tax;

      const newOrder = {
        _id: `ord_${Date.now()}`,
        id: `ord_${Date.now()}`,
        orderNumber,
        user: req.user,
        items: orderItems,
        shippingAddress,
        payment: {
          method: paymentMethod,
          status: paymentMethod === 'COD' ? 'PENDING' : 'PENDING'
        },
        subtotal,
        discount: 0,
        shippingFee,
        tax,
        total,
        status: paymentMethod === 'COD' ? 'Confirmed' : 'Payment Pending',
        timeline: [
          { status: 'Placed', timestamp: new Date(), note: 'Order placed by customer' }
        ],
        trackingNumber: '',
        carrier: '',
        createdAt: new Date().toISOString()
      };

      memoryStore.orders.unshift(newOrder);
      if (memoryStore.carts[userId]) {
        memoryStore.carts[userId].items = [];
      }

      return createdResponse(res, 'Order created successfully', newOrder);
    }
  } catch (error) {
    next(error);
  }
};

export const getMyOrders = async (req, res, next) => {
  try {
    const userId = (req.user._id || req.user.id).toString();
    if (mongoose.connection.readyState === 1) {
      const page = Number(req.query.page) || 1;
      const limit = Number(req.query.limit) || 10;
      const skip = (page - 1) * limit;

      const total = await Order.countDocuments({ user: userId });
      const orders = await Order.find({ user: userId }).sort({ createdAt: -1 }).skip(skip).limit(limit);

      return paginatedResponse(res, 'Orders fetched successfully', orders, { page, limit, total });
    } else {
      const orders = memoryStore.orders.filter(o => {
        const uId = o.user?._id || o.user?.id || o.user;
        return uId === userId || req.user.role === 'ADMIN';
      });
      return paginatedResponse(res, 'Orders fetched successfully', orders, { page: 1, limit: 20, total: orders.length });
    }
  } catch (error) {
    next(error);
  }
};

export const getOrderById = async (req, res, next) => {
  try {
    const userId = (req.user._id || req.user.id).toString();
    if (mongoose.connection.readyState === 1) {
      const order = await Order.findOne({ _id: req.params.id, user: userId }).populate('items.product', 'slug title');
      if (!order) return errorResponse(res, 'Order not found', 404);
      return successResponse(res, 'Order details fetched', order);
    } else {
      const order = memoryStore.orders.find(o => o._id === req.params.id || o.id === req.params.id);
      if (!order) return errorResponse(res, 'Order not found', 404);
      return successResponse(res, 'Order details fetched', order);
    }
  } catch (error) {
    next(error);
  }
};

export const cancelMyOrder = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const order = await Order.findOne({ _id: req.params.id, user: req.user._id });
      if (!order) return errorResponse(res, 'Order not found', 404);
      const updated = await updateOrderStatus({
        orderId: order._id,
        newStatus: 'Cancelled',
        note: 'Cancelled by customer',
        updatedBy: req.user.name
      });
      return successResponse(res, 'Order has been cancelled successfully', updated);
    } else {
      const order = memoryStore.orders.find(o => o._id === req.params.id || o.id === req.params.id);
      if (!order) return errorResponse(res, 'Order not found', 404);
      order.status = 'Cancelled';
      order.timeline.push({ status: 'Cancelled', timestamp: new Date(), note: 'Cancelled by customer' });
      return successResponse(res, 'Order has been cancelled', order);
    }
  } catch (error) {
    next(error);
  }
};
