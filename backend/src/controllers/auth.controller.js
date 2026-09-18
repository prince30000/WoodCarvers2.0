import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import User from '../models/User.js';
import DeviceToken from '../models/DeviceToken.js';
import { successResponse, createdResponse, errorResponse } from '../utils/apiResponse.js';
import { memoryStore } from '../services/memoryStore.js';

export const register = async (req, res, next) => {
  try {
    const { name, email, password, phone } = req.body;

    if (!name || !email || !password) {
      return errorResponse(res, 'Name, email, and password are required', 400);
    }

    if (mongoose.connection.readyState === 1) {
      const existingUser = await User.findOne({ email: email.toLowerCase() });
      if (existingUser) {
        return errorResponse(res, 'An account with this email address already exists', 400);
      }

      const user = await User.create({
        name,
        email: email.toLowerCase(),
        password,
        phone: phone || '',
        role: 'CUSTOMER'
      });

      const token = user.getSignedJwtToken();

      return createdResponse(res, 'Account registered successfully', {
        token,
        user: { id: user._id, name: user.name, email: user.email, role: user.role, phone: user.phone }
      });
    } else {
      const existing = memoryStore.users.find(u => u.email.toLowerCase() === email.toLowerCase());
      if (existing) return errorResponse(res, 'An account with this email address already exists', 400);

      const newUser = {
        _id: `usr_${Date.now()}`,
        id: `usr_${Date.now()}`,
        name,
        email: email.toLowerCase(),
        password: bcrypt.hashSync(password, 10),
        role: 'CUSTOMER',
        phone: phone || '',
        isActive: true,
        addresses: [],
        fcmTokens: []
      };
      memoryStore.users.push(newUser);
      const token = memoryStore.generateJwt(newUser);

      return createdResponse(res, 'Account registered successfully', {
        token,
        user: { id: newUser.id, name: newUser.name, email: newUser.email, role: newUser.role, phone: newUser.phone }
      });
    }
  } catch (error) {
    next(error);
  }
};

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return errorResponse(res, 'Please provide an email and password', 400);
    }

    if (mongoose.connection.readyState === 1) {
      const user = await User.findOne({ email: email.toLowerCase() }).select('+password');
      if (!user) return errorResponse(res, 'Invalid credentials', 401);
      if (!user.isActive) return errorResponse(res, 'Your account has been deactivated. Please contact support.', 403);

      const isMatch = await user.matchPassword(password);
      if (!isMatch) return errorResponse(res, 'Invalid credentials', 401);

      const token = user.getSignedJwtToken();
      return successResponse(res, 'Login successful', {
        token,
        user: { id: user._id, name: user.name, email: user.email, role: user.role, phone: user.phone, avatar: user.avatar }
      });
    } else {
      const user = memoryStore.users.find(u => u.email.toLowerCase() === email.toLowerCase());
      if (!user) return errorResponse(res, 'Invalid credentials', 401);
      if (!user.isActive) return errorResponse(res, 'Your account has been deactivated.', 403);

      const isMatch = bcrypt.compareSync(password, user.password);
      if (!isMatch) return errorResponse(res, 'Invalid credentials', 401);

      const token = memoryStore.generateJwt(user);
      return successResponse(res, 'Login successful', {
        token,
        user: { id: user.id || user._id, name: user.name, email: user.email, role: user.role, phone: user.phone, avatar: user.avatar || '' }
      });
    }
  } catch (error) {
    next(error);
  }
};

export const getMe = async (req, res, next) => {
  try {
    return successResponse(res, 'User profile fetched', req.user);
  } catch (error) {
    next(error);
  }
};

export const updateProfile = async (req, res, next) => {
  try {
    const { name, phone } = req.body;
    if (mongoose.connection.readyState === 1) {
      const user = await User.findById(req.user._id);
      if (name) user.name = name;
      if (phone !== undefined) user.phone = phone;
      await user.save();
      return successResponse(res, 'Profile updated successfully', user);
    } else {
      if (name) req.user.name = name;
      if (phone !== undefined) req.user.phone = phone;
      return successResponse(res, 'Profile updated successfully', req.user);
    }
  } catch (error) {
    next(error);
  }
};

export const addAddress = async (req, res, next) => {
  try {
    const { fullName, phone, street, landmark, city, state, postalCode, country, isDefault, addressType } = req.body;
    const newAddress = {
      _id: `addr_${Date.now()}`,
      id: `addr_${Date.now()}`,
      fullName,
      phone,
      street,
      landmark: landmark || '',
      city,
      state,
      postalCode,
      country: country || 'India',
      isDefault: isDefault || (req.user.addresses?.length === 0),
      addressType: addressType || 'HOME'
    };

    if (mongoose.connection.readyState === 1) {
      const user = await User.findById(req.user._id);
      if (isDefault) { user.addresses.forEach(addr => { addr.isDefault = false; }); }
      user.addresses.push(newAddress);
      await user.save();
      return createdResponse(res, 'Address added successfully', user.addresses);
    } else {
      if (!req.user.addresses) req.user.addresses = [];
      if (isDefault) { req.user.addresses.forEach(a => { a.isDefault = false; }); }
      req.user.addresses.push(newAddress);
      return createdResponse(res, 'Address added successfully', req.user.addresses);
    }
  } catch (error) {
    next(error);
  }
};

export const deleteAddress = async (req, res, next) => {
  try {
    if (mongoose.connection.readyState === 1) {
      const user = await User.findById(req.user._id);
      user.addresses = user.addresses.filter(addr => addr._id.toString() !== req.params.addressId);
      await user.save();
      return successResponse(res, 'Address removed successfully', user.addresses);
    } else {
      req.user.addresses = req.user.addresses.filter(a => a._id !== req.params.addressId && a.id !== req.params.addressId);
      return successResponse(res, 'Address removed successfully', req.user.addresses);
    }
  } catch (error) {
    next(error);
  }
};

export const registerFcmToken = async (req, res, next) => {
  try {
    return successResponse(res, 'Device token registered');
  } catch (error) {
    next(error);
  }
};
