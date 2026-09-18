import mongoose from 'mongoose';
import Product from '../models/Product.js';
import Category from '../models/Category.js';
import { successResponse, paginatedResponse, errorResponse } from '../utils/apiResponse.js';
import { memoryStore } from '../services/memoryStore.js';

export const getProducts = async (req, res, next) => {
  try {
    const {
      search,
      category,
      minPrice,
      maxPrice,
      inStock,
      isFeatured,
      isBestseller,
      isNewArrival,
      sort = 'newest',
      page = 1,
      limit = 12
    } = req.query;

    if (mongoose.connection.readyState === 1) {
      const filter = { isActive: true };

      if (search && search.trim()) {
        filter.$text = { $search: search.trim() };
      }

      if (category) {
        if (category.match(/^[0-9a-fA-F]{24}$/)) {
          filter.category = category;
        } else {
          const catDoc = await Category.findOne({ slug: category });
          if (catDoc) filter.category = catDoc._id;
        }
      }

      if (minPrice || maxPrice) {
        filter.discountedPrice = {};
        if (minPrice) filter.discountedPrice.$gte = Number(minPrice);
        if (maxPrice) filter.discountedPrice.$lte = Number(maxPrice);
      }

      if (inStock === 'true' || inStock === true) filter.stock = { $gt: 0 };
      if (isFeatured === 'true') filter.isFeatured = true;
      if (isBestseller === 'true') filter.isBestseller = true;
      if (isNewArrival === 'true') filter.isNewArrival = true;

      let sortOption = { createdAt: -1 };
      if (sort === 'price-asc') sortOption = { discountedPrice: 1 };
      if (sort === 'price-desc') sortOption = { discountedPrice: -1 };
      if (sort === 'popularity') sortOption = { ratingsCount: -1 };
      if (sort === 'rating') sortOption = { ratingsAverage: -1 };

      const skip = (Number(page) - 1) * Number(limit);
      const total = await Product.countDocuments(filter);
      const products = await Product.find(filter)
        .populate('category', 'name slug')
        .sort(sortOption)
        .skip(skip)
        .limit(Number(limit));

      return paginatedResponse(res, 'Products fetched successfully', products, { page, limit, total });
    } else {
      // Memory Store fallback
      let list = memoryStore.products.filter(p => p.isActive);

      if (search && search.trim()) {
        const q = search.toLowerCase();
        list = list.filter(p => p.title.toLowerCase().includes(q) || p.description.toLowerCase().includes(q) || (p.tags && p.tags.some(t => t.toLowerCase().includes(q))));
      }

      if (category && category !== 'all') {
        list = list.filter(p => p.categorySlug === category || p.category?.slug === category || p.category?._id === category);
      }

      if (minPrice) list = list.filter(p => p.discountedPrice >= Number(minPrice));
      if (maxPrice) list = list.filter(p => p.discountedPrice <= Number(maxPrice));
      if (inStock === 'true' || inStock === true) list = list.filter(p => p.stock > 0);
      if (isFeatured === 'true') list = list.filter(p => p.isFeatured);
      if (isBestseller === 'true') list = list.filter(p => p.isBestseller);
      if (isNewArrival === 'true') list = list.filter(p => p.isNewArrival);

      if (sort === 'price-asc') list.sort((a, b) => a.discountedPrice - b.discountedPrice);
      if (sort === 'price-desc') list.sort((a, b) => b.discountedPrice - a.discountedPrice);
      if (sort === 'popularity') list.sort((a, b) => (b.ratingsCount || 0) - (a.ratingsCount || 0));
      if (sort === 'rating') list.sort((a, b) => (b.ratingsAverage || 0) - (a.ratingsAverage || 0));

      const skip = (Number(page) - 1) * Number(limit);
      const paginated = list.slice(skip, skip + Number(limit));

      return paginatedResponse(res, 'Products fetched successfully', paginated, { page, limit, total: list.length });
    }
  } catch (error) {
    next(error);
  }
};

export const getProductBySlug = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const product = await Product.findOne({ slug: req.params.slug, isActive: true }).populate('category', 'name slug');
      if (!product) return errorResponse(res, 'Product not found', 404);
      return successResponse(res, 'Product details fetched', product);
    } else {
      const product = memoryStore.products.find(p => p.slug === req.params.slug && p.isActive);
      if (!product) return errorResponse(res, 'Product not found', 404);
      return successResponse(res, 'Product details fetched', product);
    }
  } catch (error) {
    next(error);
  }
};

export const getProductById = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const product = await Product.findById(req.params.id).populate('category', 'name slug');
      if (!product) return errorResponse(res, 'Product not found', 404);
      return successResponse(res, 'Product details fetched', product);
    } else {
      const product = memoryStore.products.find(p => p._id === req.params.id || p.id === req.params.id || p.slug === req.params.id);
      if (!product) return errorResponse(res, 'Product not found', 404);
      return successResponse(res, 'Product details fetched', product);
    }
  } catch (error) {
    next(error);
  }
};

export const getFeaturedProducts = async (req, res, next) => {
  try {
    const limit = Number(req.query.limit) || 8;
    if (mongoose.connection.readyState === 1) {
      const products = await Product.find({ isActive: true, isFeatured: true }).populate('category', 'name slug').limit(limit);
      return successResponse(res, 'Featured products fetched', products);
    } else {
      const products = memoryStore.products.filter(p => p.isActive && p.isFeatured).slice(0, limit);
      return successResponse(res, 'Featured products fetched', products);
    }
  } catch (error) {
    next(error);
  }
};

export const getNewArrivals = async (req, res, next) => {
  try {
    const limit = Number(req.query.limit) || 8;
    if (mongoose.connection.readyState === 1) {
      const products = await Product.find({ isActive: true, isNewArrival: true }).populate('category', 'name slug').limit(limit);
      return successResponse(res, 'New arrivals fetched', products);
    } else {
      const products = memoryStore.products.filter(p => p.isActive && p.isNewArrival).slice(0, limit);
      return successResponse(res, 'New arrivals fetched', products);
    }
  } catch (error) {
    next(error);
  }
};

export const getBestsellers = async (req, res, next) => {
  try {
    const limit = Number(req.query.limit) || 8;
    if (mongoose.connection.readyState === 1) {
      const products = await Product.find({ isActive: true, isBestseller: true }).populate('category', 'name slug').limit(limit);
      return successResponse(res, 'Bestsellers fetched', products);
    } else {
      const products = memoryStore.products.filter(p => p.isActive && p.isBestseller).slice(0, limit);
      return successResponse(res, 'Bestsellers fetched', products);
    }
  } catch (error) {
    next(error);
  }
};

export const getRelatedProducts = async (req, res, next) => {
  try {
    const { id } = req.params;
    if (mongoose.connection.readyState === 1) {
      const current = await Product.findById(id);
      if (!current) return errorResponse(res, 'Product not found', 404);
      const related = await Product.find({ _id: { $ne: current._id }, category: current.category, isActive: true }).limit(4).populate('category', 'name slug');
      return successResponse(res, 'Related products fetched', related);
    } else {
      const current = memoryStore.products.find(p => p._id === id || p.id === id);
      const related = memoryStore.products.filter(p => p._id !== id && p.isActive).slice(0, 4);
      return successResponse(res, 'Related products fetched', related);
    }
  } catch (error) {
    next(error);
  }
};
