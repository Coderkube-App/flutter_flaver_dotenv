#!/usr/bin/env dart
// ignore_for_file: avoid_print

// Build-time validation script for .env files.
//
// Reads all three .env files and verifies that every required key is present
// and non-empty. Exits with code 1 on failure (CI-friendly).
//
// Run from the project root:
//   dart run tool/validate_env.dart
//
// Or from the example directory:
//   dart run tool/validate_env.dart --dir example/assets
import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

/// Keys that must be present and non-empty in every .env file.
const List<String> requiredKeys = ['API_URL', 'APP_NAME', 'ENABLE_LOGGING'];

/// Map of environment name → relative path to its .env file.
const Map<String, String> envFiles = {
  'dev': 'example/assets/.env.dev',
  'staging': 'example/assets/.env.staging',
  'prod': 'example/assets/.env.prod',
};

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main(List<String> args) async {
  print('🔍 Validating .env files...\n');

  // Allow overriding the base directory via --dir flag.
  String baseDir = '';
  for (int i = 0; i < args.length - 1; i++) {
    if (args[i] == '--dir') {
      baseDir = '${args[i + 1]}/';
    }
  }

  var hasErrors = false;

  for (final entry in envFiles.entries) {
    final envName = entry.key;
    final filePath = '$baseDir${entry.value}';
    final errors = _validateFile(filePath, envName);

    if (errors.isEmpty) {
      print('  ✅ [$envName] $filePath — OK');
    } else {
      hasErrors = true;
      print('  ❌ [$envName] $filePath — FAILED');
      for (final err in errors) {
        print('      • $err');
      }
    }
  }

  print('');

  if (hasErrors) {
    print('❌ Validation failed. Fix the issues above before building.\n');
    exit(1);
  } else {
    print('✅ All .env files are valid.\n');
    exit(0);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns a list of error messages for [filePath], or an empty list if valid.
List<String> _validateFile(String filePath, String envName) {
  final errors = <String>[];
  final file = File(filePath);

  if (!file.existsSync()) {
    errors.add('File not found: $filePath');
    return errors;
  }

  final values = _parse(file.readAsStringSync());

  for (final key in requiredKeys) {
    if (!values.containsKey(key) || values[key]!.isEmpty) {
      errors.add('Missing or empty key: $key');
    }
  }

  return errors;
}

/// Parses a .env file string into a key-value map.
Map<String, String> _parse(String content) {
  final result = <String, String>{};

  for (final rawLine in content.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    final idx = line.indexOf('=');
    if (idx == -1) continue;

    final key = line.substring(0, idx).trim();
    final value = line.substring(idx + 1).trim();

    if (key.isNotEmpty) {
      result[key] = _stripQuotes(value);
    }
  }

  return result;
}

String _stripQuotes(String value) {
  if (value.length >= 2 &&
      ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'")))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}
