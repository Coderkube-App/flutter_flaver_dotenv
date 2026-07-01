import 'app_env.dart';
import 'env_loader.dart';
import 'env_validator.dart';
import 'exceptions.dart';

/// Provides type-safe access to environment configuration loaded from `.env` files.
///
/// ## Setup
///
/// Call [AppConfig.initialize] once in your flavor entry-point **before** calling
/// `runApp`:
///
/// ```dart
/// // lib/main_dev.dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AppConfig.initialize(AppEnv.dev);
///   runApp(const MyApp());
/// }
/// ```
///
/// ## Access
///
/// Anywhere in the app:
///
/// ```dart
/// final url  = AppConfig.instance.apiUrl;
/// final name = AppConfig.instance.appName;
/// final log  = AppConfig.instance.enableLogging;
/// final env  = AppConfig.instance.env; // AppEnv.dev
/// ```
class AppConfig {
  /// The active environment for this build.
  final AppEnv env;

  /// Raw key-value map loaded from the `.env` asset file.
  final Map<String, String> _values;

  AppConfig._({required this.env, required Map<String, String> values})
    : _values = Map.unmodifiable(values);

  // ---------------------------------------------------------------------------
  // Singleton management
  // ---------------------------------------------------------------------------

  static AppConfig? _instance;

  /// The global singleton instance.
  ///
  /// Throws [EnvNotInitializedException] if accessed before [initialize].
  static AppConfig get instance {
    if (_instance == null) throw const EnvNotInitializedException();
    return _instance!;
  }

  /// Whether [initialize] has been called.
  static bool get isInitialized => _instance != null;

  /// Initializes the global [AppConfig] singleton.
  ///
  /// - Loads the `.env` asset corresponding to [env] (via [AppEnvExtension.assetPath]).
  /// - Optionally merges [overrides] on top (useful for tests or CI injections).
  /// - Validates that all [requiredKeys] are present.
  ///
  /// Call this once in each flavor entry-point before `runApp`.
  ///
  /// ```dart
  /// await AppConfig.initialize(AppEnv.dev);
  /// ```
  ///
  /// Throws [EnvValidationException] if required keys are missing.
  static Future<AppConfig> initialize(
    AppEnv env, {
    Map<String, String> overrides = const {},
    List<String> requiredKeys = EnvValidator.defaultRequiredKeys,
  }) async {
    final loaded = await EnvLoader.load(env.assetPath);
    final merged = {...loaded, ...overrides};

    EnvValidator.validate(
      values: merged,
      requiredKeys: requiredKeys,
      envName: env.name,
    );

    _instance = AppConfig._(env: env, values: merged);
    return _instance!;
  }

  /// Initializes [AppConfig] synchronously from an already-loaded map.
  ///
  /// Useful in unit tests where you don't want to load Flutter assets:
  ///
  /// ```dart
  /// AppConfig.initializeFromMap(AppEnv.dev, {
  ///   'API_URL': 'https://api.dev.example.com',
  ///   'APP_NAME': 'MyApp Dev',
  ///   'ENABLE_LOGGING': 'true',
  /// });
  /// ```
  static AppConfig initializeFromMap(
    AppEnv env,
    Map<String, String> values, {
    List<String> requiredKeys = EnvValidator.defaultRequiredKeys,
  }) {
    EnvValidator.validate(
      values: values,
      requiredKeys: requiredKeys,
      envName: env.name,
    );
    _instance = AppConfig._(env: env, values: values);
    return _instance!;
  }

  /// Resets the singleton — **only for use in tests**.
  // ignore: invalid_use_of_visible_for_testing_member
  static void resetForTesting() => _instance = null;

  // ---------------------------------------------------------------------------
  // Type-safe getters
  // ---------------------------------------------------------------------------

  /// The API base URL (maps to the `API_URL` key).
  String get apiUrl => _require('API_URL');

  /// The human-readable application name (maps to the `APP_NAME` key).
  String get appName => _require('APP_NAME');

  /// Whether logging is enabled (maps to the `ENABLE_LOGGING` key).
  ///
  /// Returns `true` if the value is `"true"` (case-insensitive).
  bool get enableLogging => _values['ENABLE_LOGGING']?.toLowerCase() == 'true';

  /// Optional: a secondary base URL (maps to the `BASE_URL` key if defined).
  String? get baseUrl => _values['BASE_URL'];

  /// Optional: a Sentry DSN or similar error-reporting URL.
  String? get sentryDsn => _values['SENTRY_DSN'];

  /// Optional: Google Maps API key.
  String? get mapsApiKey => _values['MAPS_API_KEY'];

  /// Returns the raw string value for an arbitrary [key], or `null` if absent.
  ///
  /// Use this to access keys not covered by the built-in typed getters.
  String? operator [](String key) => _values[key];

  /// Returns a read-only view of all loaded key-value pairs.
  Map<String, String> get all => _values;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _require(String key) {
    final value = _values[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'AppConfig: required key "$key" is missing or empty. '
        'Make sure it is defined in your .env.${env.name} file.',
      );
    }
    return value;
  }

  @override
  String toString() =>
      'AppConfig(env: ${env.label}, apiUrl: $apiUrl, appName: $appName, '
      'enableLogging: $enableLogging)';
}
