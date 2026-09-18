import { logger } from '../utils/logger.js';
import { errorResponse } from '../utils/apiResponse.js';

export const notFoundHandler = (req, res, next) => {
  return errorResponse(res, `API route not found: ${req.method} ${req.originalUrl}`, 404);
};

export const globalErrorHandler = (err, req, res, next) => {
  logger.error(`Unhandled API Error on ${req.method} ${req.originalUrl}:`, err);

  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';
  let errors = null;

  // Mongoose Bad ObjectId
  if (err.name === 'CastError') {
    message = `Resource not found with invalid identifier: ${err.value}`;
    statusCode = 404;
  }

  // Mongoose Duplicate Key
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue || {})[0];
    message = `A resource already exists with that ${field || 'value'}.`;
    statusCode = 400;
  }

  // Mongoose Validation Error
  if (err.name === 'ValidationError') {
    message = 'Validation failed for request data.';
    statusCode = 400;
    errors = Object.values(err.errors).map(val => val.message);
  }

  // JWT Errors
  if (err.name === 'JsonWebTokenError') {
    message = 'Invalid authentication token.';
    statusCode = 401;
  }
  if (err.name === 'TokenExpiredError') {
    message = 'Authentication token expired.';
    statusCode = 401;
  }

  return errorResponse(res, message, statusCode, errors);
};
