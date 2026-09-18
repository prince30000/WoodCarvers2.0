import Wishlist from '../models/Wishlist.js';
import { successResponse } from '../utils/apiResponse.js';

export const getWishlist = async (req, res, next) => {
  try {
    let wishlist = await Wishlist.findOne({ user: req.user._id })
      .populate('products', 'title slug price discountedPrice images stock sku');

    if (!wishlist) {
      wishlist = await Wishlist.create({ user: req.user._id, products: [] });
    }

    return successResponse(res, 'Wishlist fetched', wishlist.products);
  } catch (error) {
    next(error);
  }
};

export const toggleWishlist = async (req, res, next) => {
  try {
    const { productId } = req.body;
    let wishlist = await Wishlist.findOne({ user: req.user._id });

    if (!wishlist) {
      wishlist = await Wishlist.create({ user: req.user._id, products: [] });
    }

    const index = wishlist.products.findIndex(id => id.toString() === productId);
    let action = 'added';

    if (index > -1) {
      wishlist.products.splice(index, 1);
      action = 'removed';
    } else {
      wishlist.products.push(productId);
    }

    await wishlist.save();
    await wishlist.populate('products', 'title slug price discountedPrice images stock sku');

    return successResponse(res, `Item ${action} from wishlist`, {
      action,
      products: wishlist.products
    });
  } catch (error) {
    next(error);
  }
};
