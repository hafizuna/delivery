// src/controllers/authController.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Register new user (Customer, Driver, Restaurant)
exports.register = async (req, res) => {
  try {
    const { phoneNumber, countryCode, password, firstName, lastName, role, email, fcmToken } = req.body;
    
    // Validate required fields
    if (!phoneNumber || !countryCode || !password || !firstName || !lastName || !role) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Validate role
    const validRoles = ['customer', 'driver', 'restaurant', 'admin'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({ error: 'Invalid role' });
    }
    
    // Create full phone number
    const fullPhone = `${countryCode}${phoneNumber}`;
    
    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { phoneNumber: fullPhone }
    });
    
    if (existingUser) {
      return res.status(400).json({ error: 'Phone number already registered' });
    }
    
    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);
    
    // Create user
    const user = await prisma.user.create({
      data: {
        phoneNumber: fullPhone,
        countryCode,
        passwordHash,
        firstName,
        lastName,
        role,
        email,
        fcmToken,
        provider: 'phone'
      },
      select: {
        id: true,
        phoneNumber: true,
        countryCode: true,
        firstName: true,
        lastName: true,
        email: true,
        role: true,
        profilePictureURL: true,
        walletAmount: true,
        active: true,
        createdAt: true
      }
    });
    
    // Generate tokens
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
    );
    
    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '90d' }
    );
    
    res.status(201).json({
      message: 'Registration successful',
      token,
      refreshToken,
      user
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed', message: error.message });
  }
};

// Login with phone + password
exports.login = async (req, res) => {
  try {
    const { phoneNumber, countryCode, password, fcmToken } = req.body;
    
    // Validate required fields
    if (!phoneNumber || !countryCode || !password) {
      return res.status(400).json({ error: 'Phone number, country code, and password are required' });
    }
    
    const fullPhone = `${countryCode}${phoneNumber}`;
    
    // Find user
    const user = await prisma.user.findUnique({
      where: { phoneNumber: fullPhone },
      include: {
        shippingAddresses: {
          orderBy: { isDefault: 'desc' }
        }
      }
    });
    
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Check if user is active
    if (!user.active) {
      return res.status(403).json({ error: 'Account is disabled. Please contact administrator' });
    }
    
    // Verify password
    const isValid = await bcrypt.compare(password, user.passwordHash);
    
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Update FCM token if provided
    if (fcmToken) {
      await prisma.user.update({
        where: { id: user.id },
        data: { fcmToken }
      });
    }
    
    // Generate tokens
    const token = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
    );
    
    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '90d' }
    );
    
    // Remove sensitive data
    const { passwordHash, ...userWithoutPassword } = user;
    
    res.json({
      message: 'Login successful',
      token,
      refreshToken,
      user: userWithoutPassword
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed', message: error.message });
  }
};

// Refresh access token
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(401).json({ error: 'No refresh token provided' });
    }
    
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Find user
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId }
    });
    
    if (!user || !user.active) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }
    
    // Generate new access token
    const newToken = jwt.sign(
      { userId: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
    );
    
    res.json({ 
      token: newToken,
      message: 'Token refreshed successfully'
    });
  } catch (error) {
    console.error('Token refresh error:', error);
    res.status(401).json({ error: 'Invalid refresh token' });
  }
};

// Logout (client-side token removal, optional server-side FCM token cleanup)
exports.logout = async (req, res) => {
  try {
    const userId = req.userId; // From auth middleware
    
    // Clear FCM token
    await prisma.user.update({
      where: { id: userId },
      data: { fcmToken: null }
    });
    
    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ error: 'Logout failed' });
  }
};
