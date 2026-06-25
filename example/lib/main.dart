import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';

import 'bootstrap.dart';

/// Default entry point — same as dev for quick `flutter run`.
///
/// Prefer explicit flavor entry points:
///   flutter run -t lib/main_dev.dart
///   flutter run -t lib/main_staging.dart
///   flutter run -t lib/main_prod.dart --release
Future<void> main() => runFlavorApp(AppEnv.dev);
