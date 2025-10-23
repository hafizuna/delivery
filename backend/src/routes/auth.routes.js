// src/routes/auth.routes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticate } = require('../middlewares/auth');

// Public routes
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/refresh', authController.refreshToken);

// Protected routes
router.post('/logout', authenticate, authController.logout);

module.exports = router;
