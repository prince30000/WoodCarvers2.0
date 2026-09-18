import mongoose from 'mongoose';

const ProductImageSchema = new mongoose.Schema({
  url: { type: String, required: true },
  publicId: { type: String, default: '' },
  isPrimary: { type: Boolean, default: false },
  alt: { type: String, default: '' }
}, { _id: true });

const ProductSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Product title is required'],
    trim: true,
    maxlength: [120, 'Title cannot exceed 120 characters']
  },
  slug: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  sku: {
    type: String,
    required: [true, 'SKU identifier is required'],
    unique: true,
    uppercase: true,
    trim: true
  },
  description: {
    type: String,
    required: [true, 'Product description is required'],
    maxlength: [4000, 'Description cannot exceed 4000 characters']
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: [true, 'Product category is required']
  },
  price: {
    type: Number,
    required: [true, 'Product price is required'],
    min: [0, 'Price cannot be negative']
  },
  discountPercent: {
    type: Number,
    default: 0,
    min: [0, 'Discount percentage cannot be negative'],
    max: [90, 'Discount percentage cannot exceed 90%']
  },
  discountedPrice: {
    type: Number,
    default: function () {
      if (this.discountPercent > 0) {
        return Math.round(this.price * (1 - this.discountPercent / 100));
      }
      return this.price;
    }
  },
  stock: {
    type: Number,
    required: [true, 'Stock count is required'],
    default: 10,
    min: [0, 'Stock cannot be negative']
  },
  images: {
    type: [ProductImageSchema],
    validate: [
      (val) => val.length > 0,
      'Product must have at least one image'
    ]
  },
  dimensions: {
    length: { type: Number, default: 0 },
    width: { type: Number, default: 0 },
    height: { type: Number, default: 0 },
    unit: { type: String, default: 'cm' }
  },
  weight: {
    value: { type: Number, default: 0 },
    unit: { type: String, default: 'g' }
  },
  material: {
    type: String,
    default: 'Natural Seasoned Wood',
    trim: true
  },
  careInstructions: {
    type: String,
    default: 'Wipe gently with a soft dry cloth. Keep away from direct water immersion and extreme moisture. Nourish occasionally with natural beeswax or mineral oil.'
  },
  craftsmanshipInfo: {
    type: String,
    default: 'Individually hand-carved and hand-finished by master artisan woodworkers using ethically sourced timber.'
  },
  shippingInfo: {
    type: String,
    default: 'Packed securely in protective eco-cushioning. Dispatched within 24-48 business hours.'
  },
  returnPolicy: {
    type: String,
    default: '7-day easy returns on damaged or defective items in original condition.'
  },
  tags: [{
    type: String,
    trim: true
  }],
  isFeatured: {
    type: Boolean,
    default: false
  },
  isBestseller: {
    type: Boolean,
    default: false
  },
  isNewArrival: {
    type: Boolean,
    default: true
  },
  isActive: {
    type: Boolean,
    default: true
  },
  ratingsAverage: {
    type: Number,
    default: 4.8,
    min: [1, 'Rating must be at least 1.0'],
    max: [5, 'Rating cannot exceed 5.0'],
    set: (v) => Math.round(v * 10) / 10
  },
  ratingsCount: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Auto calculate discountedPrice on pre-save
ProductSchema.pre('save', function (next) {
  if (this.isModified('price') || this.isModified('discountPercent')) {
    if (this.discountPercent > 0) {
      this.discountedPrice = Math.round(this.price * (1 - this.discountPercent / 100));
    } else {
      this.discountedPrice = this.price;
    }
  }
  next();
});

// Compound Indexes for fast catalog browsing and search
ProductSchema.index({ category: 1, isActive: 1, discountedPrice: 1 });
ProductSchema.index({ isFeatured: 1, isActive: 1 });
ProductSchema.index({ isBestseller: 1, isActive: 1 });
ProductSchema.index({ isNewArrival: 1, isActive: 1 });
ProductSchema.index({
  title: 'text',
  description: 'text',
  tags: 'text',
  material: 'text'
}, {
  weights: {
    title: 10,
    tags: 5,
    material: 3,
    description: 1
  }
});

const Product = mongoose.model('Product', ProductSchema);
export default Product;
