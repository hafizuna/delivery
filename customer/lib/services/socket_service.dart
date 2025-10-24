import 'dart:async';
import 'package:customer/config/app_config.dart';
import 'package:customer/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  
  IO.Socket? _socket;
  final StorageService _storage = StorageService();
  
  // Stream controllers for real-time updates
  final _orderStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _orderCompletedController = StreamController<Map<String, dynamic>>.broadcast();
  final _orderCancelledController = StreamController<Map<String, dynamic>>.broadcast();
  final _driverLocationController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatMessageController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Getters for streams
  Stream<Map<String, dynamic>> get orderStatusStream => _orderStatusController.stream;
  Stream<Map<String, dynamic>> get orderCompletedStream => _orderCompletedController.stream;
  Stream<Map<String, dynamic>> get orderCancelledStream => _orderCancelledController.stream;
  Stream<Map<String, dynamic>> get driverLocationStream => _driverLocationController.stream;
  Stream<Map<String, dynamic>> get chatMessageStream => _chatMessageController.stream;
  
  SocketService._internal();
  
  /// Connect to Socket.IO server
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      if (kDebugMode) {
        print('🔌 Socket already connected');
      }
      return;
    }
    
    try {
      final token = await _storage.read('token');
      
      _socket = IO.io(
        AppConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );
      
      _setupListeners();
      
      if (kDebugMode) {
        print('🔌 Socket connecting to ${AppConfig.socketUrl}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Socket connection error: $e');
      }
    }
  }
  
  void _setupListeners() {
    if (_socket == null) return;
    
    // Connection events
    _socket!.onConnect((_) {
      if (kDebugMode) {
        print('✅ Socket connected');
      }
    });
    
    _socket!.onDisconnect((_) {
      if (kDebugMode) {
        print('❌ Socket disconnected');
      }
    });
    
    _socket!.onError((error) {
      if (kDebugMode) {
        print('❌ Socket error: $error');
      }
    });
    
    // Order status updates
    _socket!.on(AppConfig.socketOrderStatusUpdateEvent, (data) {
      if (kDebugMode) {
        print('📦 Order status update: $data');
      }
      _orderStatusController.add(data as Map<String, dynamic>);
    });
    
    // Driver location updates
    _socket!.on(AppConfig.socketDriverLocationUpdateEvent, (data) {
      if (kDebugMode) {
        print('📍 Driver location update: $data');
      }
      _driverLocationController.add(data as Map<String, dynamic>);
    });
    
    // Order completed
    _socket!.on('orderCompleted', (data) {
      if (kDebugMode) {
        print('✅ Order completed: $data');
      }
      _orderCompletedController.add(data as Map<String, dynamic>);
    });
    
    // Order cancelled
    _socket!.on('orderCancelled', (data) {
      if (kDebugMode) {
        print('❌ Order cancelled: $data');
      }
      _orderCancelledController.add(data as Map<String, dynamic>);
    });
    
    // Order status updated
    _socket!.on('orderStatusUpdated', (data) {
      if (kDebugMode) {
        print('📦 Order status updated: $data');
      }
      _orderStatusController.add(data as Map<String, dynamic>);
    });
    
    // Driver location updated
    _socket!.on('driverLocationUpdated', (data) {
      if (kDebugMode) {
        print('📍 Driver location updated: $data');
      }
      _driverLocationController.add(data as Map<String, dynamic>);
    });
    
    // Chat messages
    _socket!.on(AppConfig.socketNewMessageEvent, (data) {
      if (kDebugMode) {
        print('💬 New chat message: $data');
      }
      _chatMessageController.add(data as Map<String, dynamic>);
    });
  }
  
  /// Disconnect from Socket.IO server
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      if (kDebugMode) {
        print('🔌 Socket disconnected manually');
      }
    }
  }
  
  /// Check if socket is connected
  bool get isConnected => _socket != null && _socket!.connected;
  
  // ============== ORDER EVENTS ==============
  
  /// Join order room for real-time updates
  void joinOrder(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(AppConfig.socketJoinOrderEvent, {'orderId': orderId});
      if (kDebugMode) {
        print('📦 Joined order room: $orderId');
      }
    }
  }
  
  /// Leave order room
  void leaveOrder(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(AppConfig.socketLeaveOrderEvent, {'orderId': orderId});
      if (kDebugMode) {
        print('📦 Left order room: $orderId');
      }
    }
  }
  
  // ============== CHAT EVENTS ==============
  
  /// Join chat room
  void joinChat(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(AppConfig.socketJoinChatEvent, {'orderId': orderId});
      if (kDebugMode) {
        print('💬 Joined chat room: $orderId');
      }
    }
  }
  
  /// Leave chat room
  void leaveChat(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(AppConfig.socketLeaveChatEvent, {'orderId': orderId});
      if (kDebugMode) {
        print('💬 Left chat room: $orderId');
      }
    }
  }
  
  /// Send chat message
  void sendMessage(Map<String, dynamic> messageData) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(AppConfig.socketSendMessageEvent, messageData);
      if (kDebugMode) {
        print('💬 Sent message: $messageData');
      }
    }
  }
  
  /// Mark message as read
  void markMessageAsRead(String messageId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit(AppConfig.socketMessageReadEvent, {'messageId': messageId});
      if (kDebugMode) {
        print('✅ Marked message as read: $messageId');
      }
    }
  }
  
  // ============== DRIVER LOCATION EVENTS ==============
  
  /// Request driver location update
  void requestDriverLocation(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('requestDriverLocation', {'orderId': orderId});
      if (kDebugMode) {
        print('📍 Requested driver location for order: $orderId');
      }
    }
  }
  
  // ============== CLEANUP ==============
  
  void dispose() {
    _orderStatusController.close();
    _orderCompletedController.close();
    _orderCancelledController.close();
    _driverLocationController.close();
    _chatMessageController.close();
    disconnect();
  }
}
