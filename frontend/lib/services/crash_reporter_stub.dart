import 'package:flutter/foundation.dart';

class CrashReporter {
  Future<void> initialize() async {}

  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {}

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  }) async {}
}

CrashReporter createCrashReporter() => CrashReporter();
