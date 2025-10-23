import 'package:customer/controllers/location_permission_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LocationPermissionController>(
      init: LocationPermissionController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            title: Text(
              "Select Location".tr,
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                fontFamily: AppThemeData.semiBold,
              ),
            ),
          ),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Map
                    Expanded(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: controller.currentLocation.value,
                          zoom: 15,
                        ),
                        onTap: (LatLng location) {
                          controller.updateLocation(location);
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: controller.currentLocation.value,
                            draggable: true,
                            onDragEnd: (LatLng location) {
                              controller.updateLocation(location);
                            },
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                      ),
                    ),
                    
                    // Address Info & Confirm Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Delivery Location".tr,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontSize: 18,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppThemeData.primary300,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.currentAddress.value.isEmpty
                                      ? "Fetching address...".tr
                                      : controller.currentAddress.value,
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                                    fontSize: 14,
                                    fontFamily: AppThemeData.regular,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RoundedButtonFill(
                            title: "Confirm Location".tr,
                            color: AppThemeData.primary300,
                            textColor: AppThemeData.grey50,
                            onPress: controller.saveLocationAndContinue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
