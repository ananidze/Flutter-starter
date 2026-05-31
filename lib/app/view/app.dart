import 'dart:async';

import 'package:analytics_client/analytics_client.dart';
import 'package:api_client/api_client.dart';
import 'package:app_links/app_links.dart';
import 'package:app_ui/app_ui.dart';
import 'package:authentication_client/authentication_client.dart';
import 'package:feature_flags_client/feature_flags_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/app/config/app_config.dart';
import 'package:flutter_starter/app/router/router.dart';
import 'package:flutter_starter/features/auth/auth.dart';
import 'package:flutter_starter/features/force_update/force_update.dart';
import 'package:flutter_starter/features/settings/settings.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:storage/storage.dart';

class App extends StatelessWidget {
  const App({
    required this.config,
    required this.secureStorage,
    required this.persistentStorage,
    required this.analyticsClient,
    required this.featureFlagsClient,
    required this.packageInfo,
    this.authenticationClient,
    this.initialToken,
    this.initialSettings = SettingsSnapshot.defaults,
    super.key,
  });

  final AppConfig config;
  final Storage secureStorage;
  final Storage persistentStorage;
  final AnalyticsClient analyticsClient;
  final FeatureFlagsClient featureFlagsClient;
  final PackageInfo packageInfo;
  final AuthenticationClient? authenticationClient;
  final String? initialToken;
  final SettingsSnapshot initialSettings;

  @override
  Widget build(BuildContext context) {
    final hasSession = initialToken != null && initialToken!.isNotEmpty;
    final initialStatus = hasSession
        ? AuthStatus.authenticated
        : AuthStatus.unknown;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppConfig>.value(value: config),
        RepositoryProvider<Storage>.value(value: secureStorage),
        RepositoryProvider<PackageInfo>.value(value: packageInfo),
        RepositoryProvider<AnalyticsClient>.value(value: analyticsClient),
        RepositoryProvider<FeatureFlagsClient>.value(value: featureFlagsClient),
        RepositoryProvider<SettingsRepository>(
          create: (_) => SettingsRepository(storage: persistentStorage),
          dispose: (repo) => repo.dispose(),
        ),
        RepositoryProvider<AuthenticationClient>(
          create: (_) =>
              authenticationClient ??
              FakeAuthenticationClient(
                initialUser: hasSession
                    ? const AuthenticationUser(
                        id: 'hydrated',
                        email: 'demo@example.com',
                      )
                    : null,
              ),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            client: context.read<AuthenticationClient>(),
            storage: context.read<Storage>(),
          ),
          dispose: (repo) => repo.dispose(),
        ),
        RepositoryProvider<ApiClient>(
          create: (context) {
            final authRepository = context.read<AuthRepository>();
            return ApiClient(
              baseUrl: config.apiBaseUrl,
              storage: context.read<Storage>(),
              onUnauthorized: authRepository.signOut,
              refreshSession: authRepository.tryRefreshSession,
              enableLogging: config.enableLogging,
            );
          },
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
              initialStatus: initialStatus,
            ),
          ),
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(
              repository: context.read<SettingsRepository>(),
              initial: initialSettings,
            ),
          ),
          BlocProvider<ForceUpdateCubit>(
            create: (context) => ForceUpdateCubit(
              flags: context.read<FeatureFlagsClient>(),
              currentVersion: packageInfo.version,
            ),
          ),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;
  late final _AnalyticsObserver _observer;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _observer = _AnalyticsObserver(context.read<AnalyticsClient>());
    _router = buildAppRouter(
      context.read<AuthCubit>(),
      context.read<SettingsCubit>(),
      context.read<ForceUpdateCubit>(),
      observers: [_observer],
    );
    unawaited(_wireDeepLinks());
  }

  Future<void> _wireDeepLinks() async {
    final links = AppLinks();
    try {
      final initial = await links.getInitialLink();
      if (initial != null) _handleLink(initial);
    } on Exception {
      // No initial deep link available; ignore.
    }
    _linkSubscription = links.uriLinkStream.listen(_handleLink);
  }

  void _handleLink(Uri uri) {
    final target = uri.hasAuthority
        ? '${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}'
        : uri.toString();
    if (target.isEmpty) return;
    _router.go(target);
  }

  @override
  void dispose() {
    unawaited(_linkSubscription?.cancel());
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}

/// Forwards every push/replace/pop to the [AnalyticsClient] as a screen view.
class _AnalyticsObserver extends NavigatorObserver {
  _AnalyticsObserver(this._analytics);

  final AnalyticsClient _analytics;

  void _track(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;
    unawaited(_analytics.screen(name));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _track(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _track(previousRoute);
  }
}
