# flutter_flavor_dotenv

A type-safe, multi-flavor Flutter environment manager. Load Dev, Staging, and Production configuration from `.env` assets with startup validation and a singleton `AppConfig` API.

## Features

- **Multi-flavor support** — `AppEnv.dev`, `AppEnv.staging`, and `AppEnv.prod` with conventional asset paths.
- **`.env` parsing** — Comments, quoted values, whitespace trimming, and duplicate-key handling.
- **Startup validation** — Fails fast when required keys are missing or empty.
- **Type-safe access** — `apiUrl`, `appName`, `enableLogging`, and optional keys via typed getters.
- **Test-friendly** — `initializeFromMap` and `resetForTesting` for unit tests without asset loading.

## Getting started

### 1. Add the dependency

```yaml
dependencies:
  flutter_flavor_dotenv: ^0.0.1
```

### 2. Create `.env` files in your app

Place one file per flavor under `assets/`:

```
assets/
  .env.dev
  .env.staging
  .env.prod
```

Example `assets/.env.dev`:

```env
# Development environment
API_URL=https://api.dev.example.com
APP_NAME=MyApp (Dev)
ENABLE_LOGGING=true
BASE_URL=https://dev.example.com
```

### 3. Register assets in `pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/.env.dev
    - assets/.env.staging
    - assets/.env.prod
```

### 4. Create flavor entry points

```dart
// lib/main_dev.dart
import 'package:flutter/material.dart';
import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize(AppEnv.dev);
  runApp(const MyApp());
}
```

Repeat for `main_staging.dart` and `main_prod.dart`, passing `AppEnv.staging` and `AppEnv.prod`.

### 5. Run with the matching entry point

```bash
flutter run -t lib/main_dev.dart
flutter run -t lib/main_staging.dart
flutter run -t lib/main_prod.dart --release
```

For Android/iOS product flavors, see [doc/android_flavor_setup.md](doc/android_flavor_setup.md).

## Usage

### Read configuration anywhere

```dart
final config = AppConfig.instance;

final apiUrl = config.apiUrl;
final appName = config.appName;
final logging = config.enableLogging;
final env = config.env; // AppEnv.dev

// Optional keys
final baseUrl = config.baseUrl;
final sentryDsn = config.sentryDsn;
final mapsApiKey = config.mapsApiKey;

// Arbitrary keys
final custom = config['CUSTOM_KEY'];
```

### Custom required keys

```dart
await AppConfig.initialize(
  AppEnv.prod,
  requiredKeys: ['API_URL', 'APP_NAME', 'ENABLE_LOGGING', 'MAPS_API_KEY'],
);
```

### Overrides (tests or CI)

```dart
await AppConfig.initialize(
  AppEnv.dev,
  overrides: {'API_URL': 'https://localhost:8080'},
);
```

### Unit tests without assets

```dart
AppConfig.initializeFromMap(AppEnv.dev, {
  'API_URL': 'https://api.dev.example.com',
  'APP_NAME': 'MyApp Dev',
  'ENABLE_LOGGING': 'true',
});

// tearDown
AppConfig.resetForTesting();
```

## Required `.env` keys

By default, every `.env` file must define:

| Key | Type | Description |
|-----|------|-------------|
| `API_URL` | `String` | API base URL |
| `APP_NAME` | `String` | Human-readable app name |
| `ENABLE_LOGGING` | `bool` | `"true"` or `"false"` (case-insensitive) |

### Optional keys (typed getters)

| Key | Getter |
|-----|--------|
| `BASE_URL` | `baseUrl` |
| `SENTRY_DSN` | `sentryDsn` |
| `MAPS_API_KEY` | `mapsApiKey` |

Any other key is available via `config['YOUR_KEY']`.

## Example

See the [`example/`](example/) app for a working Dev/Staging/Prod setup with flavor entry points and sample `.env` files.

```bash
cd example
flutter run -t lib/main_dev.dart
```

## API overview

| Class | Purpose |
|-------|---------|
| `AppEnv` | Environment enum (`dev`, `staging`, `prod`) |
| `AppConfig` | Singleton config loaded at startup |
| `EnvLoader` | Load and parse `.env` asset files |
| `EnvValidator` | Validate required keys |
| `EnvValidationException` | Thrown when keys are missing |
| `EnvNotInitializedException` | Thrown when `AppConfig.instance` is used before init |

## Additional information

- **License:** Apache License 2.0 — see [LICENSE](LICENSE).
- **Changelog:** [CHANGELOG.md](CHANGELOG.md).
- **Issues:** [GitHub Issues](https://github.com/nileshsenta/flutter_flavor_dotenv/issues).

Contributions and bug reports are welcome via GitHub issues and pull requests.
