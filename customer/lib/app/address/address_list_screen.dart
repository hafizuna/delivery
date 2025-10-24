import 'package:customer/app/address/add_address_screen.dart';
import 'package:customer/controllers/address_controller.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    
    return GetX<AddressController>(
      init: AddressController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            title: Text(
              'Select Address'.tr,
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                fontSize: 18,
                fontFamily: AppThemeData.semiBold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Get.to(() => const AddAddressScreen());
                },
                icon: Icon(
                  Icons.add,
                  color: AppThemeData.primary300,
                ),
              ),
            ],
          ),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.addresses.isEmpty
                  ? _buildEmptyState(themeChange)
                  : _buildAddressList(controller, themeChange, context),
          bottomNavigationBar: controller.addresses.isNotEmpty
              ? _buildAddNewAddressButton(themeChange)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(DarkThemeProvider themeChange) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
          ),
          const SizedBox(height: 20),
          Text(
            'No addresses saved'.tr,
            style: TextStyle(
              fontSize: 18,
              fontFamily: AppThemeData.semiBold,
              color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add your first address to get started'.tr,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppThemeData.medium,
              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey500,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Get.to(() => const AddAddressScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeData.primary300,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.add_location,
              color: AppThemeData.grey50,
            ),
            label: Text(
              'Add Address'.tr,
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

  Widget _buildAddressList(AddressController controller, DarkThemeProvider themeChange, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.addresses.length,
      itemBuilder: (context, index) {
        final address = controller.addresses[index];
        final isSelected = controller.selectedAddress.value.id == address.id;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => controller.selectAddress(address),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppThemeData.primary300 
                      : (themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey300),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Address type icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppThemeData.primary300.withOpacity(0.1)
                                : (themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getAddressIcon(address.addressAs),
                            color: isSelected 
                                ? AppThemeData.primary300 
                                : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Address type and default badge
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                address.addressAs,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppThemeData.semiBold,
                                  color: isSelected
                                      ? AppThemeData.primary300
                                      : (themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                                ),
                              ),
                              if (address.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppThemeData.primary300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Default'.tr,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: AppThemeData.medium,
                                      color: AppThemeData.grey50,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // More options menu
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Get.to(() => AddAddressScreen(addressToEdit: address));
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(address, controller, context);
                            } else if (value == 'default') {
                              await controller.setAsDefault(address.id!);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Edit'.tr),
                                ],
                              ),
                            ),
                            if (!address.isDefault)
                              PopupMenuItem(
                                value: 'default',
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_border, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Set as Default'.tr),
                                  ],
                                ),
                              ),
                            if (controller.addresses.length > 1)
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red[600]),
                                    const SizedBox(width: 8),
                                    Text('Delete'.tr, style: TextStyle(color: Colors.red[600])),
                                  ],
                                ),
                              ),
                          ],
                          icon: Icon(
                            Icons.more_vert,
                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Full address
                    Text(
                      address.address,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppThemeData.medium,
                        color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                      ),
                    ),
                    
                    if (address.landmark != null && address.landmark!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Near ${address.landmark}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: AppThemeData.medium,
                          color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey500,
                        ),
                      ),
                    ],
                    
                    if (isSelected) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppThemeData.primary300.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppThemeData.primary300, width: 1),
                        ),
                        child: Text(
                          'Selected for delivery'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: AppThemeData.medium,
                            color: AppThemeData.primary300,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddNewAddressButton(DarkThemeProvider themeChange) {
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
        child: ElevatedButton.icon(
          onPressed: () {
            Get.to(() => const AddAddressScreen());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppThemeData.primary300,
            side: BorderSide(color: AppThemeData.primary300, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.add_location),
          label: Text(
            'Add New Address'.tr,
            style: TextStyle(
              fontFamily: AppThemeData.medium,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAddressIcon(String addressType) {
    switch (addressType.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  void _showDeleteConfirmation(ShippingAddress address, AddressController controller, BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Address'.tr),
        content: Text('Are you sure you want to delete this address?'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteAddress(address.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'.tr),
          ),
        ],
      ),
    );
  }
}