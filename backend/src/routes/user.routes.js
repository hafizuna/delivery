// src/routes/user.routes.js
const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middlewares/auth');

// Get user profile
router.get('/profile', authenticate, async (req, res) => {
  try {
    const { PrismaClient } = require('@prisma/client');
    const prisma = new PrismaClient();
    
    const user = await prisma.user.findUnique({
      where: { id: req.userId },
      include: {
        shippingAddresses: true,
        walletTransactions: {
          take: 10,
          orderBy: { createdAt: 'desc' }
        }
      }
    });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const { passwordHash, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update user profile
router.put('/profile', authenticate, async (req, res) => {
  try {
    const { PrismaClient } = require('@prisma/client');
    const prisma = new PrismaClient();
    
    const { firstName, lastName, email, profilePictureURL } = req.body;
    
    const user = await prisma.user.update({
      where: { id: req.userId },
      data: {
        ...(firstName && { firstName }),
        ...(lastName && { lastName }),
        ...(email && { email }),
        ...(profilePictureURL && { profilePictureURL })
      }
    });
    
    const { passwordHash, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
