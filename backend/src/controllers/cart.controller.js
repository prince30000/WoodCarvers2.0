import mongoose from 'mongoose';
import Cart from '../models/Cart.js';
import Product from '../models/Product.js';
import { successResponse, errorResponse } from '../utils/apiResponse.js';
import { memoryStore } from '../services/memoryStore.js';

const recalculateCartMongo = async (cart) => {
  let subtotal = 0;
  const validItems = [];

  for (const item of cart.items) {
    const product = await Product.findById(item.product);
    if (product && product.isActive) {
      const quantity = Math.min(item.quantity, Math.max(1, product.stock));
      const livePrice = product.discountedPrice || product.price;
      validItems.push({
        product: product._id,
        quantity,
        priceAtAddition: livePrice
      });
      subtotal += livePrice * quantity;
    }
  }

  cart.items = validItems;
  cart.subtotal = subtotal;
  cart.discount = 0;
  cart.shipping = subtotal >= 1999 ? 0 : 150;
  cart.total = cart.subtotal + cart.shipping;

  await cart.save();
  return cart.populate('items.product', 'title slug price discountedPrice images stock sku');
};

const getMemoryCart = (userId) => {
  if (!memoryStore.carts[userId]) {
    memoryStore.carts[userId] = {
      _id: `cart_${userId}`,
      id: `cart_${userId}`,
      user: userId,
      items: [],
      subtotal: 0,
      discount: 0,
      shipping: 0,
      total: 0
    };
  }
  const c = memoryStore.carts[userId];
  let subtotal = 0;
  c.items.forEach(it => {
    subtotal += (it.priceAtAddition || 0) * (it.quantity || 1);
  });
  c.subtotal = subtotal;
  c.shipping = subtotal >= 1999 || subtotal === 0 ? 0 : 150;
  c.total = c.subtotal + c.shipping;
  return c;
};

export const getCart = async (req, res, next) => {
  try {
    const userId = (req.user._id || req.user.id).toString();
    if (mongoose.connection.readyState === 1) {
      let cart = await Cart.findOne({ user: userId });
      if (!cart) cart = await Cart.create({ user: userId, items: [] });
      const synced = await recalculateCartMongo(cart);
      return successResponse(res, 'Cart fetched successfully', synced);
    } else {
      const c = getMemoryCart(userId);
      return successResponse(res, 'Cart fetched successfully', c);
    }
  } catch (error) {
    next(error);
  }
};

export const addToCart = async (req, res, next) => {
  try {
    const { productId, quantity = 1 } = req.body;
    const userId = (req.user._id || req.user.id).toString();

    if (mongoose.connection.readyState === 1) {
      const product = await Product.findById(productId);
      if (!product || !product.isActive) return errorResponse(res, 'Product is unavailable', 404);
      if (product.stock < 1) return errorResponse(res, 'Product is currently out of stock', 400);

      let cart = await Cart.findOne({ user: userId });
      if (!cart) cart = await Cart.create({ user: userId, items: [] });

      const idx = cart.items.findIndex(i => i.product.toString() === productId);
      if (idx > -1) {
        cart.items[idx].quantity += Number(quantity);
      } else {
        cart.items.push({
          product: productId,
          quantity: Number(quantity),
          priceAtAddition: product.discountedPrice || product.price
        });
      }

      const updated = await recalculateCartMongo(cart);
      return successResponse(res, 'Item added to cart', updated);
    } else {
      const product = memoryStore.products.find(p => p._id === productId || p.id === productId);
      if (!product || !product.isActive) return errorResponse(res, 'Product unavailable', 404);

      const cart = getMemoryCart(userId);
      const idx = cart.items.findIndex(i => (i.product?._id || i.product?.id || i.product) === productId);

      if (idx > -1) {
        cart.items[idx].quantity += Number(quantity);
      } else {
        cart.items.push({
          _id: `ci_${Date.now()}`,
          id: `ci_${Date.now()}`,
          product,
          quantity: Number(quantity),
          priceAtAddition: product.discountedPrice || product.price
        });
      }
      return successResponse(res, 'Item added to cart', getMemoryCart(userId));
    }
  } catch (error) {
    next(error);
  }
};

export const updateCartItemQuantity = async (req, res, next) => {
  try {
    const { productId, quantity } = req.body;
    const userId = (req.user._id || req.user.id).toString();

    if (mongoose.connection.readyState === 1) {
      const cart = await Cart.findOne({ user: userId });
      if (!cart) return errorResponse(res, 'Cart not found', 404);
      const idx = cart.items.findIndex(i => i.product.toString() === productId);
      if (idx === -1) return errorResponse(res, 'Item not found in cart', 404);
      cart.items[idx].quantity = Number(quantity);
      const updated = await recalculateCartMongo(cart);
      return successResponse(res, 'Cart updated', updated);
    } else {
      const cart = getMemoryCart(userId);
      const item = cart.items.find(i => (i.product?._id || i.product?.id || i.product) === productId);
      if (item) item.quantity = Number(quantity);
      return successResponse(res, 'Cart updated', getMemoryCart(userId));
    }
  } catch (error) {
    next(error);
  }
};

export const removeFromCart = async (req, res, next) => {
  try {
    const { productId } = req.params;
    const userId = (req.user._id || req.user.id).toString();

    if (mongoose.connection.readyState === 1) {
      const cart = await Cart.findOne({ user: userId });
      if (cart) {
        cart.items = cart.items.filter(i => i.product.toString() !== productId);
        const updated = await recalculateCartMongo(cart);
        return successResponse(res, 'Item removed from cart', updated);
      }
      return successResponse(res, 'Item removed from cart');
    } else {
      const cart = getMemoryCart(userId);
      cart.items = cart.items.filter(i => (i.product?._id || i.product?.id || i.product) !== productId);
      return successResponse(res, 'Item removed from cart', getMemoryCart(userId));
    }
  } catch (error) {
    next(error);
  }
};

export const clearCart = async (req, res, next) => {
  try {
    const userId = (req.user._id || req.user.id).toString();
    if (mongoose.connection.readyState === 1) {
      await Cart.findOneAndUpdate({ user: userId }, { items: [], subtotal: 0, total: 0 });
    } else {
      const cart = getMemoryCart(userId);
      cart.items = [];
    }
    return successResponse(res, 'Cart cleared');
  } catch (error) {
    next(error);
  }
};
