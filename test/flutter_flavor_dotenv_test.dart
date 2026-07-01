// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';

void main() {
  // ---------------------------------------------------------------------------
  // EnvLoader.parse tests
  // ---------------------------------------------------------------------------
  group('EnvLoader.parse', () {
    test('parses simple KEY=VALUE pairs', () {
      const content = '''
API_URL=https://api.example.com
APP_NAME=MyApp
ENABLE_LOGGING=true
''';
      final result = EnvLoader.parse(content);

      expect(result['API_URL'], equals('https://api.example.com'));
      expect(result['APP_NAME'], equals('MyApp'));
      expect(result['ENABLE_LOGGING'], equals('true'));
    });

    test('ignores comment lines starting with #', () {
      const content = '''
# This is a comment
API_URL=https://api.example.com
# Another comment
APP_NAME=MyApp
ENABLE_LOGGING=false
''';
      final result = EnvLoader.parse(content);
      expect(result.length, equals(3));
      expect(result.containsKey('# This is a comment'), isFalse);
    });

    test('ignores blank lines', () {
      const content = '''

API_URL=https://api.example.com

APP_NAME=MyApp
ENABLE_LOGGING=true

''';
      final result = EnvLoader.parse(content);
      expect(result.length, equals(3));
    });

    test('strips double quotes from values', () {
      const content = 'API_URL="https://api.example.com"';
      final result = EnvLoader.parse(content);
      expect(result['API_URL'], equals('https://api.example.com'));
    });

    test('strips single quotes from values', () {
      const content = "APP_NAME='MyApp'";
      final result = EnvLoader.parse(content);
      expect(result['APP_NAME'], equals('MyApp'));
    });

    test('handles values with = signs (uses first = as separator)', () {
      const content = 'REDIRECT_URL=https://example.com?foo=bar';
      final result = EnvLoader.parse(content);
      expect(result['REDIRECT_URL'], equals('https://example.com?foo=bar'));
    });

    test('trims whitespace around keys and values', () {
      const content = '  API_URL  =  https://api.example.com  ';
      final result = EnvLoader.parse(content);
      expect(result['API_URL'], equals('https://api.example.com'));
    });

    test('last duplicate key wins', () {
      const content = '''
API_URL=https://first.example.com
API_URL=https://second.example.com
''';
      final result = EnvLoader.parse(content);
      expect(result['API_URL'], equals('https://second.example.com'));
    });

    test('ignores malformed lines with no = sign', () {
      const content = '''
MALFORMED_LINE
API_URL=https://api.example.com
APP_NAME=MyApp
ENABLE_LOGGING=true
''';
      final result = EnvLoader.parse(content);
      expect(result.containsKey('MALFORMED_LINE'), isFalse);
      expect(result['API_URL'], equals('https://api.example.com'));
    });

    test('returns empty map for empty content', () {
      final result = EnvLoader.parse('');
      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // EnvValidator.validate tests
  // ---------------------------------------------------------------------------
  group('EnvValidator.validate', () {
    test('passes with all required keys present', () {
      final values = {
        'API_URL': 'https://api.example.com',
        'APP_NAME': 'MyApp',
        'ENABLE_LOGGING': 'true',
      };
      expect(
        () => EnvValidator.validate(values: values, envName: 'dev'),
        returnsNormally,
      );
    });

    test('throws EnvValidationException when a key is missing', () {
      final values = {
        'API_URL': 'https://api.example.com',
        // APP_NAME missing
        'ENABLE_LOGGING': 'true',
      };

      expect(
        () => EnvValidator.validate(values: values, envName: 'dev'),
        throwsA(isA<EnvValidationException>()),
      );
    });

    test('throws when a required key is present but empty', () {
      final values = {
        'API_URL': '',
        'APP_NAME': 'MyApp',
        'ENABLE_LOGGING': 'true',
      };

      expect(
        () => EnvValidator.validate(values: values, envName: 'dev'),
        throwsA(isA<EnvValidationException>()),
      );
    });

    test('EnvValidationException lists all missing keys', () {
      final values = <String, String>{};

      EnvValidationException? caught;
      try {
        EnvValidator.validate(values: values, envName: 'prod');
      } on EnvValidationException catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(
        caught!.missingKeys,
        containsAll(['API_URL', 'APP_NAME', 'ENABLE_LOGGING']),
      );
      expect(caught.envName, equals('prod'));
    });

    test('accepts custom required keys list', () {
      final values = {'CUSTOM_KEY': 'value'};
      expect(
        () => EnvValidator.validate(
          values: values,
          requiredKeys: ['CUSTOM_KEY'],
          envName: 'dev',
        ),
        returnsNormally,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // AppConfig tests
  // ---------------------------------------------------------------------------
  group('AppConfig', () {
    tearDown(() => AppConfig.resetForTesting());

    test('initializeFromMap sets instance correctly', () {
      AppConfig.initializeFromMap(AppEnv.dev, {
        'API_URL': 'https://api.dev.example.com',
        'APP_NAME': 'MyApp Dev',
        'ENABLE_LOGGING': 'true',
      });

      expect(AppConfig.isInitialized, isTrue);
      expect(AppConfig.instance.env, equals(AppEnv.dev));
      expect(AppConfig.instance.apiUrl, equals('https://api.dev.example.com'));
      expect(AppConfig.instance.appName, equals('MyApp Dev'));
      expect(AppConfig.instance.enableLogging, isTrue);
    });

    test('enableLogging is false when value is "false"', () {
      AppConfig.initializeFromMap(AppEnv.prod, {
        'API_URL': 'https://api.example.com',
        'APP_NAME': 'MyApp',
        'ENABLE_LOGGING': 'false',
      });

      expect(AppConfig.instance.enableLogging, isFalse);
    });

    test('enableLogging is case-insensitive', () {
      AppConfig.initializeFromMap(AppEnv.dev, {
        'API_URL': 'https://api.dev.example.com',
        'APP_NAME': 'MyApp Dev',
        'ENABLE_LOGGING': 'TRUE',
      });

      expect(AppConfig.instance.enableLogging, isTrue);
    });

    test('baseUrl returns null when BASE_URL not set', () {
      AppConfig.initializeFromMap(AppEnv.dev, {
        'API_URL': 'https://api.dev.example.com',
        'APP_NAME': 'MyApp Dev',
        'ENABLE_LOGGING': 'true',
      });

      expect(AppConfig.instance.baseUrl, isNull);
    });

    test('baseUrl returns value when BASE_URL is set', () {
      AppConfig.initializeFromMap(AppEnv.staging, {
        'API_URL': 'https://api.staging.example.com',
        'APP_NAME': 'MyApp Staging',
        'ENABLE_LOGGING': 'true',
        'BASE_URL': 'https://staging.example.com',
      });

      expect(AppConfig.instance.baseUrl, equals('https://staging.example.com'));
    });

    test('operator[] returns arbitrary key values', () {
      AppConfig.initializeFromMap(AppEnv.dev, {
        'API_URL': 'https://api.dev.example.com',
        'APP_NAME': 'MyApp Dev',
        'ENABLE_LOGGING': 'true',
        'CUSTOM_KEY': 'custom_value',
      });

      expect(AppConfig.instance['CUSTOM_KEY'], equals('custom_value'));
      expect(AppConfig.instance['NONEXISTENT'], isNull);
    });

    test(
      'throws EnvNotInitializedException when instance accessed before init',
      () {
        expect(
          () => AppConfig.instance,
          throwsA(isA<EnvNotInitializedException>()),
        );
      },
    );

    test('isInitialized is false before initialize', () {
      expect(AppConfig.isInitialized, isFalse);
    });

    test('isInitialized is true after initializeFromMap', () {
      AppConfig.initializeFromMap(AppEnv.dev, {
        'API_URL': 'https://api.dev.example.com',
        'APP_NAME': 'MyApp Dev',
        'ENABLE_LOGGING': 'true',
      });

      expect(AppConfig.isInitialized, isTrue);
    });

    test(
      'initializeFromMap throws EnvValidationException when required keys missing',
      () {
        expect(
          () => AppConfig.initializeFromMap(AppEnv.dev, {
            'API_URL': 'https://api.dev.example.com',
          }),
          throwsA(isA<EnvValidationException>()),
        );
      },
    );

    test('resetForTesting clears instance', () {
      AppConfig.initializeFromMap(AppEnv.dev, {
        'API_URL': 'https://api.dev.example.com',
        'APP_NAME': 'MyApp Dev',
        'ENABLE_LOGGING': 'true',
      });

      AppConfig.resetForTesting();
      expect(AppConfig.isInitialized, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // AppEnv extension tests
  // ---------------------------------------------------------------------------
  group('AppEnvExtension', () {
    test('isDev is true only for dev', () {
      expect(AppEnv.dev.isDev, isTrue);
      expect(AppEnv.staging.isDev, isFalse);
      expect(AppEnv.prod.isDev, isFalse);
    });

    test('isStaging is true only for staging', () {
      expect(AppEnv.staging.isStaging, isTrue);
      expect(AppEnv.dev.isStaging, isFalse);
      expect(AppEnv.prod.isStaging, isFalse);
    });

    test('isProd is true only for prod', () {
      expect(AppEnv.prod.isProd, isTrue);
      expect(AppEnv.dev.isProd, isFalse);
      expect(AppEnv.staging.isProd, isFalse);
    });

    test('label returns human-readable strings', () {
      expect(AppEnv.dev.label, equals('Development'));
      expect(AppEnv.staging.label, equals('Staging'));
      expect(AppEnv.prod.label, equals('Production'));
    });

    test('assetPath returns correct file paths', () {
      expect(AppEnv.dev.assetPath, equals('assets/.env.dev'));
      expect(AppEnv.staging.assetPath, equals('assets/.env.staging'));
      expect(AppEnv.prod.assetPath, equals('assets/.env.prod'));
    });
  });
}
