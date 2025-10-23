// src/index.js
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const path = require('path');
require('dotenv').config();

const app = express();
const server = require('http').createServer(app);

// Initialize Socket.IO
const initializeSocket = require('./sockets');
const io = initializeSocket(server);

// Make io accessible to routes
app.set('io', io);

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Foodie Delivery API is running',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/v1/auth', require('./routes/auth.routes'));
app.use('/api/v1/users', require('./routes/user.routes'));
app.use('/api/v1/vendors', require('./routes/vendor.routes'));
app.use('/api/v1/products', require('./routes/product.routes'));
app.use('/api/v1/orders', require('./routes/order.routes'));
app.use('/api/v1/chat', require('./routes/chat.routes'));
app.use('/api/v1/wallet', require('./routes/wallet.routes'));
app.use('/api/v1/upload', require('./routes/upload.routes'));
app.use('/api/v1/admin', require('./routes/admin.routes'));

// Error handler
app.use(require('./middlewares/errorHandler'));

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📝 API Documentation: http://localhost:${PORT}/health`);
  console.log(`📁 Uploads directory: ${path.join(__dirname, '../uploads')}`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Rejection:', err);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});
