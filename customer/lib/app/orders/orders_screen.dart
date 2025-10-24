import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import 'order_details_screen.dart';
import 'live_tracking_screen.dart';
import 'widgets/order_card.dart';
import '../../constant/constant.dart';
import '../../controllers/orders_controller.dart';
import '../../themes/app_them_data.dart';
import '../../themes/responsive.dart';
import '../../utils/dark_theme_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    
    return GetX<OrdersController>(
      init: OrdersController(),
      builder: (controller) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
            child: controller.isLoading.value
                ? Constant.loader()
                : Constant.userModel == null
                    ? _buildLoginPrompt(themeChange)
                    : _buildOrderHistory(controller, themeChange, context),
          ),
        );
      },
    );
  }

  Widget _buildLoginPrompt(DarkThemeProvider themeChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/login.gif",
            height: 120,
          ),
          const SizedBox(height: 12),
          Text(
            "Please Log In to Continue".tr,
            style: TextStyle(
              color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
              fontSize: 22,
              fontFamily: AppThemeData.semiBold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "You're not logged in. Please sign in to access your account and explore all features.".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500,
              fontSize: 16,
              fontFamily: AppThemeData.regular,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.offAll(() => const LoginScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeData.primary300,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Log in".tr,
              style: const TextStyle(
                color: AppThemeData.grey50,
                fontFamily: AppThemeData.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistory(OrdersController controller, DarkThemeProvider themeChange, BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Orders".tr,
                        style: TextStyle(
                          fontSize: 24,
                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          fontFamily: AppThemeData.semiBold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Keep track your delivered, In Progress and Rejected food all in just one place.".tr,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          fontFamily: AppThemeData.regular,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          // Tab Bar and Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: ShapeDecoration(
                      color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(120),
                      ),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppThemeData.primary300,
                      ),
                      labelColor: AppThemeData.grey50,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorWeight: 0.5,
                      unselectedLabelColor: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Tab(text: 'All'.tr),
                        ),
                        Tab(text: 'In Progress'.tr),
                        Tab(text: 'Delivered'.tr),
                        Tab(text: 'Rejected'.tr),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Tab Bar View
                  Expanded(
                    child: TabBarView(
                      children: [
                        // All Orders
                        _buildOrderList(
                          controller.allOrders,
                          controller,
                          themeChange,
                          context,
                          () => controller.getOrders(),
                        ),
                        
                        // In Progress Orders
                        _buildOrderList(
                          controller.inProgressOrders,
                          controller,
                          themeChange,
                          context,
                          () => controller.getOrders(),
                        ),
                        
                        // Delivered Orders
                        _buildOrderList(
                          controller.deliveredOrders,
                          controller,
                          themeChange,
                          context,
                          () => controller.getOrders(),
                        ),
                        
                        // Rejected Orders
                        _buildOrderList(
                          controller.rejectedOrders,
                          controller,
                          themeChange,
                          context,
                          () => controller.getOrders(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    RxList orders,
    OrdersController controller,
    DarkThemeProvider themeChange,
    BuildContext context,
    Future<void> Function() onRefresh,
  ) {
    if (orders.isEmpty) {
      return Constant.showEmptyView(message: "Order Not Found".tr);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: orders.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            themeChange: themeChange,
            onTap: () => _navigateToOrderDetails(order),
            onTrackTap: () => _navigateToLiveTracking(order),
            onReorderTap: () => _reorderItems(controller, order),
          );
        },
      ),
    );
  }

  void _navigateToOrderDetails(order) {
    Get.to(() => OrderDetailsScreen(order: order));
  }

  void _navigateToLiveTracking(order) {
    Get.to(() => LiveTrackingScreen(order: order));
  }

  void _reorderItems(OrdersController controller, order) {
    // Implement reorder functionality
    controller.reorderItems(order);
  }
}