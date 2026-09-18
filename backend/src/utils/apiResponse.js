/**
 * Standardized API Response Envelopes for Wood Carvers REST API
 */

export const successResponse = (res, message = 'Operation successful', data = null, statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    timestamp: new Date().toISOString()
  });
};

export const createdResponse = (res, message = 'Resource created successfully', data = null) => {
  return successResponse(res, message, data, 201);
};

export const paginatedResponse = (res, message = 'Data fetched successfully', data = [], pagination = {}, statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    pagination: {
      page: Number(pagination.page) || 1,
      limit: Number(pagination.limit) || 10,
      total: Number(pagination.total) || data.length,
      totalPages: Math.ceil((Number(pagination.total) || data.length) / (Number(pagination.limit) || 10))
    },
    timestamp: new Date().toISOString()
  });
};

export const errorResponse = (res, message = 'An error occurred', statusCode = 500, errors = null) => {
  const response = {
    success: false,
    message,
    timestamp: new Date().toISOString()
  };

  if (errors) {
    response.errors = errors;
  }

  return res.status(statusCode).json(response);
};
