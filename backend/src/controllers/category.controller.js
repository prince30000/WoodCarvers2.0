import mongoose from 'mongoose';
import Category from '../models/Category.js';
import { successResponse, errorResponse } from '../utils/apiResponse.js';
import { memoryStore } from '../services/memoryStore.js';

export const getCategories = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const categories = await Category.find({ isActive: true }).sort({ displayOrder: 1, name: 1 });
      return successResponse(res, 'Categories fetched successfully', categories);
    } else {
      return successResponse(res, 'Categories fetched successfully', memoryStore.categories.filter(c => c.isActive));
    }
  } catch (error) {
    next(error);
  }
};

export const getCategoryBySlug = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const category = await Category.findOne({ slug: req.params.slug, isActive: true });
      if (!category) return errorResponse(res, 'Category not found', 404);
      return successResponse(res, 'Category details fetched', category);
    } else {
      const category = memoryStore.categories.find(c => c.slug === req.params.slug && c.isActive);
      if (!category) return errorResponse(res, 'Category not found', 404);
      return successResponse(res, 'Category details fetched', category);
    }
  } catch (error) {
    next(error);
  }
};
