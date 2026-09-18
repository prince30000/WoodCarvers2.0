import mongoose from 'mongoose';

const DeviceTokenSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  token: {
    type: String,
    required: true,
    unique: true
  },
  platform: {
    type: String,
    enum: ['web', 'android', 'ios'],
    default: 'web'
  },
  lastSeen: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

DeviceTokenSchema.index({ user: 1 });

const DeviceToken = mongoose.model('DeviceToken', DeviceTokenSchema);
export default DeviceToken;
