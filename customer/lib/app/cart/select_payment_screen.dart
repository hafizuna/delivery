import 'package:customer/app/cart/order_confirmation_screen.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SelectPaymentScreen extends StatefulWidget {
  const SelectPaymentScreen({super.key});

  @override
  State<SelectPaymentScreen> createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen> {
  String selectedPaymentMethod = '';

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    
    return GetX<CartController>(
      init: CartController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            title: Text(
              'Select Payment Method'.tr,
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                fontSize: 18,
                fontFamily: AppThemeData.semiBold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary Card
                _buildOrderSummary(controller, themeChange),
                
                const SizedBox(height: 20),
                
                // Payment Methods
                Text(
                  'Payment Methods'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: AppThemeData.semiBold,
                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Wallet Payment Option
                _buildWalletOption(controller, themeChange),
                
                const SizedBox(height: 12),
                
                // COD Payment Option
                _buildCODOption(themeChange),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: RoundedButtonFill(
                title: 'Place Order • ₹${controller.totalAmount.value.toStringAsFixed(2)}'.tr,
                height: 5.5,
                color: selectedPaymentMethod.isNotEmpty 
                    ? AppThemeData.primary300 
                    : AppThemeData.grey400,
                textColor: AppThemeData.grey50,
                fontSizes: 16,
                isEnabled: selectedPaymentMethod.isNotEmpty && !controller.isLoading.value,
                onPress: selectedPaymentMethod.isNotEmpty && !controller.isLoading.value 
                    ? () => _placeOrder(controller) 
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(CartController controller, DarkThemeProvider themeChange) {
    return Container(
      decoration: ShapeDecoration(
        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary'.tr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppThemeData.semiBold,
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildSummaryRow('Items (${controller.totalItemsCount})'.tr, 
                '₹${controller.subTotal.value.toStringAsFixed(2)}', themeChange),
            
            if (controller.deliveryCharges.value > 0)
              _buildSummaryRow('Delivery Charges'.tr, 
                  '₹${controller.deliveryCharges.value.toStringAsFixed(2)}', themeChange),
            
            if (controller.couponAmount.value > 0)
              _buildSummaryRow('Discount'.tr, 
                  '-₹${controller.couponAmount.value.toStringAsFixed(2)}', themeChange, isDiscount: true),
            
            if (controller.deliveryTips.value > 0)
              _buildSummaryRow('Tips'.tr, 
                  '₹${controller.deliveryTips.value.toStringAsFixed(2)}', themeChange),
            
            const Divider(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: AppThemeData.semiBold,
                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                  ),
                ),
                Text(
                  '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: AppThemeData.semiBold,
                    color: AppThemeData.primary300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, DarkThemeProvider themeChange, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppThemeData.medium,
              color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppThemeData.medium,
              color: isDiscount 
                  ? Colors.green
                  : (themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOption(CartController controller, DarkThemeProvider themeChange) {
    final walletBalance = Constant.userModel?.walletAmount ?? 0.0;
    final totalAmount = controller.totalAmount.value;
    final isInsufficientBalance = walletBalance < totalAmount;
    
    return InkWell(
      onTap: isInsufficientBalance ? null : () {
        setState(() {
          selectedPaymentMethod = 'wallet';
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPaymentMethod == 'wallet' 
                ? AppThemeData.primary300 
                : (isInsufficientBalance 
                    ? Colors.red.withOpacity(0.5)
                    : (themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey300)),
            width: selectedPaymentMethod == 'wallet' ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isInsufficientBalance 
                      ? Colors.red.withOpacity(0.1)
                      : (selectedPaymentMethod == 'wallet' 
                          ? AppThemeData.primary300.withOpacity(0.1)
                          : (themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: isInsufficientBalance 
                      ? Colors.red
                      : (selectedPaymentMethod == 'wallet' 
                          ? AppThemeData.primary300
                          : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600)),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: AppThemeData.semiBold,
                        color: isInsufficientBalance 
                            ? Colors.red
                            : (selectedPaymentMethod == 'wallet'
                                ? AppThemeData.primary300
                                : (themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Balance: ₹${walletBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppThemeData.medium,
                        color: isInsufficientBalance 
                            ? Colors.red
                            : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600),
                      ),
                    ),
                    if (isInsufficientBalance) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Insufficient balance. Need ₹${(totalAmount - walletBalance).toStringAsFixed(2)} more.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: AppThemeData.medium,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              if (isInsufficientBalance)
                TextButton(
                  onPressed: () {
                    // Navigate to wallet top-up screen
                    ShowToastDialog.showToast('Wallet top-up feature coming soon!'.tr);
                  },
                  child: Text(
                    'Top Up'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppThemeData.medium,
                      color: AppThemeData.primary300,
                    ),
                  ),
                )
              else if (selectedPaymentMethod == 'wallet')
                Icon(
                  Icons.check_circle,
                  color: AppThemeData.primary300,
                  size: 24,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCODOption(DarkThemeProvider themeChange) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = 'cod';
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPaymentMethod == 'cod' 
                ? AppThemeData.primary300 
                : (themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey300),
            width: selectedPaymentMethod == 'cod' ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedPaymentMethod == 'cod' 
                      ? AppThemeData.primary300.withOpacity(0.1)
                      : (themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.money,
                  color: selectedPaymentMethod == 'cod' 
                      ? AppThemeData.primary300
                      : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash on Delivery'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: AppThemeData.semiBold,
                        color: selectedPaymentMethod == 'cod'
                            ? AppThemeData.primary300
                            : (themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pay cash to delivery partner'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppThemeData.medium,
                        color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                selectedPaymentMethod == 'cod' 
                    ? Icons.check_circle 
                    : Icons.radio_button_unchecked,
                color: selectedPaymentMethod == 'cod' 
                    ? AppThemeData.primary300
                    : (themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _placeOrder(CartController controller) async {
    // Validate cart and address using controller method
    if (!controller.validateOrder()) {
      return;
    }
    
    if (selectedPaymentMethod.isEmpty) {
      ShowToastDialog.showToast('Please select payment method'.tr);
      return;
    }
    
    // Additional wallet balance check
    if (selectedPaymentMethod == 'wallet') {
      final walletBalance = Constant.userModel?.walletAmount ?? 0.0;
      if (walletBalance < controller.totalAmount.value) {
        ShowToastDialog.showToast('Insufficient wallet balance'.tr);
        return;
      }
    }
    
    try {
      // Show loading
      ShowToastDialog.showLoader('Placing order...'.tr);
      
      // Place order using cart controller
      bool success = await controller.placeOrder(
        paymentMethod: selectedPaymentMethod,
        deliveryAddress: Constant.selectedLocation,
      );
      
      // Close loading
      ShowToastDialog.closeLoader();
      
      if (!success) {
        // Error handling is done in the controller
        return;
      }
      
      // Success case is handled in controller (navigation to confirmation screen)
      
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Failed to place order. Please try again.'.tr);
    }
  }
}