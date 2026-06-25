// Flutter Flavor Dotenv
//
// A type-safe, multi-flavor environment configuration package for Flutter.
//
// ## Quick Start
//
// ```dart
// // In your flavor entry point (e.g. lib/main_dev.dart):
// import 'package:flutter/material.dart';
// import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await AppConfig.initialize(AppEnv.dev);
//   runApp(const MyApp());
// }
//
// // Anywhere in the app:
// final url = AppConfig.instance.apiUrl;
// ```

export 'src/app_config.dart';
export 'src/app_env.dart';
export 'src/env_loader.dart';
export 'src/env_validator.dart';
export 'src/exceptions.dart';
