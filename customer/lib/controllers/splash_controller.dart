import 'package:customer/app/auth/login_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/onboarding/on_boarding_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/storage_service.dart';
import 'package:customer/services/socket_service.dart';
import 'package:customer/utils/preferences.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final StorageService _storageService = StorageService();
  final SocketService _socketService = SocketService();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for splash screen display
      await Future.delayed(const Duration(seconds: 2));

      // Initialize preferences
      await Preferences.initPref();

      // Check if user has completed onboarding
      bool isFirstTime = Preferences.getBoolean(Preferences.isFinishOnBoardingKey);
      
      if (isFirstTime == false) {
        // First time user - show onboarding
        Get.offAll(() => const OnBoardingScreen());
        return;
      }

      // Check if user is logged in
      bool isLoggedIn = await _storageService.isLoggedIn();
      
      if (isLoggedIn) {
        // Get user data from storage
        final userDataJson = await _storageService.getUserData();
        
        if (userDataJson != null) {
          try {
            // Parse user data and set in constant
            Constant.userModel = UserModel.fromJson(userDataJson);
            
            // Connect Socket.IO for real-time updates
            await _socketService.connect();
            
            // Navigate to dashboard
            Get.offAll(() => const DashBoardScreen());
          } catch (e) {
            print('Error parsing user data: $e');
            // If user data is corrupted, clear and show login
            await _clearStorageAndShowLogin();
          }
        } else {
          // No user data, show login
          Get.offAll(() => const LoginScreen());
        }
      } else {
        // Not logged in - show login
        Get.offAll(() => const LoginScreen());
      }
    } catch (e) {
      print('Error in splash initialization: $e');
      // Fallback - show login
      Get.offAll(() => const LoginScreen());
    }
  }

  Future<void> _clearStorageAndShowLogin() async {
    await _storageService.clearAll();
    Constant.userModel = null;
    _socketService.disconnect();
    Get.offAll(() => const LoginScreen());
  }
}
