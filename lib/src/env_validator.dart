import 'exceptions.dart';

/// Validates that a loaded environment map contains all required keys.
///
/// Usage:
/// ```dart
/// EnvValidator.validate(
///   values: loadedMap,
///   requiredKeys: ['API_URL', 'APP_NAME', 'ENABLE_LOGGING'],
///   envName: 'dev',
/// );
/// ```
///
/// Throws [EnvValidationException] if any required keys are absent.
class EnvValidator {
  const EnvValidator._();

  /// The default set of keys that every `.env` file must define.
  static const List<String> defaultRequiredKeys = [
    'API_URL',
    'APP_NAME',
    'ENABLE_LOGGING',
  ];

  /// Validates [values] against [requiredKeys].
  ///
  /// - [values] — the parsed environment map.
  /// - [requiredKeys] — keys that must be present. Defaults to [defaultRequiredKeys].
  /// - [envName] — human-readable name used in the error message.
  ///
  /// Throws [EnvValidationException] listing all missing keys.
  static void validate({
    required Map<String, String> values,
    List<String> requiredKeys = defaultRequiredKeys,
    String envName = 'unknown',
  }) {
    final missing = requiredKeys
        .where((key) => !values.containsKey(key) || values[key]!.isEmpty)
        .toList();

    if (missing.isNotEmpty) {
      throw EnvValidationException(missingKeys: missing, envName: envName);
    }
  }
}
