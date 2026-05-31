import 'package:equatable/equatable.dart';

/// Immutable, environment-aware application configuration.
///
/// Use [AppConfig.fromEnvironment] to construct an instance for a known
/// flavor (`'development'`, `'staging'`, or `'production'`). Per-flavor
/// defaults can be overridden at compile time via `--dart-define`:
///
/// * `--dart-define=API_BASE_URL=...`
/// * `--dart-define=SENTRY_DSN=...`
/// * `--dart-define=ENABLE_LOGGING=true|false`
class AppConfig extends Equatable {
  const AppConfig({
    required this.apiBaseUrl,
    required this.environmentName,
    required this.enableLogging,
    this.sentryDsn,
  });

  /// Builds an [AppConfig] for the given environment [name].
  ///
  /// Throws an [ArgumentError] if [name] is not one of the known flavors.
  factory AppConfig.fromEnvironment(String name) {
    final defaults = switch (name) {
      'development' => const _EnvironmentDefaults(
        apiBaseUrl: 'http://localhost:8080',
        enableLogging: true,
      ),
      'staging' => const _EnvironmentDefaults(
        apiBaseUrl: 'https://staging.api.example.com',
        enableLogging: true,
      ),
      'production' => const _EnvironmentDefaults(
        apiBaseUrl: 'https://api.example.com',
        enableLogging: false,
      ),
      _ => throw ArgumentError.value(name, 'name', 'Unknown environment'),
    };

    const apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    const enableLoggingOverride = String.fromEnvironment('ENABLE_LOGGING');

    return AppConfig(
      apiBaseUrl: apiBaseUrlOverride.isNotEmpty
          ? apiBaseUrlOverride
          : defaults.apiBaseUrl,
      sentryDsn: sentryDsn.isNotEmpty ? sentryDsn : null,
      environmentName: name,
      enableLogging: enableLoggingOverride.isNotEmpty
          ? enableLoggingOverride.toLowerCase() == 'true'
          : defaults.enableLogging,
    );
  }

  /// Base URL of the backend API.
  final String apiBaseUrl;

  /// Optional Sentry DSN; `null` when not configured.
  final String? sentryDsn;

  /// Human-readable environment label (`development`, `staging`, `production`).
  final String environmentName;

  /// Whether verbose logging should be enabled at runtime.
  final bool enableLogging;

  @override
  List<Object?> get props => [
    apiBaseUrl,
    sentryDsn,
    environmentName,
    enableLogging,
  ];
}

class _EnvironmentDefaults {
  const _EnvironmentDefaults({
    required this.apiBaseUrl,
    required this.enableLogging,
  });

  final String apiBaseUrl;
  final bool enableLogging;
}
