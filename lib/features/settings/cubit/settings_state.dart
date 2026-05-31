import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_starter/features/settings/data/app_theme_mode.dart';
import 'package:flutter_starter/features/settings/data/settings_repository.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = AppThemeMode.system,
    this.locale,
    this.hasSeenOnboarding = false,
  });

  factory SettingsState.fromSnapshot(SettingsSnapshot snapshot) {
    return SettingsState(
      themeMode: snapshot.themeMode,
      locale: snapshot.locale,
      hasSeenOnboarding: snapshot.hasSeenOnboarding,
    );
  }

  final AppThemeMode themeMode;
  final Locale? locale;
  final bool hasSeenOnboarding;

  SettingsState copyWith({
    AppThemeMode? themeMode,
    Locale? Function()? locale,
    bool? hasSeenOnboarding,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale != null ? locale() : this.locale,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, hasSeenOnboarding];
}
