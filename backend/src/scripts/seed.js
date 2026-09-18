import mongoose from 'mongoose';
import { connectDB } from '../config/db.js';
import User from '../models/User.js';
import Category from '../models/Category.js';
import Product from '../models/Product.js';
import Review from '../models/Review.js';
import { categoriesData, productsData } from '../utils/seedData.js';
import { logger } from '../utils/logger.js';

const seedDatabase = async () => {
  logger.info('Starting Wood Carvers database seed...');
  const conn = await connectDB();
  if (!conn) {
    logger.error('Database connection failed. Aborting seed.');
    process.exit(1);
  }

  try {
    // Clear existing data
    await User.deleteMany();
    await Category.deleteMany();
    await Product.deleteMany();
    await Review.deleteMany();

    logger.info('Existing data cleared.');

    // 1. Create Default Admin & Customer Accounts
    const adminUser = await User.create({
      name: 'Wood Carvers Master Admin',
      email: 'admin@woodcarvers.com',
      password: 'Admin@123456',
      role: 'ADMIN',
      phone: '+919876543210',
      isActive: true
    });

    const customerUser = await User.create({
      name: 'Aarav Sharma',
      email: 'customer@woodcarvers.com',
      password: 'Customer@123456',
      role: 'CUSTOMER',
      phone: '+919876543211',
      isActive: true,
      addresses: [
        {
          fullName: 'Aarav Sharma',
          phone: '+919876543211',
          street: '12 Heritage Woodcraft Lane, Indiranagar',
          landmark: 'Near Banyan Tree Square',
          city: 'Bengaluru',
          state: 'Karnataka',
          postalCode: '560038',
          country: 'India',
          isDefault: true,
          addressType: 'HOME'
        }
      ]
    });

    logger.info('Admin and Customer accounts created successfully.');

    // 2. Create Categories
    const createdCategories = await Category.insertMany(categoriesData);
    logger.info(`Seeded ${createdCategories.length} categories.`);

    const categoryMap = {};
    createdCategories.forEach(cat => {
      categoryMap[cat.slug] = cat._id;
    });

    // 3. Create Products linked to Category ObjectIds
    const productsToInsert = productsData.map(prod => {
      const { categorySlug, ...rest } = prod;
      return {
        ...rest,
        category: categoryMap[categorySlug] || createdCategories[0]._id
      };
    });

    const createdProducts = await Product.insertMany(productsToInsert);
    logger.info(`Seeded ${createdProducts.length} handcrafted decorative products.`);

    // 4. Create sample reviews for first 3 products
    if (createdProducts.length > 0) {
      await Review.create({
        product: createdProducts[0]._id,
        user: customerUser._id,
        rating: 5,
        title: 'Exquisite woodworking, true heirloom piece!',
        comment: 'The depth of the carving on this walnut medallion exceeded all expectations. You can feel the chisel marks and the beeswax aroma is wonderful. Packed with tremendous care.',
        isVerifiedPurchase: true,
        isApproved: true
      });

      await Review.create({
        product: createdProducts[1]._id,
        user: customerUser._id,
        rating: 5,
        title: 'Remarkable craftsmanship and symmetry',
        comment: 'The teakwood grain is gorgeous and the mandala pattern is meticulously hand-carved. Looks stunning in my meditation room.',
        isVerifiedPurchase: true,
        isApproved: true
      });
    }

    logger.info('Database seeding completed successfully!');
    logger.info('==========================================');
    logger.info('Credentials:');
    logger.info('Admin Login:    admin@woodcarvers.com    / Admin@123456');
    logger.info('Customer Login: customer@woodcarvers.com / Customer@123456');
    logger.info('==========================================');

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    logger.error('Error during database seeding:', error);
    await mongoose.connection.close();
    process.exit(1);
  }
};

seedDatabase();
