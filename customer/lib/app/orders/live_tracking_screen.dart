import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constant/constant.dart';
import '../../models/order_model.dart';
import '../../controllers/live_tracking_controller.dart';
import '../../themes/app_them_data.dart';
import '../../utils/network_image_widget.dart';

class LiveTrackingScreen extends StatelessWidget {
  final OrderModel order;
  
  const LiveTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveTrackingController());
    controller.setOrder(order);

    return Scaffold(
      backgroundColor: AppThemeData.grey50,
      appBar: AppBar(
        backgroundColor: AppThemeData.primary300,
        title: Text(
          'Track Order',
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

        return Stack(
          children: [
            // Google Map
            GoogleMap(
              onMapCreated: (GoogleMapController mapController) {
                controller.onMapCreated(mapController);
              },
              initialCameraPosition: CameraPosition(
                target: controller.restaurantLocation.value,
                zoom: 14.0,
              ),
              markers: Set<Marker>.of(controller.markers.values),
              polylines: Set<Polyline>.of(controller.polylines.values),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            
            // Bottom Sheet with Order Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomSheet(controller),
            ),
            
            // Custom Controls
            Positioned(
              top: 16,
              right: 16,
              child: _buildMapControls(controller),
            ),
            
            // ETA Card
            Positioned(
              top: 16,
              left: 16,
              child: _buildETACard(controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBottomSheet(LiveTrackingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeData.grey50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppThemeData.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Driver Info
            Row(
              children: [
                // Driver Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppThemeData.primary300,
                  child: Icon(
                    Icons.person,
                    color: AppThemeData.grey900,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Driver Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.driverName.value.isEmpty 
                            ? 'Driver' 
                            : controller.driverName.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: AppThemeData.semiBold,
                          color: AppThemeData.grey900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppThemeData.warning300,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppThemeData.grey600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppThemeData.grey600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.vehicleNumber.value.isEmpty 
                                ? 'ABC-1234' 
                                : controller.vehicleNumber.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppThemeData.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Call Button
                IconButton(
                  onPressed: () => controller.callDriver(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppThemeData.primary300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone,
                      color: AppThemeData.grey900,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Order Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(order.status),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppThemeData.medium,
                  color: _getStatusColor(order.status),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Restaurant Info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageWidget(
                    imageUrl: order.vendor?.photo ?? '',
                    width: 50,
                    height: 50,
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
                      Text(
                        'Order #${order.orderId ?? order.id?.substring(0, 8) ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppThemeData.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Constant.amountShow(amount: order.total?.toString() ?? '0'),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: AppThemeData.semiBold,
                    color: AppThemeData.grey900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls(LiveTrackingController controller) {
    return Column(
      children: [
        // My Location Button
        FloatingActionButton.small(
          onPressed: () => controller.moveToMyLocation(),
          backgroundColor: AppThemeData.grey50,
          child: Icon(
            Icons.my_location,
            color: AppThemeData.grey900,
          ),
        ),
        const SizedBox(height: 8),
        
        // Zoom In
        FloatingActionButton.small(
          onPressed: () => controller.zoomIn(),
          backgroundColor: AppThemeData.grey50,
          child: Icon(
            Icons.add,
            color: AppThemeData.grey900,
          ),
        ),
        const SizedBox(height: 8),
        
        // Zoom Out
        FloatingActionButton.small(
          onPressed: () => controller.zoomOut(),
          backgroundColor: AppThemeData.grey50,
          child: Icon(
            Icons.remove,
            color: AppThemeData.grey900,
          ),
        ),
      ],
    );
  }

  Widget _buildETACard(LiveTrackingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeData.primary300,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: AppThemeData.grey900,
          ),
          const SizedBox(width: 6),
          Text(
            controller.estimatedTime.value.isEmpty 
                ? '15-20 min' 
                : controller.estimatedTime.value,
            style: TextStyle(
              fontSize: 12,
              fontFamily: AppThemeData.medium,
              color: AppThemeData.grey900,
            ),
          ),
        ],
      ),
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
        return 'Restaurant Preparing';
      case 'Driver_Pending':
        return 'Finding Driver';
      case 'Driver_Accepted':
        return 'Driver On The Way to Restaurant';
      case 'Order_Shipped':
        return 'Order Picked Up';
      case 'In_Transit':
        return 'On The Way to You';
      case 'Order_Completed':
        return 'Delivered';
      case 'Order_Rejected':
        return 'Order Rejected';
      case 'Order_Cancelled':
        return 'Order Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }
}
