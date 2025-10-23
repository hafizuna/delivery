import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/lang/en_us.dart';
import 'package:customer/lang/ar_ar.dart';
import 'package:customer/lang/es_es.dart';
import 'package:customer/lang/fr_fr.dart';
import 'package:customer/lang/hi_in.dart';
import 'package:customer/lang/pt_pt.dart';
import 'package:customer/lang/sw_sw.dart';
import 'package:customer/lang/am_et.dart';

class LocalizationService extends Translations {
  static const fallbackLocale = Locale('en', 'US');
  
  static final List<Locale> supportedLocales = [
    const Locale('en', 'US'), // English
    const Locale('ar', 'AR'), // Arabic
    const Locale('es', 'ES'), // Spanish
    const Locale('fr', 'FR'), // French
    const Locale('hi', 'IN'), // Hindi
    const Locale('pt', 'PT'), // Portuguese
    const Locale('sw', 'SW'), // Swahili
    const Locale('am', 'ET'), // Amharic (Ethiopia)
  ];
  
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ar_AR': arAR,
        'es_ES': esES,
        'fr_FR': frFR,
        'hi_IN': hiIN,
        'pt_PT': ptPT,
        'sw_SW': swSW,
        'am_ET': amET,
      };
  
  static Locale get locale => Get.deviceLocale ?? fallbackLocale;
  
  static void changeLocale(String languageCode) {
    final locale = _getLocaleFromLanguage(languageCode);
    Get.updateLocale(locale);
  }
  
  static Locale _getLocaleFromLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return const Locale('en', 'US');
      case 'ar':
        return const Locale('ar', 'AR');
      case 'es':
        return const Locale('es', 'ES');
      case 'fr':
        return const Locale('fr', 'FR');
      case 'hi':
        return const Locale('hi', 'IN');
      case 'pt':
        return const Locale('pt', 'PT');
      case 'sw':
        return const Locale('sw', 'SW');
      case 'am':
        return const Locale('am', 'ET');
      default:
        return fallbackLocale;
    }
  }
}
