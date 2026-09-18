import mongoose from 'mongoose';
import Order from '../models/Order.js';
import Product from '../models/Product.js';
import Category from '../models/Category.js';
import User from '../models/User.js';
import { uploadImage, deleteImage } from '../services/cloudinary.service.js';
import { updateOrderStatus } from '../services/order.service.js';
import { broadcastNotification } from '../services/notification.service.js';
import { successResponse, createdResponse, paginatedResponse, errorResponse } from '../utils/apiResponse.js';
import { memoryStore } from '../services/memoryStore.js';

// 1. DASHBOARD ANALYTICS
export const getDashboardStats = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const totalOrders = await Order.countDocuments();
      const totalCustomers = await User.countDocuments({ role: 'CUSTOMER' });
      const totalProducts = await Product.countDocuments({ isActive: true });

      const revenueAgg = await Order.aggregate([
        { $match: { status: { $in: ['Paid', 'Confirmed', 'Processing', 'Packed', 'Shipped', 'Out for Delivery', 'Delivered'] } } },
        { $group: { _id: null, totalRevenue: { $sum: '$total' } } }
      ]);
      const totalRevenue = revenueAgg.length > 0 ? revenueAgg[0].totalRevenue : 0;
      const lowStockCount = await Product.countDocuments({ isActive: true, stock: { $gt: 0, $lte: 5 } });
      const outOfStockCount = await Product.countDocuments({ isActive: true, stock: 0 });

      const recentOrders = await Order.find().populate('user', 'name email').sort({ createdAt: -1 }).limit(6);
      const recentCustomers = await User.find({ role: 'CUSTOMER' }).sort({ createdAt: -1 }).limit(5).select('name email phone createdAt isActive');

      const statusBreakdown = await Order.aggregate([
        { $group: { _id: '$status', count: { $sum: 1 } } }
      ]);

      return successResponse(res, 'Dashboard analytics fetched', {
        totalRevenue,
        totalOrders,
        totalCustomers,
        totalProducts,
        lowStockCount,
        outOfStockCount,
        recentOrders,
        recentCustomers,
        statusBreakdown: statusBreakdown.reduce((acc, curr) => { acc[curr._id] = curr.count; return acc; }, {})
      });
    } else {
      const totalOrders = memoryStore.orders.length;
      const totalCustomers = memoryStore.users.filter(u => u.role === 'CUSTOMER').length;
      const totalProducts = memoryStore.products.filter(p => p.isActive).length;
      const totalRevenue = memoryStore.orders.reduce((sum, o) => sum + (o.total || 0), 0);
      const lowStockCount = memoryStore.products.filter(p => p.stock > 0 && p.stock <= 5).length;
      const outOfStockCount = memoryStore.products.filter(p => p.stock === 0).length;

      const statusBreakdown = {};
      memoryStore.orders.forEach(o => {
        statusBreakdown[o.status] = (statusBreakdown[o.status] || 0) + 1;
      });

      return successResponse(res, 'Dashboard analytics fetched', {
        totalRevenue,
        totalOrders,
        totalCustomers,
        totalProducts,
        lowStockCount,
        outOfStockCount,
        recentOrders: memoryStore.orders.slice(0, 6),
        recentCustomers: memoryStore.users.filter(u => u.role === 'CUSTOMER').slice(0, 5),
        statusBreakdown
      });
    }
  } catch (error) {
    next(error);
  }
};

// 2. PRODUCT MANAGEMENT
export const getAllProductsAdmin = async (req, res, next) => {
  try {
    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 20;
    const search = req.query.search;

    if (mongoose.connection.readyState === 1) {
      const filter = {};
      if (search && search.trim()) {
        filter.$or = [{ title: { $regex: search.trim(), $options: 'i' } }, { sku: { $regex: search.trim(), $options: 'i' } }];
      }
      if (req.query.category) filter.category = req.query.category;

      const total = await Product.countDocuments(filter);
      const products = await Product.find(filter).populate('category', 'name').sort({ createdAt: -1 }).skip((page - 1) * limit).limit(limit);
      return paginatedResponse(res, 'Admin products list', products, { page, limit, total });
    } else {
      let list = memoryStore.products;
      if (search && search.trim()) {
        const q = search.toLowerCase();
        list = list.filter(p => p.title.toLowerCase().includes(q) || p.sku.toLowerCase().includes(q));
      }
      return paginatedResponse(res, 'Admin products list', list, { page: 1, limit: 50, total: list.length });
    }
  } catch (error) {
    next(error);
  }
};

export const createProductAdmin = async (req, res, next) => {
  try {
    const { title, sku, description, category, price, discountPercent, stock, dimensions, weight, material, tags, isFeatured, isBestseller, isNewArrival, images } = req.body;

    const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '') + `-${Date.now().toString().slice(-4)}`;

    if (mongoose.connection.readyState === 1) {
      const product = await Product.create({
        title, slug, sku, description, category,
        price: Number(price), discountPercent: Number(discountPercent) || 0,
        stock: Number(stock), dimensions, weight, material, tags,
        isFeatured: Boolean(isFeatured), isBestseller: Boolean(isBestseller),
        isNewArrival: isNewArrival !== undefined ? Boolean(isNewArrival) : true,
        images: images || []
      });
      return createdResponse(res, 'Product created successfully', product);
    } else {
      const catObj = memoryStore.categories.find(c => c._id === category || c.id === category) || memoryStore.categories[0];
      const pNum = Number(price);
      const dNum = Number(discountPercent) || 0;
      const newProd = {
        _id: `prod_${Date.now()}`,
        id: `prod_${Date.now()}`,
        title, slug, sku, description,
        category: catObj,
        categorySlug: catObj.slug,
        price: pNum,
        discountPercent: dNum,
        discountedPrice: dNum > 0 ? Math.round(pNum * (1 - dNum / 100)) : pNum,
        stock: Number(stock),
        material: material || 'Natural Seasoned Wood',
        dimensions: dimensions || { length: 0, width: 0, height: 0, unit: 'cm' },
        weight: weight || { value: 0, unit: 'g' },
        tags: Array.isArray(tags) ? tags : [],
        isFeatured: Boolean(isFeatured),
        isBestseller: Boolean(isBestseller),
        isNewArrival: Boolean(isNewArrival),
        isActive: true,
        ratingsAverage: 5.0,
        ratingsCount: 0,
        images: images || [{ url: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80', isPrimary: true }]
      };
      memoryStore.products.unshift(newProd);
      return createdResponse(res, 'Product created successfully', newProd);
    }
  } catch (error) {
    next(error);
  }
};

export const updateProductAdmin = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
      return successResponse(res, 'Product updated successfully', product);
    } else {
      const prod = memoryStore.products.find(p => p._id === req.params.id || p.id === req.params.id);
      if (!prod) return errorResponse(res, 'Product not found', 404);
      Object.assign(prod, req.body);
      return successResponse(res, 'Product updated successfully', prod);
    }
  } catch (error) {
    next(error);
  }
};

export const deleteProductAdmin = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      await Product.findByIdAndDelete(req.params.id);
    } else {
      memoryStore.products = memoryStore.products.filter(p => p._id !== req.params.id && p.id !== req.params.id);
    }
    return successResponse(res, 'Product deleted successfully');
  } catch (error) {
    next(error);
  }
};

export const uploadMediaAdmin = async (req, res, next) => {
  try {
    const result = await uploadImage(req.file?.buffer, 'woodcarvers/products');
    return successResponse(res, 'Image uploaded to Cloudinary successfully', result);
  } catch (error) {
    next(error);
  }
};

// 3. CATEGORIES
export const createCategoryAdmin = async (req, res, next) => {
  try {
    const { name, description, image } = req.body;
    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '');

    if (mongoose.connection.readyState === 1) {
      const cat = await Category.create({ name, slug, description, image });
      return createdResponse(res, 'Category created', cat);
    } else {
      const newCat = { _id: `cat_${Date.now()}`, id: `cat_${Date.now()}`, name, slug, description, imageUrl: image?.url || '', isActive: true };
      memoryStore.categories.push(newCat);
      return createdResponse(res, 'Category created', newCat);
    }
  } catch (error) {
    next(error);
  }
};

export const updateCategoryAdmin = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const cat = await Category.findByIdAndUpdate(req.params.id, req.body, { new: true });
      return successResponse(res, 'Category updated', cat);
    } else {
      const cat = memoryStore.categories.find(c => c._id === req.params.id || c.id === req.params.id);
      if (cat) Object.assign(cat, req.body);
      return successResponse(res, 'Category updated', cat);
    }
  } catch (error) {
    next(error);
  }
};

export const deleteCategoryAdmin = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      await Category.findByIdAndDelete(req.params.id);
    } else {
      memoryStore.categories = memoryStore.categories.filter(c => c._id !== req.params.id && c.id !== req.params.id);
    }
    return successResponse(res, 'Category deleted successfully');
  } catch (error) {
    next(error);
  }
};

// 4. ORDERS
export const getAllOrdersAdmin = async (req, res, next) => {
  try {
    const status = req.query.status;
    if (mongoose.connection.readyState === 1) {
      const filter = {};
      if (status && status !== 'ALL') filter.status = status;
      const orders = await Order.find(filter).populate('user', 'name email phone').sort({ createdAt: -1 });
      return paginatedResponse(res, 'Orders list', orders, { page: 1, limit: 50, total: orders.length });
    } else {
      let list = memoryStore.orders;
      if (status && status !== 'ALL') list = list.filter(o => o.status === status);
      return paginatedResponse(res, 'Orders list', list, { page: 1, limit: 50, total: list.length });
    }
  } catch (error) {
    next(error);
  }
};

export const getOrderDetailsAdmin = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const order = await Order.findById(req.params.id).populate('user', 'name email phone');
      return successResponse(res, 'Order details', order);
    } else {
      const order = memoryStore.orders.find(o => o._id === req.params.id || o.id === req.params.id);
      return successResponse(res, 'Order details', order);
    }
  } catch (error) {
    next(error);
  }
};

export const updateOrderStatusAdmin = async (req, res, next) => {
  try {
    const { status, trackingNumber, carrier, note } = req.body;
    if (mongoose.connection.readyState === 1) {
      const updated = await updateOrderStatus({
        orderId: req.params.id,
        newStatus: status,
        trackingNumber,
        carrier,
        note,
        updatedBy: req.user.name
      });
      return successResponse(res, 'Order updated', updated);
    } else {
      const order = memoryStore.orders.find(o => o._id === req.params.id || o.id === req.params.id);
      if (!order) return errorResponse(res, 'Order not found', 404);
      order.status = status;
      if (trackingNumber) order.trackingNumber = trackingNumber;
      if (carrier) order.carrier = carrier;
      order.timeline.push({ status, timestamp: new Date(), note: note || `Updated to ${status}` });
      return successResponse(res, 'Order updated', order);
    }
  } catch (error) {
    next(error);
  }
};

// 5. CUSTOMERS
export const getAllCustomersAdmin = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const customers = await User.find({ role: 'CUSTOMER' }).select('-password');
      return paginatedResponse(res, 'Customers list', customers, { page: 1, limit: 50, total: customers.length });
    } else {
      const customers = memoryStore.users.filter(u => u.role === 'CUSTOMER');
      return paginatedResponse(res, 'Customers list', customers, { page: 1, limit: 50, total: customers.length });
    }
  } catch (error) {
    next(error);
  }
};

export const toggleCustomerStatusAdmin = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const user = await User.findById(req.params.id);
      if (user) { user.isActive = !user.isActive; await user.save(); }
      return successResponse(res, 'Customer status toggled', user);
    } else {
      const user = memoryStore.users.find(u => u._id === req.params.id || u.id === req.params.id);
      if (user) user.isActive = !user.isActive;
      return successResponse(res, 'Customer status toggled', user);
    }
  } catch (error) {
    next(error);
  }
};

export const sendBroadcastAdmin = async (req, res, next) => {
  try {
    const { title, body, type } = req.body;
    await broadcastNotification({ title, body, type });
    return successResponse(res, 'Broadcast sent');
  } catch (error) {
    next(error);
  }
};
