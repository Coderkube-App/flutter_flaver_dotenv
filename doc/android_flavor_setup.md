## Android Flavor Configuration

Add the following `productFlavors` block inside the `android { ... }` section of your app's
`android/app/build.gradle`.

```groovy
android {
    // ... existing config (compileSdk, defaultConfig, etc.) ...

    flavorDimensions "environment"

    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "MyApp (Dev)"
        }

        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "MyApp (Staging)"
        }

        prod {
            dimension "environment"
            // No suffix — prod uses the base applicationId
            resValue "string", "app_name", "MyApp"
        }
    }
}
```

### Build Commands

| Flavor      | Command                                                      |
|-------------|--------------------------------------------------------------|
| Dev (debug) | `flutter run --flavor dev -t lib/main_dev.dart`              |
| Staging     | `flutter run --flavor staging -t lib/main_staging.dart`      |
| Production  | `flutter build apk --flavor prod -t lib/main_prod.dart --release` |

### iOS Scheme Setup

For iOS, create three Xcode schemes:
1. Open `ios/Runner.xcworkspace` in Xcode.
2. **Product → Scheme → Manage Schemes**.
3. Duplicate `Runner` three times, rename to `dev`, `staging`, `prod`.
4. For each scheme set the environment variable `FLUTTER_TARGET` to the corresponding `lib/main_*.dart`.

Or use the `flutter_flavorizr` package to automate both Android + iOS flavor setup:
```yaml
# pubspec.yaml (dev_dependencies)
flutter_flavorizr: ^2.2.3
```
