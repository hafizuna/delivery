import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constant/constant.dart';
import '../../../models/order_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/responsive.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/network_image_widget.dart';
import '../../../widget/my_separator.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final DarkThemeProvider themeChange;
  final VoidCallback? onTap;
  final VoidCallback? onTrackTap;
  final VoidCallback? onReorderTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.themeChange,
    this.onTap,
    this.onTrackTap,
    this.onReorderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: ShapeDecoration(
          color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Order Header
              Row(
                children: [
                  // Restaurant Image
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Stack(
                      children: [
                        NetworkImageWidget(
                          imageUrl: order.vendor?.photo ?? '',
                          fit: BoxFit.cover,
                          height: Responsive.height(10, context),
                          width: Responsive.width(20, context),
                        ),
                        Container(
                          height: Responsive.height(10, context),
                          width: Responsive.width(20, context),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: const Alignment(0.00, 1.00),
                              end: const Alignment(0, -1),
                              colors: [Colors.black.withOpacity(0), AppThemeData.grey900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Order Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Status
                        Text(
                          _getDisplayStatus(order.status),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        
                        // Restaurant Name
                        Text(
                          order.vendor?.title ?? 'Unknown Restaurant',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontFamily: AppThemeData.medium,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 5),
                        
                        // Order Date & Order ID
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderId ?? 'Order #${order.id?.substring(0, 8) ?? 'Unknown'}',
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontFamily: AppThemeData.medium,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              Constant.timestampToDateTime(order.createdAt!),
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontFamily: AppThemeData.medium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Order Items List
              if (order.items != null && order.items!.isNotEmpty)
                ListView.builder(
                  itemCount: order.items!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = order.items![index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${item.quantity} x ${item.productName}",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                fontFamily: AppThemeData.regular,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            Constant.amountShow(
                              amount: (item.discountPrice != null && item.discountPrice! > 0) 
                                  ? item.discountPrice!.toString() 
                                  : item.price.toString(),
                            ),
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              
              // Separator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: MySeparator(
                  color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                ),
              ),
              
              // Action Buttons Row
              Row(
                children: [
                  // Reorder Button (for completed orders)
                  if (order.status == 'Order_Completed' && onReorderTap != null)
                    Expanded(
                      child: InkWell(
                        onTap: onReorderTap,
                        child: Text(
                          "Reorder".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppThemeData.primary300,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  
                  // Track Order Button (for shipped/in transit orders)
                  if ((order.status == 'Order_Shipped' || order.status == 'In_Transit') && onTrackTap != null)
                    Expanded(
                      child: InkWell(
                        onTap: onTrackTap,
                        child: Text(
                          "Track Order".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppThemeData.primary300,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  
                  // View Details Button (always available)
                  Expanded(
                    child: InkWell(
                      onTap: onTap,
                      child: Text(
                        "View Details".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppThemeData.primary300,
                          fontFamily: AppThemeData.semiBold,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Order_Placed':
        return AppThemeData.primary300;
      case 'Order_Accepted':
        return Colors.blue;
      case 'Driver_Pending':
        return Colors.orange;
      case 'Driver_Accepted':
        return Colors.green;
      case 'Order_Shipped':
        return Colors.purple;
      case 'In_Transit':
        return Colors.indigo;
      case 'Order_Completed':
        return Colors.green;
      case 'Order_Cancelled':
        return Colors.red;
      case 'Order_Rejected':
        return Colors.red;
      case 'Driver_Rejected':
        return Colors.orange;
      default:
        return AppThemeData.grey600;
    }
  }

  String _getDisplayStatus(String status) {
    switch (status) {
      case 'Order_Placed':
        return 'Order Placed'.tr;
      case 'Order_Accepted':
        return 'Order Accepted'.tr;
      case 'Driver_Pending':
        return 'Finding Driver'.tr;
      case 'Driver_Accepted':
        return 'Driver Assigned'.tr;
      case 'Order_Shipped':
        return 'Order Shipped'.tr;
      case 'In_Transit':
        return 'In Transit'.tr;
      case 'Order_Completed':
        return 'Delivered'.tr;
      case 'Order_Cancelled':
        return 'Cancelled'.tr;
      case 'Order_Rejected':
        return 'Rejected'.tr;
      case 'Driver_Rejected':
        return 'Finding Driver'.tr;
      default:
        return status.tr;
    }
  }
}