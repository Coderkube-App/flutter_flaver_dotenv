import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';

import 'bootstrap.dart';

/// Production entry point.
///
/// Run with:
///   flutter run -t lib/main_prod.dart --release
Future<void> main() => runFlavorApp(AppEnv.prod);
