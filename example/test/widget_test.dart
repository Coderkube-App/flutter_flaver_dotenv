import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';
import 'package:flutter_flavor_dotenv_example/app.dart';

void main() {
  setUp(() {
    AppConfig.initializeFromMap(AppEnv.dev, {
      'API_URL': 'https://api.dev.example.com',
      'APP_NAME': 'MyApp (Dev)',
      'ENABLE_LOGGING': 'true',
      'BASE_URL': 'https://dev.example.com',
      'WELCOME_MESSAGE': 'Welcome to the dev sandbox.',
      'FEATURE_FLAG': 'beta-checkout',
    });
  });

  tearDown(() => AppConfig.resetForTesting());

  testWidgets('FlavorDemoApp renders config from AppConfig', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FlavorDemoApp());

    expect(find.text('MyApp (Dev)'), findsWidgets);
    expect(find.text('https://api.dev.example.com'), findsOneWidget);
    expect(find.text('Must have'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Simulate API call'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Simulate API call'), findsOneWidget);
  });
}
