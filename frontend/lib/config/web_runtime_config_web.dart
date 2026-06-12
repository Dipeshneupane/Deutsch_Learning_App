import 'dart:js_interop';
import 'dart:js_interop_unsafe';

String? readConfigValue(String key) {
  final config = globalContext['__APP_CONFIG__'];
  if (config == null || !config.isA<JSObject>()) {
    return null;
  }

  final value = (config as JSObject)[key];
  if (value == null || !value.isA<JSString>()) {
    return null;
  }

  final stringValue = (value as JSString).toDart;
  return stringValue.isEmpty ? null : stringValue;
}
