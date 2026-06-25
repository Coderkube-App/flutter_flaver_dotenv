# Example app

A small demo that shows how `flutter_flavor_dotenv` loads and validates
per-flavor `.env` files, then exposes them through `AppConfig.instance`.

## What it demonstrates

- **Flavor entry points** — `main_dev.dart`, `main_staging.dart`, and `main_prod.dart`
- **Must have** — `apiUrl`, `appName`, `enableLogging` (app won't start if missing)
- **Nice to have** — `baseUrl`, `sentryDsn`, `mapsApiKey` (optional, returns null)
- **Your own keys** — `config['WELCOME_MESSAGE']` and `config['FEATURE_FLAG']`
- **Logging toggle** — `DemoLogger` only prints when `ENABLE_LOGGING=true`

## Run

From this directory:

```bash
# Development (default)
flutter run -t lib/main_dev.dart

# Staging
flutter run -t lib/main_staging.dart

# Production
flutter run -t lib/main_prod.dart --release
```

Plain `flutter run` also works — it defaults to the dev flavor via `lib/main.dart`.

## Project layout

```
example/
  assets/
    .env.dev
    .env.staging
    .env.prod
  lib/
    bootstrap.dart      # shared AppConfig.initialize + runApp
    demo_logger.dart    # respects enableLogging
    app.dart            # UI that surfaces every config API
    main.dart           # defaults to dev
    main_dev.dart
    main_staging.dart
    main_prod.dart
```

Edit the `.env` files and hot-restart to see values update. Switch entry points
to compare how each flavor changes theme color, logging, and config values.
