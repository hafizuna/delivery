import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/constant.dart';
import '../constant/show_toast_dialog.dart';
import '../models/order_model.dart';
import '../models/cart_product_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/cart_provider.dart';
import '../app/orders/live_tracking_screen.dart';

class OrderDetailsController extends GetxController {
  late final ApiService _apiService;
  late final SocketService _socketService;
  final cartProvider = CartProvider();

  // Observable current order
  Rx<OrderModel?> currentOrder = Rx<OrderModel?>(null);
  RxBool isLoading = false.obs;

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
    
    setupSocketListeners();
  }

  @override
  void onClose() {
    // Clean up socket listeners
    _socketService.disconnect();
    super.onClose();
  }

  /// Set the current order
  void setOrder(OrderModel order) {
    currentOrder.value = order;
    
    // Join this specific order for real-time updates
    _socketService.joinOrder(order.id!);
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
      
      // Check if this update is for the current order
      if (currentOrder.value?.id == orderId) {
        final updatedOrder = OrderModel.fromJson(data['order']);
        currentOrder.value = updatedOrder;
        
        ShowToastDialog.showToast(
          'Order status updated: ${_getStatusText(updatedOrder.status)}'
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
      
      if (currentOrder.value?.id == orderId) {
        final completedOrder = OrderModel.fromJson(data['order']);
        currentOrder.value = completedOrder;
        
        ShowToastDialog.showToast('🎉 Order delivered! Enjoy your meal!');
      }
    } catch (error) {
      print('Error handling order completion: $error');
    }
  }

  /// Handle order cancellation
  void _handleOrderCancelled(Map<String, dynamic> data) {
    try {
      final orderId = data['orderId'];
      
      if (currentOrder.value?.id == orderId) {
        final cancelledOrder = OrderModel.fromJson(data['order']);
        currentOrder.value = cancelledOrder;
        
        ShowToastDialog.showToast('Order cancelled');
      }
    } catch (error) {
      print('Error handling order cancellation: $error');
    }
  }

  /// Cancel the current order
  Future<void> cancelOrder() async {
    try {
      if (currentOrder.value == null) {
        ShowToastDialog.showToast('No order to cancel');
        return;
      }

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Cancel Order'),
          content: Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Yes, Cancel'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading.value = true;

      final response = await _apiService.cancelOrder(currentOrder.value!.id!);
      if (response != null && response['success'] == true) {
        // Update the current order status locally
        currentOrder.value = currentOrder.value!.copyWith(status: 'Order_Cancelled');
        
        ShowToastDialog.showToast('Order cancelled successfully');
      } else {
        ShowToastDialog.showToast('Failed to cancel order');
      }
    } catch (error) {
      print('Error cancelling order: $error');
      ShowToastDialog.showToast('Failed to cancel order');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to live tracking screen
  void navigateToTracking() {
    if (currentOrder.value == null) {
      ShowToastDialog.showToast('No order to track');
      return;
    }

    Get.to(() => LiveTrackingScreen(order: currentOrder.value!));
  }

  /// Reorder items from current order
  Future<void> reorderItems() async {
    try {
      if (currentOrder.value?.items == null || currentOrder.value!.items!.isEmpty) {
        ShowToastDialog.showToast('No items found to reorder');
        return;
      }

      // Convert order items to cart products
      int itemsAdded = 0;
      for (final orderItem in currentOrder.value!.items!) {
        final cartProduct = CartProductModel(
          id: orderItem.productId,
          name: orderItem.productName,
          price: orderItem.price.toString(),
          discountPrice: orderItem.discountPrice?.toString() ?? '0',
          quantity: orderItem.quantity,
          vendorID: currentOrder.value!.vendorId,
          categoryId: '', // Not needed for reorder
          photo: '', // Not needed for reorder
          extras: [], // Not needed for reorder
          extrasPrice: '0',
        );

        // Add to cart
        cartProvider.addToCart(Get.context!, cartProduct, orderItem.quantity!);
        itemsAdded++;
      }

      ShowToastDialog.showToast('$itemsAdded items added to cart');
      
      // Navigate back to restaurants or cart
      Get.back();
    } catch (error) {
      print('Error reordering items: $error');
      ShowToastDialog.showToast('Failed to add items to cart');
    }
  }

  /// Refresh order details from API
  Future<void> refreshOrder() async {
    try {
      if (currentOrder.value?.id == null) return;

      isLoading.value = true;
      final response = await _apiService.getOrderDetails(currentOrder.value!.id!);
      
      if (response != null && response['order'] != null) {
        currentOrder.value = OrderModel.fromJson(response['order']);
      }
    } catch (error) {
      print('Error refreshing order: $error');
      ShowToastDialog.showToast('Failed to refresh order');
    } finally {
      isLoading.value = false;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'Order_Placed':
        return 'Order Placed';
      case 'Order_Accepted':
        return 'Confirmed';
      case 'Driver_Pending':
        return 'Finding Driver';
      case 'Driver_Accepted':
        return 'Driver Assigned';
      case 'Order_Shipped':
        return 'Picked Up';
      case 'In_Transit':
        return 'On the Way';
      case 'Order_Completed':
        return 'Delivered';
      case 'Order_Rejected':
        return 'Rejected';
      case 'Order_Cancelled':
        return 'Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }
}