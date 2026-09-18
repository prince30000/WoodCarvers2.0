import express from 'express';
import multer from 'multer';
import {
  getDashboardStats,
  getAllProductsAdmin,
  createProductAdmin,
  updateProductAdmin,
  deleteProductAdmin,
  uploadMediaAdmin,
  createCategoryAdmin,
  updateCategoryAdmin,
  deleteCategoryAdmin,
  getAllOrdersAdmin,
  getOrderDetailsAdmin,
  updateOrderStatusAdmin,
  getAllCustomersAdmin,
  toggleCustomerStatusAdmin,
  sendBroadcastAdmin
} from '../controllers/admin.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';
import { requireAdmin } from '../middleware/rbac.middleware.js';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB max
});

const router = express.Router();

// Enforce both JWT authentication and ADMIN role for all routes in this router
router.use(authenticate, requireAdmin);

// Dashboard Analytics
router.get('/dashboard', getDashboardStats);

// Product Management
router.get('/products', getAllProductsAdmin);
router.post('/products', createProductAdmin);
router.put('/products/:id', updateProductAdmin);
router.delete('/products/:id', deleteProductAdmin);
router.post('/upload', upload.single('image'), uploadMediaAdmin);

// Category Management
router.post('/categories', createCategoryAdmin);
router.put('/categories/:id', updateCategoryAdmin);
router.delete('/categories/:id', deleteCategoryAdmin);

// Order Management
router.get('/orders', getAllOrdersAdmin);
router.get('/orders/:id', getOrderDetailsAdmin);
router.put('/orders/:id/status', updateOrderStatusAdmin);

// Customer Management
router.get('/customers', getAllCustomersAdmin);
router.put('/customers/:id/toggle-status', toggleCustomerStatusAdmin);

// Notifications
router.post('/notifications/broadcast', sendBroadcastAdmin);

export default router;
