import mongoose from 'mongoose';

const PaymentSchema = new mongoose.Schema({
  order: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  razorpayOrderId: {
    type: String,
    required: true
  },
  razorpayPaymentId: {
    type: String
  },
  razorpaySignature: {
    type: String
  },
  amount: {
    type: Number,
    required: true
  },
  currency: {
    type: String,
    default: 'INR'
  },
  status: {
    type: String,
    enum: ['CREATED', 'AUTHORIZED', 'CAPTURED', 'FAILED', 'REFUNDED'],
    default: 'CREATED'
  },
  errorDetails: {
    code: String,
    description: String,
    source: String,
    step: String,
    reason: String
  }
}, {
  timestamps: true
});

PaymentSchema.index({ razorpayOrderId: 1 });
PaymentSchema.index({ order: 1 });

const Payment = mongoose.model('Payment', PaymentSchema);
export default Payment;
