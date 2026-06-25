/// Thrown when required environment keys are missing from an `.env` file.
class EnvValidationException implements Exception {
  /// The list of keys that were missing during validation.
  final List<String> missingKeys;

  /// The name of the environment (e.g., "dev", "staging", "prod").
  final String envName;

  const EnvValidationException({
    required this.missingKeys,
    required this.envName,
  });

  @override
  String toString() {
    final keys = missingKeys.join(', ');
    return 'EnvValidationException: Missing required keys in [$envName] environment: $keys';
  }
}

/// Thrown when [AppConfig.instance] is accessed before [AppConfig.initialize]
/// has been called.
class EnvNotInitializedException implements Exception {
  const EnvNotInitializedException();

  @override
  String toString() =>
      'EnvNotInitializedException: AppConfig has not been initialized. '
      'Call AppConfig.initialize() before accessing AppConfig.instance.';
}
