import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/app/router/app_routes.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({required this.error, super.key});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.errorPageTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 72,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.errorPageMessage,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? l10n.errorPageUnknown,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => AppRoutes.home.go(context),
                icon: const Icon(Icons.home),
                label: Text(l10n.errorPageGoHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final info = context.read<PackageInfo>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsAbout)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(info.appName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${info.version}+${info.buildNumber}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(info.packageName, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
