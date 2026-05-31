import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/features/settings/cubit/settings_state.dart';
import 'package:flutter_starter/features/settings/data/settings_repository.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required SettingsRepository repository,
    SettingsSnapshot initial = SettingsSnapshot.defaults,
  }) : _repository = repository,
       super(SettingsState.fromSnapshot(initial)) {
    _subscription = _repository.changes.listen(
      (snapshot) => emit(SettingsState.fromSnapshot(snapshot)),
    );
  }

  final SettingsRepository _repository;
  late final StreamSubscription<SettingsSnapshot> _subscription;

  Future<void> setThemeMode(ThemeMode mode) => _repository.setThemeMode(mode);

  Future<void> setLocale(Locale? locale) => _repository.setLocale(locale);

  Future<void> completeOnboarding() =>
      _repository.setHasSeenOnboarding(seen: true);

  /// Resets the onboarding flag — handy for testing the onboarding flow from
  /// the settings screen during development.
  Future<void> resetOnboarding() =>
      _repository.setHasSeenOnboarding(seen: false);

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
