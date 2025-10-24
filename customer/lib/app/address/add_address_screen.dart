import 'package:customer/controllers/address_controller.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddAddressScreen extends StatefulWidget {
  final ShippingAddress? addressToEdit;
  
  const AddAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  bool get isEditing => widget.addressToEdit != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (isEditing && widget.addressToEdit != null) {
      final address = widget.addressToEdit!;
      _addressController.text = address.address;
      _localityController.text = address.locality;
      _landmarkController.text = address.landmark ?? '';
      
      // Set location and address type in controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = Get.find<AddressController>();
        controller.selectedLocation.value = LatLng(address.latitude, address.longitude);
        controller.selectedAddressType.value = address.addressAs;
        controller.currentAddress.value = address.address;
        _updateMapMarker(LatLng(address.latitude, address.longitude));
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _localityController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _initializeMapMarker();
  }

  void _initializeMapMarker() {
    final addressController = Get.find<AddressController>();
    final location = addressController.selectedLocation.value;
    _updateMapMarker(location);
  }

  void _updateMapMarker(LatLng location) {
    if (mounted) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: location,
            draggable: true,
            onDragEnd: (LatLng newLocation) {
              final controller = Get.find<AddressController>();
              controller.updateSelectedLocation(newLocation);
            },
            infoWindow: const InfoWindow(
              title: 'Delivery Location',
              snippet: 'Drag to adjust location',
            ),
          ),
        };
      });
    }
    
    // Move camera to location
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 16.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    
    return GetX<AddressController>(
      init: AddressController(),
      builder: (controller) {
        // Schedule map update after build
        if (_mapController != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateMapMarker(controller.selectedLocation.value);
          });
        }
        
        // Schedule address field update after build
        if (controller.currentAddress.value.isNotEmpty && 
            _addressController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _addressController.text = controller.currentAddress.value;
          });
        }

        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            title: Text(
              isEditing ? 'Edit Address'.tr : 'Add Address'.tr,
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                fontSize: 18,
                fontFamily: AppThemeData.semiBold,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                // Map Section
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: controller.selectedLocation.value,
                        zoom: 16.0,
                      ),
                      markers: _markers,
                      onTap: (LatLng location) {
                        controller.updateSelectedLocation(location);
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                  ),
                ),
                
                // Form Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location hint
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppThemeData.primary300.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppThemeData.primary300.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppThemeData.primary300,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Drag the marker to set your exact delivery location'.tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                    color: AppThemeData.primary300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Address Type Selection
                        Text(
                          'Address Type'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppThemeData.semiBold,
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            _buildAddressTypeButton('Home', Icons.home, controller, themeChange),
                            const SizedBox(width: 8),
                            _buildAddressTypeButton('Work', Icons.work, controller, themeChange),
                            const SizedBox(width: 8),
                            _buildAddressTypeButton('Other', Icons.location_on, controller, themeChange),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Address Field
                        TextFieldWidget(
                          title: 'Address'.tr,
                          controller: _addressController,
                          hintText: 'Enter your full address'.tr,
                          maxLine: 2,
                          textInputType: TextInputType.streetAddress,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Locality Field
                        TextFieldWidget(
                          title: 'Area/Locality'.tr,
                          controller: _localityController,
                          hintText: 'Enter area or locality'.tr,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Landmark Field (Optional)
                        TextFieldWidget(
                          title: 'Landmark (Optional)'.tr,
                          controller: _landmarkController,
                          hintText: 'Near landmark or building'.tr,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Set as Default Checkbox
                        Row(
                          children: [
                            Obx(() => Checkbox(
                              value: isEditing 
                                  ? widget.addressToEdit!.isDefault 
                                  : (controller.addresses.isEmpty), // First address is always default
                              onChanged: isEditing && !widget.addressToEdit!.isDefault 
                                  ? (value) {
                                      // Allow changing default only in edit mode
                                      widget.addressToEdit!.isDefault = value ?? false;
                                      setState(() {});
                                    }
                                  : null, // Disabled for new addresses (auto-default if first)
                              activeColor: AppThemeData.primary300,
                            )),
                            Expanded(
                              child: Text(
                                controller.addresses.isEmpty
                                    ? 'This will be your default address'.tr
                                    : 'Set as default address'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: AppThemeData.medium,
                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
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
              child: Obx(() => RoundedButtonFill(
                title: isEditing ? 'Update Address'.tr : 'Save Address'.tr,
                height: 5.5,
                color: AppThemeData.primary300,
                textColor: AppThemeData.grey50,
                fontSizes: 16,
                isEnabled: !controller.isLoading.value,
                onPress: controller.isLoading.value ? null : () => _saveAddress(controller),
              )),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressTypeButton(String type, IconData icon, AddressController controller, DarkThemeProvider themeChange) {
    return Expanded(
      child: Obx(() => InkWell(
        onTap: () => controller.setAddressType(type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: controller.selectedAddressType.value == type
                ? AppThemeData.primary300
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.selectedAddressType.value == type
                  ? AppThemeData.primary300
                  : (themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey300),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: controller.selectedAddressType.value == type
                    ? AppThemeData.grey50
                    : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                type.tr,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: AppThemeData.medium,
                  color: controller.selectedAddressType.value == type
                      ? AppThemeData.grey50
                      : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  void _saveAddress(AddressController controller) async {
    if (!_formKey.currentState!.validate()) return;
    
    final address = _addressController.text.trim();
    final locality = _localityController.text.trim();
    final landmark = _landmarkController.text.trim();
    final location = controller.selectedLocation.value;
    final addressType = controller.selectedAddressType.value;
    
    if (isEditing && widget.addressToEdit != null) {
      // Update existing address
      await controller.updateAddress(
        addressId: widget.addressToEdit!.id!,
        address: address,
        addressAs: addressType,
        locality: locality,
        landmark: landmark.isEmpty ? null : landmark,
        latitude: location.latitude,
        longitude: location.longitude,
        isDefault: widget.addressToEdit!.isDefault,
      );
    } else {
      // Add new address
      await controller.addAddress(
        address: address,
        addressAs: addressType,
        locality: locality,
        landmark: landmark.isEmpty ? null : landmark,
        latitude: location.latitude,
        longitude: location.longitude,
        isDefault: controller.addresses.isEmpty, // First address is default
      );
    }
  }
}