import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _customApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _defaultMobileApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL_MOBILE',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );
  static const String _defaultWebApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL_WEB',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static String get apiBaseUrl {
    if (_customApiBaseUrl.isNotEmpty) {
      return _customApiBaseUrl;
    }
    return kIsWeb ? _defaultWebApiBaseUrl : _defaultMobileApiBaseUrl;
  }

  static const String admobBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String admobInterstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String adsensePlaceholderSlot = 'ADSENSE-PLACEHOLDER-SLOT-001';

  static const bool firebaseTelemetryEnabled = bool.fromEnvironment(
    'FIREBASE_ENABLED',
    defaultValue: false,
  );
}
