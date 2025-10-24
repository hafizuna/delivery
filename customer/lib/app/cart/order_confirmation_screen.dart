import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/app/orders/live_tracking_screen.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final String paymentMethod;
  
  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Success Animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 60,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Success Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Order Placed Successfully!'.tr,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: AppThemeData.semiBold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Your order has been confirmed and is being prepared'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: AppThemeData.medium,
                        color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Order Details Card
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: ShapeDecoration(
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details'.tr,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: AppThemeData.semiBold,
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('Order ID'.tr, widget.orderId, themeChange),
                        _buildDetailRow('Total Amount'.tr, '₹${widget.totalAmount.toStringAsFixed(2)}', themeChange),
                        _buildDetailRow('Payment Method'.tr, _getPaymentMethodName(widget.paymentMethod), themeChange),
                        _buildDetailRow('Estimated Delivery'.tr, '30-45 minutes', themeChange),
                        
                        const SizedBox(height: 16),
                        
                        // Delivery Address
                        Text(
                          'Delivery Address'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppThemeData.medium,
                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${Constant.selectedLocation.addressAs} - ${Constant.selectedLocation.address}',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppThemeData.medium,
                            color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Action Buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Track Order Button
                    RoundedButtonFill(
                      title: 'Track Your Order'.tr,
                      height: 5.5,
                      color: AppThemeData.primary300,
                      textColor: AppThemeData.grey50,
                      fontSizes: 16,
                      onPress: () {
                        _navigateToLiveTracking();
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Back to Home Button
                    InkWell(
                      onTap: () {
                        // Navigate to dashboard and reset to home tab
                        Get.offAll(() => const DashBoardScreen());
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppThemeData.primary300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Continue Shopping'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppThemeData.medium,
                            color: AppThemeData.primary300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, DarkThemeProvider themeChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppThemeData.medium,
                color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppThemeData.medium,
                color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey800,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'wallet':
        return 'Wallet'.tr;
      case 'cod':
        return 'Cash on Delivery'.tr;
      default:
        return method;
    }
  }

  void _navigateToLiveTracking() {
    try {
      // Create a minimal order model for tracking
      final orderModel = OrderModel(
        id: widget.orderId,
        customerId: 'current-user', // Will be replaced with actual user ID
        vendorId: 'unknown',
        subtotal: widget.totalAmount,
        totalAmount: widget.totalAmount,
        paymentMethod: widget.paymentMethod,
        status: 'Order_Placed', // Initial status
        vendor: VendorModel(
          id: 'unknown',
          title: 'Restaurant',
          latitude: 0.0,
          longitude: 0.0,
          location: 'Restaurant Location',
          phoneNumber: '',
          categoryId: '',
          zoneId: '',
        ),
      );

      // Navigate to live tracking screen
      Get.to(() => LiveTrackingScreen(order: orderModel));
    } catch (error) {
      print('Error navigating to live tracking: $error');
      ShowToastDialog.showToast('Unable to open tracking. Please try from orders screen.');
    }
  }
}
