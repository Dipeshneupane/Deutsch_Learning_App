import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReporter {
  Future<void> initialize() async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {
    await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: fatal,
    );
  }
}

CrashReporter createCrashReporter() => CrashReporter();
