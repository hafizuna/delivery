// src/middlewares/errorHandler.js

module.exports = (err, req, res, next) => {
  console.error('Error:', err);

  // Prisma errors
  if (err.code === 'P2002') {
    return res.status(400).json({
      error: 'Duplicate entry',
      message: `${err.meta?.target?.join(', ')} already exists`
    });
  }

  if (err.code === 'P2025') {
    return res.status(404).json({
      error: 'Record not found',
      message: err.meta?.cause || 'The requested resource was not found'
    });
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      error: 'Invalid token',
      message: 'Authentication failed'
    });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      error: 'Token expired',
      message: 'Please log in again'
    });
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: 'Validation error',
      message: err.message,
      details: err.details
    });
  }

  // Multer errors
  if (err.name === 'MulterError') {
    return res.status(400).json({
      error: 'File upload error',
      message: err.message
    });
  }

  // Default error
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal server error';

  res.status(statusCode).json({
    error: 'Server error',
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};
