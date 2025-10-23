// src/sockets/index.js
const socketIO = require('socket.io');

module.exports = (server) => {
  const io = socketIO(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"]
    }
  });

  // Track connected users
  const connectedUsers = new Map();

  io.on('connection', (socket) => {
    console.log(`✅ Client connected: ${socket.id}`);

    // User joins with their user ID
    socket.on('join', (userId) => {
      socket.userId = userId;
      connectedUsers.set(userId, socket.id);
      socket.join(`user:${userId}`);
      console.log(`User ${userId} joined`);
    });

    // Order tracking events
    socket.on('track_order', (orderId) => {
      socket.join(`order:${orderId}`);
      console.log(`Tracking order: ${orderId}`);
    });

    // Driver location update
    socket.on('driver_location', (data) => {
      const { orderId, latitude, longitude, rotation } = data;
      // Broadcast to customers tracking this order
      io.to(`order:${orderId}`).emit('driver_location_update', {
        latitude,
        longitude,
        rotation,
        timestamp: new Date()
      });
    });

    // Chat message
    socket.on('send_message', (data) => {
      const { receiverId, message } = data;
      const receiverSocketId = connectedUsers.get(receiverId);
      
      if (receiverSocketId) {
        io.to(receiverSocketId).emit('new_message', message);
      }
    });

    // Disconnect
    socket.on('disconnect', () => {
      if (socket.userId) {
        connectedUsers.delete(socket.userId);
        console.log(`User ${socket.userId} disconnected`);
      }
      console.log(`❌ Client disconnected: ${socket.id}`);
    });
  });

  // Helper function to emit to specific user
  io.emitToUser = (userId, event, data) => {
    const socketId = connectedUsers.get(userId);
    if (socketId) {
      io.to(socketId).emit(event, data);
    }
  };

  // Helper function to emit to order room
  io.emitToOrder = (orderId, event, data) => {
    io.to(`order:${orderId}`).emit(event, data);
  };

  return io;
};
