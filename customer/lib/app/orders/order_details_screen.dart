import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/constant.dart';
import '../../models/order_model.dart';
import '../../controllers/order_details_controller.dart';
import '../../themes/app_them_data.dart';
import '../../utils/network_image_widget.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderDetailsController());
    controller.setOrder(order);

    return Scaffold(
      backgroundColor: AppThemeData.grey50,
      appBar: AppBar(
        backgroundColor: AppThemeData.primary300,
        title: Text(
          'Order Details',
          style: TextStyle(
            color: AppThemeData.grey900,
            fontFamily: AppThemeData.medium,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: Constant.loader());
        }

        final currentOrder = controller.currentOrder.value;
        if (currentOrder == null) {
          return Center(
            child: Text(
              'Order not found',
              style: TextStyle(
                fontSize: 16,
                color: AppThemeData.grey500,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Info Card
              _buildOrderInfoCard(currentOrder),
              const SizedBox(height: 16),
              
              // Restaurant Info Card
              _buildRestaurantCard(currentOrder),
              const SizedBox(height: 16),
              
              // Order Timeline
              _buildOrderTimeline(currentOrder),
              const SizedBox(height: 16),
              
              // Order Items
              _buildOrderItems(currentOrder),
              const SizedBox(height: 16),
              
              // Price Breakdown
              _buildPriceBreakdown(currentOrder),
              const SizedBox(height: 16),
              
              // Action Buttons
              _buildActionButtons(context, currentOrder, controller),
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderInfoCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeData.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderId ?? order.id?.substring(0, 8) ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: AppThemeData.semiBold,
                  color: AppThemeData.grey900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppThemeData.medium,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppThemeData.grey500,
              ),
              const SizedBox(width: 6),
              Text(
                'Ordered on ${_formatDate(order.createdAtDate)}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppThemeData.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.payment,
                size: 16,
                color: AppThemeData.grey500,
              ),
              const SizedBox(width: 6),
              Text(
                'Payment: ${order.paymentMethod ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppThemeData.grey500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeData.grey100),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: NetworkImageWidget(
              imageUrl: order.vendor?.photo ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.vendor?.title ?? 'Restaurant',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: AppThemeData.semiBold,
                    color: AppThemeData.grey900,
                  ),
                ),
                const SizedBox(height: 4),
                if (order.vendor?.location != null)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppThemeData.grey500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.vendor!.location!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppThemeData.grey500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeData.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Progress',
            style: TextStyle(
              fontSize: 16,
              fontFamily: AppThemeData.semiBold,
              color: AppThemeData.grey900,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem('Order Placed', 'Your order has been placed', true, true),
          _buildTimelineItem('Order Confirmed', 'Restaurant is preparing your order', 
              _isStatusReached(order.status, 'Order_Accepted'), 
              _isStatusReached(order.status, 'Order_Accepted')),
          _buildTimelineItem('Driver Assigned', 'A driver has been assigned', 
              _isStatusReached(order.status, 'Driver_Accepted'), 
              _isStatusReached(order.status, 'Driver_Accepted')),
          _buildTimelineItem('Order Picked Up', 'Driver picked up your order', 
              _isStatusReached(order.status, 'Order_Shipped'), 
              _isStatusReached(order.status, 'Order_Shipped')),
          _buildTimelineItem('On the Way', 'Your order is on the way', 
              _isStatusReached(order.status, 'In_Transit'), 
              _isStatusReached(order.status, 'In_Transit')),
          _buildTimelineItem('Delivered', 'Order delivered successfully', 
              _isStatusReached(order.status, 'Order_Completed'), 
              _isStatusReached(order.status, 'Order_Completed'), isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isActive, bool isCompleted, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? AppThemeData.primary300 : AppThemeData.grey100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppThemeData.primary300 : AppThemeData.grey300,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 12,
                      color: AppThemeData.grey900,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? AppThemeData.primary300 : AppThemeData.grey200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppThemeData.medium,
                    color: isActive ? AppThemeData.grey900 : AppThemeData.grey500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppThemeData.grey500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    if (order.items == null || order.items!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeData.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${order.items!.length})',
            style: TextStyle(
              fontSize: 16,
              fontFamily: AppThemeData.semiBold,
              color: AppThemeData.grey900,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items!.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final item = order.items![index];
              return Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppThemeData.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fastfood,
                      color: AppThemeData.grey500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName ?? 'Unknown Item',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppThemeData.medium,
                            color: AppThemeData.grey900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Qty: ${item.quantity ?? 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppThemeData.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (item.discountPrice != null && item.discountPrice! > 0)
                        Text(
                          Constant.amountShow(amount: item.price.toString()),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppThemeData.grey500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        Constant.amountShow(
                          amount: (item.discountPrice ?? item.price).toString(),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppThemeData.semiBold,
                          color: AppThemeData.grey900,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeData.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeData.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(
              fontSize: 16,
              fontFamily: AppThemeData.semiBold,
              color: AppThemeData.grey900,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Subtotal', order.subTotal?.toString() ?? '0'),
          _buildPriceRow('Delivery Fee', order.deliveryCharge?.toString() ?? '0'),
          _buildPriceRow('Tax', order.tax?.toString() ?? '0'),
          if (order.discount != null && order.discount! > 0)
            _buildPriceRow('Discount', '-${order.discount}', isDiscount: true),
          const Divider(height: 20),
          _buildPriceRow('Total', order.total?.toString() ?? '0', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontFamily: isTotal ? AppThemeData.semiBold : AppThemeData.regular,
              color: AppThemeData.grey900,
            ),
          ),
          Text(
            isDiscount ? amount : Constant.amountShow(amount: amount),
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontFamily: isTotal ? AppThemeData.semiBold : AppThemeData.regular,
              color: isDiscount ? AppThemeData.success300 : AppThemeData.grey900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order, OrderDetailsController controller) {
    return Column(
      children: [
        // Track Order Button (if order is active)
        if (_canTrackOrder(order.status))
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.navigateToTracking(),
              icon: const Icon(Icons.location_on),
              label: const Text('Track Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary300,
                foregroundColor: AppThemeData.grey900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        
        // Cancel Order Button (if order can be cancelled)
        if (_canCancelOrder(order.status)) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => controller.cancelOrder(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeData.danger300,
                side: BorderSide(color: AppThemeData.danger300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel Order'),
            ),
          ),
        ],
        
        // Reorder Button
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => controller.reorderItems(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reorder'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppThemeData.primary300,
              side: BorderSide(color: AppThemeData.primary300),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Order_Placed':
      case 'Order_Accepted':
        return AppThemeData.primary300;
      case 'Driver_Pending':
      case 'Driver_Accepted':
      case 'Order_Shipped':
      case 'In_Transit':
        return AppThemeData.warning300;
      case 'Order_Completed':
        return AppThemeData.success300;
      case 'Order_Rejected':
      case 'Order_Cancelled':
        return AppThemeData.danger300;
      default:
        return AppThemeData.grey500;
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

  bool _isStatusReached(String? currentStatus, String targetStatus) {
    const statusOrder = [
      'Order_Placed',
      'Order_Accepted',
      'Driver_Accepted',
      'Order_Shipped',
      'In_Transit',
      'Order_Completed',
    ];

    final currentIndex = statusOrder.indexOf(currentStatus ?? '');
    final targetIndex = statusOrder.indexOf(targetStatus);

    return currentIndex >= targetIndex && currentIndex != -1;
  }

  bool _canTrackOrder(String? status) {
    return status == 'Driver_Accepted' ||
           status == 'Order_Shipped' ||
           status == 'In_Transit';
  }

  bool _canCancelOrder(String? status) {
    return status == 'Order_Placed' ||
           status == 'Order_Accepted' ||
           status == 'Driver_Pending';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
