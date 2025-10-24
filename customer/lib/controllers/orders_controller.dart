import 'package:get/get.dart';
import '../constant/constant.dart';
import '../constant/show_toast_dialog.dart';
import '../models/order_model.dart';
import '../models/cart_product_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/cart_provider.dart';

class OrdersController extends GetxController {
  late final ApiService _apiService;
  late final SocketService _socketService;
  final cartProvider = CartProvider();

  // Observable lists for different order categories
  RxList<OrderModel> allOrders = <OrderModel>[].obs;
  RxList<OrderModel> inProgressOrders = <OrderModel>[].obs;
  RxList<OrderModel> deliveredOrders = <OrderModel>[].obs;
  RxList<OrderModel> rejectedOrders = <OrderModel>[].obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize services
    try {
      _apiService = Get.find<ApiService>();
    } catch (e) {
      _apiService = ApiService();
      Get.put(_apiService);
    }
    
    try {
      _socketService = Get.find<SocketService>();
    } catch (e) {
      _socketService = SocketService();
      Get.put(_socketService);
    }
    
    if (Constant.userModel != null) {
      getOrders();
      setupSocketListeners();
    }
  }

  @override
  void onClose() {
    // Clean up socket listeners
    _socketService.disconnect();
    super.onClose();
  }

  /// Fetch orders from API
  Future<void> getOrders() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getOrders();
      if (response != null && response['orders'] != null) {
        final List<dynamic> ordersList = response['orders'] as List;
        
        // Parse orders from API response
        allOrders.value = ordersList
            .map((json) => OrderModel.fromJson(json))
            .toList();

        // Filter orders by status
        _filterOrdersByStatus();
      }
    } catch (error) {
      print('Error fetching orders: $error');
      ShowToastDialog.showToast('Failed to load orders');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter orders into different categories based on status
  void _filterOrdersByStatus() {
    // In Progress: Active orders
    inProgressOrders.value = allOrders.where((order) => 
        order.status == 'Order_Accepted' ||
        order.status == 'Driver_Pending' ||
        order.status == 'Driver_Accepted' ||
        order.status == 'Order_Shipped' ||
        order.status == 'In_Transit' ||
        order.status == 'Driver_Rejected'
    ).toList();

    // Delivered: Completed orders
    deliveredOrders.value = allOrders.where((order) => 
        order.status == 'Order_Completed'
    ).toList();

    // Rejected: Cancelled/Rejected orders
    rejectedOrders.value = allOrders.where((order) => 
        order.status == 'Order_Rejected' ||
        order.status == 'Order_Cancelled'
    ).toList();
  }

  /// Setup Socket.IO listeners for real-time order updates
  void setupSocketListeners() {
    // Listen for order status updates
    _socketService.orderStatusStream.listen((data) {
      _handleOrderStatusUpdate(data);
    });

    // Listen for order completion
    _socketService.orderCompletedStream.listen((data) {
      _handleOrderCompleted(data);
    });

    // Listen for order cancellation
    _socketService.orderCancelledStream.listen((data) {
      _handleOrderCancelled(data);
    });
  }

  /// Handle real-time order status updates
  void _handleOrderStatusUpdate(Map<String, dynamic> data) {
    try {
      final orderId = data['orderId'];
      final updatedOrder = OrderModel.fromJson(data['order']);
      
      // Find and update the order in the list
      final index = allOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        allOrders[index] = updatedOrder;
        _filterOrdersByStatus(); // Re-filter after update
        
        ShowToastDialog.showToast(
          'Order ${updatedOrder.orderId ?? orderId.substring(0, 8)} status updated'
        );
      }
    } catch (error) {
      print('Error handling order status update: $error');
    }
  }

  /// Handle order completion
  void _handleOrderCompleted(Map<String, dynamic> data) {
    try {
      final orderId = data['orderId'];
      final completedOrder = OrderModel.fromJson(data['order']);
      
      // Update the order in the list
      final index = allOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        allOrders[index] = completedOrder;
        _filterOrdersByStatus();
        
        ShowToastDialog.showToast(
          '🎉 Order delivered! Enjoy your meal!'
        );
      }
    } catch (error) {
      print('Error handling order completion: $error');
    }
  }

  /// Handle order cancellation
  void _handleOrderCancelled(Map<String, dynamic> data) {
    try {
      final orderId = data['orderId'];
      final cancelledOrder = OrderModel.fromJson(data['order']);
      
      // Update the order in the list
      final index = allOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        allOrders[index] = cancelledOrder;
        _filterOrdersByStatus();
        
        ShowToastDialog.showToast(
          'Order cancelled'
        );
      }
    } catch (error) {
      print('Error handling order cancellation: $error');
    }
  }

  /// Reorder items from a previous order
  Future<void> reorderItems(OrderModel order) async {
    try {
      if (order.items == null || order.items!.isEmpty) {
        ShowToastDialog.showToast('No items found to reorder');
        return;
      }

      // Convert order items to cart products
      for (final orderItem in order.items!) {
        final cartProduct = CartProductModel(
          id: orderItem.productId,
          name: orderItem.productName,
          price: orderItem.price.toString(),
          discountPrice: orderItem.discountPrice?.toString() ?? '0',
          quantity: orderItem.quantity,
          vendorID: order.vendorId,
          categoryId: '', // Not needed for reorder
          photo: '', // Not needed for reorder
          extras: [], // Not needed for reorder
          extrasPrice: '0',
        );

        // Add to cart
        cartProvider.addToCart(Get.context!, cartProduct, orderItem.quantity!);
      }

      ShowToastDialog.showToast(
        '${order.items!.length} items added to cart'
      );
    } catch (error) {
      print('Error reordering items: $error');
      ShowToastDialog.showToast('Failed to add items to cart');
    }
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      ShowToastDialog.showLoader('Cancelling order...');
      
      await _apiService.cancelOrder(orderId, reason: reason);
      
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Order cancelled successfully');
      
      // Refresh orders
      await getOrders();
    } catch (error) {
      ShowToastDialog.closeLoader();
      print('Error cancelling order: $error');
      ShowToastDialog.showToast('Failed to cancel order');
    }
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final response = await _apiService.getOrderById(orderId);
      if (response != null) {
        return OrderModel.fromJson(response);
      }
    } catch (error) {
      print('Error fetching order details: $error');
      ShowToastDialog.showToast('Failed to load order details');
    }
    return null;
  }

  /// Check if order can be cancelled
  bool canCancelOrder(String status) {
    return status == 'Order_Placed' || status == 'Order_Accepted';
  }

  /// Check if order can be tracked
  bool canTrackOrder(String status) {
    return status == 'Order_Shipped' || status == 'In_Transit';
  }

  /// Check if order can be reordered
  bool canReorder(String status) {
    return status == 'Order_Completed';
  }
}