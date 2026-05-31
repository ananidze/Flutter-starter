import 'package:flutter/widgets.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

enum AppRoutes {
  home('/'),
  counter('/counter'),
  settings('/settings'),
  profile('/profile'),
  about('/about'),
  onboarding('/onboarding'),
  updateRequired('/update-required'),
  emailLink('/auth/email-link'),
  login('/login'),
  signUp('/signup')
  ;

  const AppRoutes(this.path);

  final String path;

  /// Returns the localized title for the route, resolved against
  /// [AppLocalizations]. Suitable for app-bar titles, settings list entries,
  /// breadcrumbs, and anywhere else the route needs a human-readable name.
  String title(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AppRoutes.home || AppRoutes.counter => l10n.counterAppBarTitle,
      AppRoutes.settings => l10n.settingsTitle,
      AppRoutes.profile => l10n.profileTitle,
      AppRoutes.about => l10n.settingsAbout,
      AppRoutes.onboarding => l10n.onboardingSlideWelcomeTitle,
      AppRoutes.updateRequired => l10n.forceUpdateTitle,
      AppRoutes.emailLink || AppRoutes.login => l10n.signInTitle,
      AppRoutes.signUp => l10n.signUpTitle,
    };
  }

  void go(BuildContext context) => context.go(path);
  Future<T?> push<T extends Object?>(BuildContext context) =>
      context.push<T>(path);
  void replace(BuildContext context) => context.replace(path);
}
