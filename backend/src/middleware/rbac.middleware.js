import { errorResponse } from '../utils/apiResponse.js';

export const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return errorResponse(res, 'Authentication required before authorization check.', 401);
    }

    const userRole = (req.user.role || 'CUSTOMER').toUpperCase();
    const allowedRoles = roles.map(r => r.toUpperCase());

    if (!allowedRoles.includes(userRole)) {
      return errorResponse(
        res,
        `Access denied. Your role '${userRole}' does not have permission to access this resource.`,
        403
      );
    }

    next();
  };
};

export const requireAdmin = authorize('ADMIN');
