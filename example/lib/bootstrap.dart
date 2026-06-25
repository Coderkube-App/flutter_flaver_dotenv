import 'package:flutter/material.dart';
import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';

import 'app.dart';

/// Shared startup for every flavor entry point.
///
/// Loads the matching `.env` asset, validates required keys, then launches
/// the demo app.
Future<void> runFlavorApp(AppEnv env) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize(env);
  runApp(const FlavorDemoApp());
}
