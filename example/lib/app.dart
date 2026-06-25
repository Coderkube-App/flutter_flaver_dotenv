import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor_dotenv/flutter_flavor_dotenv.dart';

import 'demo_logger.dart';

/// Root widget for the flutter_flavor_dotenv example app.
class FlavorDemoApp extends StatelessWidget {
  const FlavorDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    final seedColor = _envColor(config.env);

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: config.env.isDev,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const FlavorDemoHomePage(),
    );
  }

  static Color _envColor(AppEnv env) => switch (env) {
        AppEnv.dev => const Color(0xFF2563EB),
        AppEnv.staging => const Color(0xFFEA580C),
        AppEnv.prod => const Color(0xFF16A34A),
      };
}

class FlavorDemoHomePage extends StatelessWidget {
  const FlavorDemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    final theme = Theme.of(context);
    final accent = _envColor(config.env);

    return Scaffold(
      appBar: AppBar(
        title: Text(config.appName),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _HeroHeader(env: config.env, assetPath: config.env.assetPath),
          const SizedBox(height: 20),
          _ConfigSection(
            title: 'Must have',
            subtitle: 'Every .env file needs these — the app won\'t start without them',
            children: [
              _ConfigTile(label: 'API URL', value: config.apiUrl),
              _ConfigTile(label: 'App name', value: config.appName),
              _ConfigTile(
                label: 'Logging',
                value: config.enableLogging ? 'Enabled' : 'Disabled',
                valueColor: config.enableLogging ? Colors.green : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ConfigSection(
            title: 'Nice to have',
            subtitle: 'Common extras — safe to omit; returns null if missing',
            children: [
              _ConfigTile(
                label: 'Base URL',
                value: config.baseUrl ?? '—',
              ),
              _ConfigTile(
                label: 'Sentry DSN',
                value: _maskSecret(config.sentryDsn),
              ),
              _ConfigTile(
                label: 'Maps API key',
                value: _maskSecret(config.mapsApiKey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ConfigSection(
            title: 'Your own keys',
            subtitle: 'Anything else in .env — read with config["YOUR_KEY"]',
            children: [
              _ConfigTile(
                label: 'WELCOME_MESSAGE',
                value: config['WELCOME_MESSAGE'] ?? '—',
              ),
              _ConfigTile(
                label: 'FEATURE_FLAG',
                value: config['FEATURE_FLAG'] ?? '—',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Try it',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => _simulateApiCall(context),
                icon: const Icon(Icons.cloud_outlined),
                label: const Text('Simulate API call'),
              ),
              OutlinedButton.icon(
                onPressed: () => _emitLog(context),
                icon: const Icon(Icons.terminal_outlined),
                label: const Text('Emit log'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            config.enableLogging
                ? 'Logs print to the debug console when logging is enabled.'
                : 'Logging is off in this flavor — the emit button is a no-op.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _RunInstructionsCard(accent: accent),
        ],
      ),
    );
  }

  static Color _envColor(AppEnv env) => FlavorDemoApp._envColor(env);

  static String _maskSecret(String? value) {
    if (value == null || value.isEmpty) return '—';
    if (value.length <= 8) return '••••••••';
    return '${'•' * 8}${value.substring(value.length - 4)}';
  }

  void _simulateApiCall(BuildContext context) {
    final config = AppConfig.instance;
    DemoLogger.log('GET ${config.apiUrl}/health');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would call ${config.apiUrl}/health'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _emitLog(BuildContext context) {
    final config = AppConfig.instance;
    DemoLogger.log('Manual log from ${config.env.label} build');

    final message = config.enableLogging
        ? 'Log sent — check your debug console.'
        : 'Logging is disabled for ${config.env.label}.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.env,
    required this.assetPath,
  });

  final AppEnv env;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = FlavorDemoHomePage._envColor(env);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color),
            ),
            child: Text(
              env.label.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Environment loaded from .env',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This screen reads every value from AppConfig.instance after '
            'startup validation.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          _CopyableChip(label: 'Asset', value: assetPath),
        ],
      ),
    );
  }
}

class _ConfigSection extends StatelessWidget {
  const _ConfigSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  const _ConfigTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 112,
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyableChip extends StatelessWidget {
  const _CopyableChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied $value'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.copy_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _RunInstructionsCard extends StatelessWidget {
  const _RunInstructionsCard({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(
                'Run another flavor',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _CommandLine(command: 'flutter run -t lib/main_dev.dart'),
          const SizedBox(height: 8),
          const _CommandLine(command: 'flutter run -t lib/main_staging.dart'),
          const SizedBox(height: 8),
          const _CommandLine(
            command: 'flutter run -t lib/main_prod.dart --release',
          ),
        ],
      ),
    );
  }
}

class _CommandLine extends StatelessWidget {
  const _CommandLine({required this.command});

  final String command;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      command,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12.5,
      ),
    );
  }
}
