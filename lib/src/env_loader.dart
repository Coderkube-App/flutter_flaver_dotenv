import 'package:flutter/services.dart' show rootBundle;

/// Loads and parses key-value pairs from a `.env`-formatted asset file.
///
/// ### `.env` file format
/// ```
/// # This is a comment
/// API_URL=https://api.example.com
/// APP_NAME=MyApp
/// ENABLE_LOGGING=true
/// ```
///
/// Rules:
/// - Lines starting with `#` are treated as comments and ignored.
/// - Blank lines are ignored.
/// - Keys and values are trimmed of surrounding whitespace.
/// - Inline comments (after the value) are **not** stripped — keep values clean.
/// - Duplicate keys: the last occurrence wins.
class EnvLoader {
  const EnvLoader._();

  /// Loads the `.env` file at [assetPath] from the Flutter asset bundle and
  /// returns a [Map] of key-value pairs.
  ///
  /// Throws a [FlutterError] if the asset cannot be found.
  ///
  /// ```dart
  /// final values = await EnvLoader.load('assets/.env.dev');
  /// ```
  static Future<Map<String, String>> load(String assetPath) async {
    final content = await rootBundle.loadString(assetPath);
    return parse(content);
  }

  /// Parses a [String] in `.env` format and returns a [Map] of key-value pairs.
  ///
  /// This is a synchronous utility useful for unit-testing without asset loading.
  ///
  /// ```dart
  /// final values = EnvLoader.parse('API_URL=https://api.example.com\nDEBUG=true');
  /// ```
  static Map<String, String> parse(String content) {
    final result = <String, String>{};

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();

      // Skip empty lines and comments.
      if (line.isEmpty || line.startsWith('#')) continue;

      final separatorIndex = line.indexOf('=');
      if (separatorIndex == -1) continue; // No `=` found — skip malformed line.

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();

      if (key.isNotEmpty) {
        result[key] = _stripQuotes(value);
      }
    }

    return result;
  }

  /// Strips surrounding single or double quotes from a value, if present.
  static String _stripQuotes(String value) {
    if (value.length >= 2) {
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        return value.substring(1, value.length - 1);
      }
    }
    return value;
  }
}
