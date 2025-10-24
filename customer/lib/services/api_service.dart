import 'dart:io';
import 'package:dio/dio.dart';
import 'package:customer/config/app_config.dart';
import 'package:customer/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final StorageService _storage = StorageService();
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token = await _storage.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          if (kDebugMode) {
            print('🌐 REQUEST[${options.method}] => ${options.uri}');
            print('📤 Headers: ${options.headers}');
            if (options.data != null) {
              print('📦 Data: ${options.data}');
            }
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
            print('📥 Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
            print('💥 Message: ${error.message}');
            print('📛 Response: ${error.response?.data}');
          }
          
          // Handle 401 Unauthorized - refresh token
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the request
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read('refreshToken');
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        AppConfig.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refreshToken'];
        
        await _storage.write('token', newToken);
        await _storage.write('refreshToken', newRefreshToken);
        
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Token refresh failed: $e');
      }
      return false;
    }
  }
  
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
  
  // ============== GENERIC REQUEST METHOD ==============
  
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // ============== AUTH ENDPOINTS ==============
  
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String countryCode,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final response = await _dio.post(
        AppConfig.loginEndpoint,
        data: {
          'phoneNumber': phoneNumber,
          'countryCode': countryCode,
          'password': password,
          'fcmToken': fcmToken,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String countryCode,
    required String password,
    required String firstName,
    required String lastName,
    String? email,
    String? fcmToken,
  }) async {
    try {
      final response = await _dio.post(
        AppConfig.registerEndpoint,
        data: {
          'phoneNumber': phoneNumber,
          'countryCode': countryCode,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'fcmToken': fcmToken,
          'role': 'customer',
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      await _dio.post(AppConfig.logoutEndpoint);
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }
  }
  
  // ============== USER ENDPOINTS ==============
  
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get(AppConfig.userProfileEndpoint);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(AppConfig.updateProfileEndpoint, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dio.post(AppConfig.updateFcmTokenEndpoint, data: {'fcmToken': fcmToken});
    } catch (e) {
      if (kDebugMode) {
        print('Update FCM token error: $e');
      }
    }
  }
  
  // ============== VENDOR ENDPOINTS ==============
  
  Future<List<dynamic>> getVendors({
    double? latitude,
    double? longitude,
    String? radius,
    String? categoryId,
  }) async {
    try {
      final response = await _dio.get(
        AppConfig.vendorsEndpoint,
        queryParameters: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (radius != null) 'radius': radius,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getVendorDetails(String vendorId) async {
    try {
      final response = await _dio.get('${AppConfig.vendorDetailsEndpoint}/$vendorId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<dynamic>> getVendorCategories() async {
    try {
      final response = await _dio.get(AppConfig.vendorCategoriesEndpoint);
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }
  
  // ============== PRODUCT ENDPOINTS ==============
  
  Future<List<dynamic>> getProducts({String? vendorId, String? categoryId}) async {
    try {
      final response = await _dio.get(
        AppConfig.productsEndpoint,
        queryParameters: {
          if (vendorId != null) 'vendorId': vendorId,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );
      return response.data['products'] ?? [];
    } catch (e) {
      rethrow;
    }
  }
  
  // ============== ORDER ENDPOINTS ==============
  
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post(AppConfig.createOrderEndpoint, data: orderData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await _dio.get('${AppConfig.orderDetailsEndpoint}/$orderId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getOrders({String? status, int? page, int? limit}) async {
    try {
      final response = await _dio.get(
        AppConfig.ordersEndpoint,
        queryParameters: {
          if (status != null) 'status': status,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> cancelOrder(String orderId, {String? reason}) async {
    try {
      final response = await _dio.put(
        '/orders/$orderId/cancel',
        data: {
          if (reason != null) 'reason': reason,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // ============== WALLET ENDPOINTS ==============
  
  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _dio.get(AppConfig.walletEndpoint);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<dynamic>> getWalletTransactions() async {
    try {
      final response = await _dio.get(AppConfig.walletTransactionsEndpoint);
      return response.data['transactions'] ?? [];
    } catch (e) {
      rethrow;
    }
  }
  
  // ============== FILE UPLOAD ==============
  
  Future<Map<String, dynamic>> uploadImage(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      
      final response = await _dio.post(AppConfig.uploadImageEndpoint, data: formData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // ============== ZONES ==============
  
  Future<List<dynamic>> getZones() async {
    try {
      final response = await _dio.get(AppConfig.zonesEndpoint);
      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }
}
