/// Represents the application environment / flavor.
enum AppEnv {
  /// Development environment — verbose logging, mock data, dev APIs.
  dev,

  /// Staging environment — mirrors production with test data.
  staging,

  /// Production environment — real data, minimal logging.
  prod,
}

/// Convenience extension on [AppEnv].
extension AppEnvExtension on AppEnv {
  /// Returns `true` if this is the [AppEnv.dev] environment.
  bool get isDev => this == AppEnv.dev;

  /// Returns `true` if this is the [AppEnv.staging] environment.
  bool get isStaging => this == AppEnv.staging;

  /// Returns `true` if this is the [AppEnv.prod] environment.
  bool get isProd => this == AppEnv.prod;

  /// Returns a human-readable label for the environment.
  String get label => switch (this) {
        AppEnv.dev => 'Development',
        AppEnv.staging => 'Staging',
        AppEnv.prod => 'Production',
      };

  /// Returns the asset path for the corresponding `.env` file.
  ///
  /// By convention the consuming app places env files under `assets/`:
  /// ```
  /// assets/.env.dev
  /// assets/.env.staging
  /// assets/.env.prod
  /// ```
  String get assetPath => switch (this) {
        AppEnv.dev => 'assets/.env.dev',
        AppEnv.staging => 'assets/.env.staging',
        AppEnv.prod => 'assets/.env.prod',
      };
}
