import 'package:flutter/foundation.dart';
import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';

/// Tiny logger that respects [AppConfig.enableLogging].
class DemoLogger {
  const DemoLogger._();

  static void log(String message) {
    if (!AppConfig.instance.enableLogging) return;
    debugPrint('[${AppConfig.instance.env.label}] $message');
  }
}
