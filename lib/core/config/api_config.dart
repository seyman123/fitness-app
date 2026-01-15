import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  // Dinamik base URL - Platform'a göre otomatik ayarlanır
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web: localhost kullan (tarayıcı aynı makinede çalışıyor)
      return 'http://localhost:3000/api';
    }

    // Android Emülatör: 10.0.2.2 kullan (host makineye erişim için)
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }

    // iOS Simülatör: localhost kullanabilir
    if (Platform.isIOS) {
      return 'http://localhost:3000/api';
    }

    // Fiziksel cihaz için LAN IP (gerekirse bu satırı aktif et)
    // return 'http://192.168.1.178:3000/api';

    return 'http://localhost:3000/api';
  }

  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // Endpoints
  static const String auth = '/auth';
  static const String profile = '/profile';
  static const String profileEndpoint = '/profile'; // Added for consistency
  static const String water = '/water';
  static const String nutrition = '/nutrition';
  static const String steps = '/steps';
}
