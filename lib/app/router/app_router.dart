import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_starter/app/router/app_routes.dart';
import 'package:flutter_starter/app/router/pages.dart';
import 'package:flutter_starter/features/auth/auth.dart';
import 'package:flutter_starter/features/counter/counter.dart';
import 'package:flutter_starter/features/force_update/force_update.dart';
import 'package:flutter_starter/features/onboarding/onboarding.dart';
import 'package:flutter_starter/features/profile/profile.dart';
import 'package:flutter_starter/features/settings/settings.dart';
import 'package:go_router/go_router.dart';

/// Builds the [GoRouter] used by the app.
///
/// Redirect priority (high → low):
///   1. Force-update required → [AppRoutes.updateRequired]
///   2. Onboarding not yet seen → [AppRoutes.onboarding]
///   3. Unauthenticated user on a protected route → [AppRoutes.login]
///   4. Authenticated user on an auth-only route → [AppRoutes.home]
GoRouter buildAppRouter(
  AuthCubit authCubit,
  SettingsCubit settingsCubit,
  ForceUpdateCubit forceUpdateCubit, {
  String initialLocation = '/',
  List<NavigatorObserver> observers = const [],
}) {
  final refreshListenable = _MergedListenable([
    _StreamListenable<AuthStatus>(authCubit.stream),
    _StreamListenable<SettingsState>(settingsCubit.stream),
    _StreamListenable<ForceUpdateState>(forceUpdateCubit.stream),
  ]);

  return GoRouter(
    initialLocation: initialLocation,
    observers: observers,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final authStatus = authCubit.state;
      final hasSeenOnboarding = settingsCubit.state.hasSeenOnboarding;
      final updateRequired =
          forceUpdateCubit.state.status == ForceUpdateStatus.required;

      // 1. Force-update gate wins over everything.
      if (updateRequired && loc != AppRoutes.updateRequired.path) {
        return AppRoutes.updateRequired.path;
      }
      if (!updateRequired && loc == AppRoutes.updateRequired.path) {
        return AppRoutes.home.path;
      }

      // Email-link auth is always reachable so deep links from the OS work
      // before any auth state has had a chance to settle.
      if (loc.startsWith(AppRoutes.emailLink.path)) return null;

      if (authStatus == AuthStatus.unknown) return null;

      // 2. Onboarding gate (only meaningful before sign-in screens).
      if (!hasSeenOnboarding && loc != AppRoutes.onboarding.path) {
        return AppRoutes.onboarding.path;
      }
      if (hasSeenOnboarding && loc == AppRoutes.onboarding.path) {
        return AppRoutes.home.path;
      }
      // Onboarding is a public page — skip auth gate until it's completed.
      if (!hasSeenOnboarding) return null;

      // 3 & 4. Auth gates.
      final isAuthPage =
          loc == AppRoutes.login.path || loc == AppRoutes.signUp.path;
      final isAuthed = authStatus == AuthStatus.authenticated;
      if (!isAuthed && !isAuthPage) return AppRoutes.login.path;
      if (isAuthed && isAuthPage) return AppRoutes.home.path;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home.path,
        name: AppRoutes.home.name,
        builder: (context, state) => const CounterPage(),
      ),
      GoRoute(
        path: AppRoutes.counter.path,
        name: AppRoutes.counter.name,
        builder: (context, state) => const CounterPage(),
      ),
      GoRoute(
        path: AppRoutes.settings.path,
        name: AppRoutes.settings.name,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.profile.path,
        name: AppRoutes.profile.name,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.about.path,
        name: AppRoutes.about.name,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding.path,
        name: AppRoutes.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.updateRequired.path,
        name: AppRoutes.updateRequired.name,
        builder: (context, state) => const ForceUpdatePage(),
      ),
      GoRoute(
        path: AppRoutes.emailLink.path,
        name: AppRoutes.emailLink.name,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final link =
              state.uri.queryParameters['link'] ?? state.uri.toString();
          return EmailLinkSignInPage(email: email, link: link);
        },
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp.path,
        name: AppRoutes.signUp.name,
        builder: (context, state) => const SignUpPage(),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
}

class _StreamListenable<T> extends ChangeNotifier {
  _StreamListenable(Stream<T> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<T> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

class _MergedListenable extends ChangeNotifier {
  _MergedListenable(this._sources) {
    for (final source in _sources) {
      source.addListener(notifyListeners);
    }
  }

  final List<Listenable> _sources;

  @override
  void dispose() {
    for (final source in _sources) {
      source.removeListener(notifyListeners);
      if (source is ChangeNotifier) source.dispose();
    }
    super.dispose();
  }
}
