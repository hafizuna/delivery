import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../address/address_list_screen.dart';
import 'select_payment_screen.dart';
import '../../controllers/address_controller.dart';
import '../../constant/constant.dart';

import '../../controllers/cart_controller.dart';
import '../../models/cart_product_model.dart';
import '../../themes/app_them_data.dart';
import '../../themes/responsive.dart';
import '../../utils/dark_theme_provider.dart';
import '../../utils/network_image_widget.dart';
import '../../widget/my_separator.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
              'Cart'.tr,
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                fontSize: 18,
                fontFamily: AppThemeData.semiBold,
              ),
            ),
            actions: [
              if (controller.cartItems.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text('Clear Cart'.tr),
                        content: Text('Are you sure you want to clear all items from cart?'.tr),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('Cancel'.tr),
                          ),
                          TextButton(
                            onPressed: () async {
                              await controller.clearCart();
                              Get.back();
                            },
                            child: Text('Clear'.tr),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Clear'.tr,
                    style: TextStyle(
                      color: AppThemeData.primary300,
                      fontFamily: AppThemeData.medium,
                    ),
                  ),
                ),
            ],
          ),
          body: controller.isCartEmpty
              ? _buildEmptyCart(themeChange)
              : _buildCartContent(controller, themeChange, context),
          bottomNavigationBar: controller.isCartEmpty
              ? null
              : _buildBottomBar(controller, themeChange, context),
        );
      },
    );
  }

  Widget _buildEmptyCart(DarkThemeProvider themeChange) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty'.tr,
            style: TextStyle(
              fontSize: 18,
              fontFamily: AppThemeData.semiBold,
              color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add items from restaurants to get started'.tr,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppThemeData.medium,
              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey500,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeData.primary300,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Browse Restaurants'.tr,
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

  Widget _buildCartContent(CartController controller, DarkThemeProvider themeChange, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address Selection Card
          _buildAddressSelector(controller, themeChange),
          
          // Cart Items List
          _buildCartItemsList(controller, themeChange, context),
          
          // Price Breakdown
          _buildPriceBreakdown(controller, themeChange),
          
          // Tips Selection
          _buildTipsSection(controller, themeChange),
          
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }


  Widget _buildCartItemsList(CartController controller, DarkThemeProvider themeChange, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: ShapeDecoration(
          color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Items (${controller.totalItemsCount})'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppThemeData.semiBold,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.cartItems.length,
                separatorBuilder: (context, index) => const Divider(height: 20),
                itemBuilder: (context, index) {
                  return _buildCartItem(controller.cartItems[index], controller, themeChange, context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartProductModel cartItem, CartController controller, DarkThemeProvider themeChange, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: NetworkImageWidget(
            imageUrl: cartItem.photo ?? '',
            height: Responsive.height(8, context),
            width: Responsive.width(18, context),
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        
        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cartItem.name ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppThemeData.medium,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              const SizedBox(height: 4),
              
              // Price
              Row(
                children: [
                  if (cartItem.discountPrice != null && double.parse(cartItem.discountPrice.toString()) > 0) ...[
                    Text(
                      '₹${cartItem.discountPrice}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppThemeData.semiBold,
                        color: AppThemeData.primary300,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '₹${cartItem.price}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: AppThemeData.medium,
                        color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ] else
                    Text(
                      '₹${cartItem.price}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppThemeData.semiBold,
                        color: AppThemeData.primary300,
                      ),
                    ),
                ],
              ),
              
              // Variants
              if (cartItem.variantInfo?.variantOptions != null && cartItem.variantInfo!.variantOptions!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: cartItem.variantInfo!.variantOptions!.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: AppThemeData.medium,
                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
        
        // Quantity Controls
        Container(
          decoration: BoxDecoration(
            color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  await controller.addToCart(
                    cartProductModel: cartItem,
                    isIncrement: false,
                    quantity: (cartItem.quantity ?? 1) - 1,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${cartItem.quantity}',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppThemeData.semiBold,
                    color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await controller.addToCart(
                    cartProductModel: cartItem,
                    isIncrement: true,
                    quantity: (cartItem.quantity ?? 0) + 1,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(CartController controller, DarkThemeProvider themeChange) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: ShapeDecoration(
          color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bill Details'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppThemeData.semiBold,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              const SizedBox(height: 15),
              
              _buildPriceRow('Subtotal'.tr, '₹${controller.subTotal.value.toStringAsFixed(2)}', themeChange),
              if (controller.deliveryCharges.value > 0)
                _buildPriceRow('Delivery Charges'.tr, '₹${controller.deliveryCharges.value.toStringAsFixed(2)}', themeChange),
              if (controller.couponAmount.value > 0)
                _buildPriceRow('Discount'.tr, '-₹${controller.couponAmount.value.toStringAsFixed(2)}', themeChange, isDiscount: true),
              if (controller.deliveryTips.value > 0)
                _buildPriceRow('Tips'.tr, '₹${controller.deliveryTips.value.toStringAsFixed(2)}', themeChange),
              
              const MySeparator(color: AppThemeData.grey300),
              const SizedBox(height: 10),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppThemeData.semiBold,
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    ),
                  ),
                  Text(
                    '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppThemeData.semiBold,
                      color: AppThemeData.primary300,
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

  Widget _buildPriceRow(String label, String amount, DarkThemeProvider themeChange, {bool isDiscount = false}) {
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

  Widget _buildTipsSection(CartController controller, DarkThemeProvider themeChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: ShapeDecoration(
          color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Tips for Delivery Partner'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppThemeData.semiBold,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildTipButton('₹20', 20, controller, themeChange),
                  const SizedBox(width: 8),
                  _buildTipButton('₹30', 30, controller, themeChange),
                  const SizedBox(width: 8),
                  _buildTipButton('₹50', 50, controller, themeChange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipButton(String label, double amount, CartController controller, DarkThemeProvider themeChange) {
    bool isSelected = controller.deliveryTips.value == amount;
    
    return InkWell(
      onTap: () => controller.setDeliveryTips(isSelected ? 0 : amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppThemeData.primary300 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected 
                ? AppThemeData.primary300 
                : (themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: AppThemeData.medium,
            color: isSelected 
                ? AppThemeData.grey50 
                : (themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(CartController controller, DarkThemeProvider themeChange, BuildContext context) {
    return Container(
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: AppThemeData.semiBold,
                      color: AppThemeData.primary300,
                    ),
                  ),
                  Text(
                    '${controller.totalItemsCount} items'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: AppThemeData.medium,
                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to payment selection screen
                Get.to(() => const SelectPaymentScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeData.primary300,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Proceed to Checkout'.tr,
                style: const TextStyle(
                  color: AppThemeData.grey50,
                  fontFamily: AppThemeData.medium,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelector(CartController controller, DarkThemeProvider themeChange) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GetBuilder<AddressController>(
        init: AddressController(),
        builder: (addressController) {
          final selectedAddress = Constant.selectedLocation;
          
          return InkWell(
            onTap: () {
              Get.to(() => const AddressListScreen())?.then((address) {
                if (address != null) {
                  Constant.selectedLocation = address;
                  controller.calculatePrice(); // Recalculate delivery charges
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: ShapeDecoration(
                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppThemeData.primary300.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: AppThemeData.primary300,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Address'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: AppThemeData.medium,
                                  color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedAddress.addressAs.isNotEmpty 
                                    ? selectedAddress.addressAs 
                                    : 'Select Address'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppThemeData.semiBold,
                                  color: AppThemeData.primary300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                        ),
                      ],
                    ),
                    if (selectedAddress.address.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: Text(
                          selectedAddress.address,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppThemeData.medium,
                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: Text(
                          'Tap to select your delivery address'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: AppThemeData.medium,
                            color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
