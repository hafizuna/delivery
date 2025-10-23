import 'package:customer/app/splash/splash_screen.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_preference.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GetMaterialApp(
            title: 'Lakeside Customer',
            debugShowCheckedModeBanner: false,
            theme: AppThemeData.lightTheme,
            darkTheme: AppThemeData.darkTheme,
            themeMode: themeChangeProvider.getThem() ? ThemeMode.dark : ThemeMode.light,
            locale: LocalizationService.locale,
            fallbackLocale: LocalizationService.fallbackLocale,
            translations: LocalizationService(),
            home: const SplashScreen(),
            builder: EasyLoading.init(),
          );
        },
      ),
    );
  }
}
