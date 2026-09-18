import Review from '../models/Review.js';
import Order from '../models/Order.js';
import Product from '../models/Product.js';
import { successResponse, createdResponse, paginatedResponse, errorResponse } from '../utils/apiResponse.js';

export const getProductReviews = async (req, res, next) => {
  try {
    const { productId } = req.params;
    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const total = await Review.countDocuments({ product: productId, isApproved: true });
    const reviews = await Review.find({ product: productId, isApproved: true })
      .populate('user', 'name avatar')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    return paginatedResponse(res, 'Reviews fetched', reviews, { page, limit, total });
  } catch (error) {
    next(error);
  }
};

export const addReview = async (req, res, next) => {
  try {
    const { productId } = req.params;
    const { rating, title, comment } = req.body;

    const product = await Product.findById(productId);
    if (!product) return errorResponse(res, 'Product not found', 404);

    // Check if user already reviewed this product
    const existing = await Review.findOne({ product: productId, user: req.user._id });
    if (existing) {
      return errorResponse(res, 'You have already submitted a review for this handcrafted piece', 400);
    }

    // Check verified purchase (User has an order containing this product with status Delivered or Paid)
    const verifiedOrder = await Order.findOne({
      user: req.user._id,
      'items.product': productId,
      status: { $in: ['Delivered', 'Paid', 'Confirmed', 'Processing', 'Packed', 'Shipped', 'Out for Delivery'] }
    });

    const isVerifiedPurchase = Boolean(verifiedOrder);

    const review = await Review.create({
      product: productId,
      user: req.user._id,
      rating: Number(rating),
      title,
      comment,
      isVerifiedPurchase,
      isApproved: true
    });

    return createdResponse(res, 'Review submitted successfully', review);
  } catch (error) {
    next(error);
  }
};
