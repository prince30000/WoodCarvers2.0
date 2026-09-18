import app from '../app.js';
import { ENV } from '../config/env.js';

console.log('✅ Express app and all routes loaded successfully!');
console.log(`Port configured: ${ENV.PORT}`);
console.log(`Node environment: ${ENV.NODE_ENV}`);
process.exit(0);
