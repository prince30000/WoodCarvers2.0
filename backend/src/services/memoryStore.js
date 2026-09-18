import { categoriesData, productsData } from '../utils/seedData.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { ENV } from '../config/env.js';

class MemoryStore {
  constructor() {
    this.categories = categoriesData.map((c, i) => ({
      _id: `cat_${i + 1}`,
      id: `cat_${i + 1}`,
      ...c,
      imageUrl: c.image?.url || '',
      isActive: true
    }));

    const catMap = {};
    this.categories.forEach(c => { catMap[c.slug] = c; });

    this.products = productsData.map((p, i) => {
      const cat = catMap[p.categorySlug] || this.categories[0];
      const price = p.price;
      const discountPercent = p.discountPercent || 0;
      const discountedPrice = discountPercent > 0 ? Math.round(price * (1 - discountPercent / 100)) : price;

      return {
        _id: `prod_${i + 1}`,
        id: `prod_${i + 1}`,
        ...p,
        price,
        discountPercent,
        discountedPrice,
        category: cat,
        isActive: true,
        createdAt: new Date().toISOString()
      };
    });

    const passwordHash = bcrypt.hashSync('Admin@123456', 10);
    const custHash = bcrypt.hashSync('Customer@123456', 10);

    this.users = [
      {
        _id: 'usr_admin',
        id: 'usr_admin',
        name: 'Wood Carvers Master Admin',
        email: 'admin@woodcarvers.com',
        password: passwordHash,
        role: 'ADMIN',
        phone: '+919876543210',
        isActive: true,
        addresses: [],
        fcmTokens: []
      },
      {
        _id: 'usr_customer',
        id: 'usr_customer',
        name: 'Aarav Sharma',
        email: 'customer@woodcarvers.com',
        password: custHash,
        role: 'CUSTOMER',
        phone: '+919876543211',
        isActive: true,
        addresses: [
          {
            _id: 'addr_1',
            id: 'addr_1',
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
        ],
        fcmTokens: []
      }
    ];

    this.carts = {
      'usr_customer': {
        _id: 'cart_cust_1',
        user: 'usr_customer',
        items: [
          {
            _id: 'ci_1',
            product: this.products[0],
            quantity: 1,
            priceAtAddition: this.products[0].discountedPrice
          }
        ],
        subtotal: this.products[0].discountedPrice,
        discount: 0,
        shipping: 0,
        total: this.products[0].discountedPrice
      }
    };

    this.orders = [
      {
        _id: 'ord_1',
        id: 'ord_1',
        orderNumber: 'WC-202609-1088',
        user: this.users[1],
        items: [
          {
            _id: 'oi_1',
            product: this.products[0]._id,
            title: this.products[0].title,
            sku: this.products[0].sku,
            price: this.products[0].discountedPrice,
            quantity: 1,
            image: this.products[0].images[0].url
          }
        ],
        shippingAddress: this.users[1].addresses[0],
        payment: {
          method: 'RAZORPAY',
          status: 'PAID',
          razorpayPaymentId: 'pay_rzp_mock123'
        },
        subtotal: this.products[0].discountedPrice,
        shippingFee: 0,
        tax: Math.round(this.products[0].discountedPrice * 0.05),
        total: this.products[0].discountedPrice + Math.round(this.products[0].discountedPrice * 0.05),
        status: 'Delivered',
        timeline: [
          { status: 'Placed', timestamp: new Date(Date.now() - 432000000), note: 'Order placed' },
          { status: 'Confirmed', timestamp: new Date(Date.now() - 345600000), note: 'Order confirmed' },
          { status: 'Processing', timestamp: new Date(Date.now() - 259200000), note: 'Chiseled and prepared' },
          { status: 'Packed', timestamp: new Date(Date.now() - 172800000), note: 'Packed with eco-cushioning' },
          { status: 'Shipped', timestamp: new Date(Date.now() - 86400000), note: 'Shipped via BlueDart' },
          { status: 'Delivered', timestamp: new Date(), note: 'Delivered to customer' }
        ],
        trackingNumber: 'BD-WC-998822',
        carrier: 'BlueDart Express',
        createdAt: new Date(Date.now() - 432000000).toISOString()
      }
    ];

    this.reviews = [];
  }

  generateJwt(user) {
    return jwt.sign(
      { id: user._id, email: user.email, role: user.role, name: user.name },
      ENV.JWT_SECRET,
      { expiresIn: ENV.JWT_EXPIRE }
    );
  }
}

export const memoryStore = new MemoryStore();
