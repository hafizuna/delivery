// src/middlewares/auth.js
const jwt = require('jsonwebtoken');

// Authenticate JWT token
exports.authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
    const token = authHeader.split(' ')[1];
    
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Attach user info to request
    req.userId = decoded.userId;
    req.userRole = decoded.role;
    
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// Authorize specific roles
exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.userRole) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    if (!roles.includes(req.userRole)) {
      return res.status(403).json({ error: 'Access denied. Insufficient permissions' });
    }
    
    next();
  };
};

// Optional authentication (doesn't fail if no token)
exports.optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.userId = decoded.userId;
      req.userRole = decoded.role;
    }
    
    next();
  } catch (error) {
    // Continue without authentication
    next();
  }
};
