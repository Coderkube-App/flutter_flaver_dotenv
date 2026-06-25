import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';

import 'bootstrap.dart';

/// Development entry point.
///
/// Run with:
///   flutter run -t lib/main_dev.dart
Future<void> main() => runFlavorApp(AppEnv.dev);
