import express from 'express';
import { getWishlist, toggleWishlist } from '../controllers/wishlist.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

const router = express.Router();

router.use(authenticate);

router.get('/', getWishlist);
router.post('/toggle', toggleWishlist);

export default router;
