import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';

import 'bootstrap.dart';

/// Staging entry point.
///
/// Run with:
///   flutter run -t lib/main_staging.dart
Future<void> main() => runFlavorApp(AppEnv.staging);
