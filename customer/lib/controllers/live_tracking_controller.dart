import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../constant/show_toast_dialog.dart';
import '../constant/constant.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class LiveTrackingController extends GetxController {
  late final ApiService _apiService;
  late final SocketService _socketService;
  
  // Observable properties
  RxBool isLoading = true.obs;
  Rx<OrderModel?> currentOrder = Rx<OrderModel?>(null);
  
  // Map properties
  GoogleMapController? _mapController;
  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> polylines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints();
  
  // Custom Icons
  BitmapDescriptor? restaurantIcon;
  BitmapDescriptor? customerIcon;
  BitmapDescriptor? bikerIcon;
  
  // Location properties
  Rx<LatLng> restaurantLocation = const LatLng(37.7749, -122.4194).obs;
  Rx<LatLng> driverLocation = const LatLng(37.7849, -122.4094).obs;
  Rx<LatLng> customerLocation = const LatLng(37.7649, -122.4294).obs;
  RxDouble driverRotation = 0.0.obs;
  
  // Driver info
  RxString driverName = ''.obs;
  RxString vehicleNumber = ''.obs;
  RxString driverPhone = ''.obs;
  RxString estimatedTime = '15-20 min'.obs;
  
  // Timer for location updates
  Timer? _locationUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize services
    try {
      _apiService = Get.find<ApiService>();
    } catch (e) {
      _apiService = ApiService();
      Get.put(_apiService);
    }
    
    try {
      _socketService = Get.find<SocketService>();
    } catch (e) {
      _socketService = SocketService();
      Get.put(_socketService);
    }
    
    _setupCustomIcons();
    _initializeLocationServices();
    setupSocketListeners();
  }

  @override
  void onClose() {
    _locationUpdateTimer?.cancel();
    _socketService.disconnect();
    super.onClose();
  }

  /// Setup custom map icons
  Future<void> _setupCustomIcons() async {
    try {
      // Load custom icons from assets
      final Uint8List restaurantIconBytes = await _getBytesFromAsset('assets/images/pickup.png', 100);
      final Uint8List customerIconBytes = await _getBytesFromAsset('assets/images/dropoff.png', 100);
      final Uint8List bikerIconBytes = await _getBytesFromAsset('assets/images/food_delivery.png', 60);
      
      restaurantIcon = BitmapDescriptor.fromBytes(restaurantIconBytes);
      customerIcon = BitmapDescriptor.fromBytes(customerIconBytes);
      bikerIcon = BitmapDescriptor.fromBytes(bikerIconBytes);
    } catch (error) {
      print('Error loading custom icons: $error');
      // Fallback to default markers if custom icons fail to load
      restaurantIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      customerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      bikerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }
  
  /// Helper method to convert asset to bytes
  Future<Uint8List> _getBytesFromAsset(String path, int size) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: size,
      targetHeight: size,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  /// Set the current order being tracked
  void setOrder(OrderModel order) {
    currentOrder.value = order;
    
    // Join this specific order for real-time updates
    _socketService.joinOrder(order.id!);
    
    // Initialize map data
    _initializeMapData();
    _startLocationUpdates();
  }

  /// Initialize location services and permissions
  Future<void> _initializeLocationServices() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle permission denied
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle permission permanently denied
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      customerLocation.value = LatLng(position.latitude, position.longitude);
      isLoading.value = false;
    } catch (error) {
      print('Error initializing location services: $error');
      isLoading.value = false;
    }
  }

  /// Initialize map data and markers
  void _initializeMapData() {
    if (currentOrder.value == null) return;

    // Set restaurant location (from order or mock data)
    if (currentOrder.value!.vendor?.location != null) {
      // Extract lat/lng from vendor location if available
      restaurantLocation.value = const LatLng(37.7749, -122.4194); // Use mock for now
    } else {
      restaurantLocation.value = const LatLng(37.7749, -122.4194);
    }
    
    // Set driver location (mock data - will be updated via Socket.IO)
    driverLocation.value = const LatLng(37.7849, -122.4094);

    // Wait for icons to load then create markers
    Future.delayed(const Duration(milliseconds: 500), () {
      _updateMarkersBasedOnStatus();
    });
  }

  /// Add marker to map with custom icon and rotation
  void _addMarker({
    required String id,
    required LatLng position,
    required BitmapDescriptor icon,
    required String title,
    String? snippet,
    double rotation = 0.0,
  }) {
    final markerId = MarkerId(id);
    final marker = Marker(
      markerId: markerId,
      position: position,
      icon: icon,
      rotation: rotation,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet ?? '',
      ),
    );
    markers[markerId] = marker;
  }

  /// Update markers based on order status (like original Firebase logic)
  void _updateMarkersBasedOnStatus() {
    if (currentOrder.value == null || bikerIcon == null) return;
    
    final order = currentOrder.value!;
    markers.clear();
    
    switch (order.status) {
      case 'Order_Shipped':
        // Driver going to restaurant - show driver and restaurant
        _addMarker(
          id: 'driver',
          position: driverLocation.value,
          icon: bikerIcon!,
          title: driverName.value.isEmpty ? 'Driver' : driverName.value,
          snippet: 'Heading to restaurant',
          rotation: driverRotation.value,
        );
        _addMarker(
          id: 'restaurant',
          position: restaurantLocation.value,
          icon: restaurantIcon!,
          title: order.vendor?.title ?? 'Restaurant',
          snippet: 'Pickup location',
        );
        _updatePolylineRoute(
          start: driverLocation.value,
          end: restaurantLocation.value,
        );
        break;
        
      case 'In_Transit':
        // Driver going to customer - show driver and customer
        _addMarker(
          id: 'driver',
          position: driverLocation.value,
          icon: bikerIcon!,
          title: driverName.value.isEmpty ? 'Driver' : driverName.value,
          snippet: 'On the way to you',
          rotation: driverRotation.value,
        );
        _addMarker(
          id: 'customer',
          position: customerLocation.value,
          icon: customerIcon!,
          title: 'You',
          snippet: 'Delivery location',
        );
        _updatePolylineRoute(
          start: driverLocation.value,
          end: customerLocation.value,
        );
        break;
        
      default:
        // Show restaurant and customer (before driver assignment)
        _addMarker(
          id: 'restaurant',
          position: restaurantLocation.value,
          icon: restaurantIcon!,
          title: order.vendor?.title ?? 'Restaurant',
          snippet: 'Pickup location',
        );
        _addMarker(
          id: 'customer',
          position: customerLocation.value,
          icon: customerIcon!,
          title: 'You',
          snippet: 'Delivery location',
        );
        _updatePolylineRoute(
          start: restaurantLocation.value,
          end: customerLocation.value,
        );
    }
  }

  /// Update polyline route with real navigation data
  Future<void> _updatePolylineRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      // Clear existing polylines
      polylines.clear();
      
      List<LatLng> polylineCoordinates = [];
      
      // Create polyline request for navigation route
      PolylineRequest polylineRequest = PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      );

      // Get route from Google Directions API (only if API key is available)
      if (Constant.mapAPIKey.isNotEmpty) {
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          request: polylineRequest,
          googleApiKey: Constant.mapAPIKey,
        );
        
        if (result.points.isNotEmpty) {
          // Convert points to LatLng coordinates
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        } else {
          // Fallback to simple line if API fails
          polylineCoordinates = [start, end];
          print('Polyline API error: ${result.errorMessage}');
        }
      } else {
        // Simple line fallback when no API key
        polylineCoordinates = [start, end];
        print('No Google Maps API key - using simple polyline');
      }

      // Create polyline
      const polylineId = PolylineId('route');
      final polyline = Polyline(
        polylineId: polylineId,
        points: polylineCoordinates,
        color: Colors.blue,
        width: 6,
        consumeTapEvents: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );
      
      polylines[polylineId] = polyline;
      
      // Update camera to show the route
      _updateCameraBounds(polylineCoordinates.first, polylineCoordinates.last);
      
    } catch (error) {
      print('Error updating polyline route: $error');
      // Fallback to simple line
      const polylineId = PolylineId('route');
      final polyline = Polyline(
        polylineId: polylineId,
        points: [start, end],
        color: Colors.blue,
        width: 4,
      );
      polylines[polylineId] = polyline;
    }
  }

  /// Called when map is created
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Fit all markers in view
    _fitMarkersInView();
  }

  /// Fit all markers in camera view
  void _fitMarkersInView() {
    if (_mapController == null || markers.isEmpty) return;

    // Calculate bounds from current markers
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = -double.infinity;
    double maxLng = -double.infinity;

    for (final marker in markers.values) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = lat < minLat ? lat : minLat;
      minLng = lng < minLng ? lng : minLng;
      maxLat = lat > maxLat ? lat : maxLat;
      maxLng = lng > maxLng ? lng : maxLng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  /// Update camera bounds to show route
  Future<void> _updateCameraBounds(LatLng source, LatLng destination) async {
    if (_mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(source.latitude, destination.longitude),
        northeast: LatLng(destination.latitude, source.longitude),
      );
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destination.latitude, source.longitude),
        northeast: LatLng(source.latitude, destination.longitude),
      );
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);
    await _mapController!.animateCamera(cameraUpdate);
  }

  /// Move camera to user's current location
  void moveToMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final newLocation = LatLng(position.latitude, position.longitude);
      customerLocation.value = newLocation;
      
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 16.0),
      );
      
      _updateMarkersBasedOnStatus();
    } catch (error) {
      print('Error getting current location: $error');
      ShowToastDialog.showToast('Failed to get current location');
    }
  }

  /// Zoom in on map
  void zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  /// Zoom out on map
  void zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  /// Call the driver
  void callDriver() async {
    try {
      final phoneNumber = driverPhone.value.isEmpty ? '+1234567890' : driverPhone.value;
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ShowToastDialog.showToast('Cannot make phone call');
      }
    } catch (error) {
      print('Error making phone call: $error');
      ShowToastDialog.showToast('Failed to make phone call');
    }
  }

  /// Setup Socket.IO listeners for real-time updates
  void setupSocketListeners() {
    // Listen for driver location updates
    _socketService.driverLocationStream.listen((data) {
      _handleDriverLocationUpdate(data);
    });

    // Listen for order status updates
    _socketService.orderStatusStream.listen((data) {
      _handleOrderStatusUpdate(data);
    });
  }

  /// Handle real-time driver location updates
  void _handleDriverLocationUpdate(Map<String, dynamic> data) {
    try {
      final orderId = data['orderId'];
      
      // Check if this update is for the current order
      if (currentOrder.value?.id == orderId) {
        final lat = data['latitude'] as double?;
        final lng = data['longitude'] as double?;
        final rotation = data['rotation'] as double?;
        
        if (lat != null && lng != null) {
          final oldLocation = driverLocation.value;
          final newLocation = LatLng(lat, lng);
          
          // Calculate rotation based on movement if not provided
          if (rotation != null) {
            driverRotation.value = rotation;
          } else {
            driverRotation.value = _calculateBearing(oldLocation, newLocation);
          }
          
          driverLocation.value = newLocation;
          _updateMarkersBasedOnStatus();
          
          // Update ETA if provided
          if (data['estimatedTime'] != null) {
            estimatedTime.value = data['estimatedTime'];
          }
        }
      }
    } catch (error) {
      print('Error handling driver location update: $error');
    }
  }
  
  /// Calculate bearing between two points for driver rotation
  double _calculateBearing(LatLng start, LatLng end) {
    final dLng = (end.longitude - start.longitude);
    final y = math.sin(dLng) * math.cos(end.latitude);
    final x = math.cos(start.latitude) * math.sin(end.latitude) -
        math.sin(start.latitude) * math.cos(end.latitude) * math.cos(dLng);
    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  /// Handle order status updates
  void _handleOrderStatusUpdate(Map<String, dynamic> data) {
    try {
      final orderId = data['orderId'];
      
      if (currentOrder.value?.id == orderId) {
        final updatedOrder = OrderModel.fromJson(data['order']);
        currentOrder.value = updatedOrder;
        
        // Update driver info if available
        if (data['driverInfo'] != null) {
          final driverInfo = data['driverInfo'];
          driverName.value = driverInfo['name'] ?? '';
          vehicleNumber.value = driverInfo['vehicleNumber'] ?? '';
          driverPhone.value = driverInfo['phone'] ?? '';
        }
      }
    } catch (error) {
      print('Error handling order status update: $error');
    }
  }

  /// Start periodic location updates
  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) => _requestDriverLocationUpdate(),
    );
  }

  /// Request driver location update via Socket.IO
  void _requestDriverLocationUpdate() {
    if (currentOrder.value?.id != null) {
      _socketService.requestDriverLocation(currentOrder.value!.id!);
    }
  }
}