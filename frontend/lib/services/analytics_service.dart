import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/firebase_config.dart';
import 'crash_reporter.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;
  bool _initialized = false;
  bool _enabled = false;
  late final CrashReporter _crashReporter = createCrashReporter();

  bool get isEnabled => _enabled;
  bool get isCrashReportingEnabled => _enabled && !kIsWeb;
  NavigatorObserver? get navigatorObserver => _observer;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    if (!FirebaseConfig.isConfigured) {
      debugPrint(
        'Firebase telemetry disabled. Add FIREBASE_* dart-defines to enable analytics and crash reporting.',
      );
      return;
    }

    try {
      await Firebase.initializeApp(options: FirebaseConfig.options);
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      _enabled = true;

      await _analytics!.setAnalyticsCollectionEnabled(true);
      await _analytics!.logAppOpen();

      if (!kIsWeb) {
        await _crashReporter.initialize();

        final previousOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          previousOnError?.call(details);
          unawaited(_crashReporter.recordFlutterFatalError(details));
        };

        final previousPlatformOnError = PlatformDispatcher.instance.onError;
        PlatformDispatcher.instance.onError = (error, stackTrace) {
          unawaited(
            _crashReporter.recordError(
              error,
              stackTrace,
              fatal: true,
            ),
          );
          return previousPlatformOnError?.call(error, stackTrace) ?? false;
        };
      }
    } catch (error, stackTrace) {
      debugPrint('Firebase telemetry setup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _enabled = false;
    }
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    if (_analytics == null) {
      return;
    }

    final sanitized = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is String || value is num || value is bool) {
        sanitized[entry.key] = value;
      } else {
        sanitized[entry.key] = value.toString();
      }
    }

    await _analytics!.logEvent(name: name, parameters: sanitized);
  }

  Future<void> logScreenView(String screenName) async {
    if (_analytics == null) {
      return;
    }
    await _analytics!.logScreenView(screenName: screenName);
  }
}
