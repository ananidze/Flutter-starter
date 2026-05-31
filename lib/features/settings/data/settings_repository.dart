import 'dart:async';
import 'dart:ui';

import 'package:flutter_starter/features/settings/data/app_theme_mode.dart';
import 'package:meta/meta.dart';
import 'package:storage/storage.dart';

/// Persists user-controlled app settings (theme mode, locale, onboarding) to
/// a [Storage] backend.
///
/// Exposes a [Stream] that emits whenever any value changes so the rest of
/// the app can react to user-driven changes without polling.
class SettingsRepository {
  SettingsRepository({required Storage storage}) : _storage = storage;

  final Storage _storage;
  final StreamController<SettingsSnapshot> _controller =
      StreamController<SettingsSnapshot>.broadcast();

  static const String _themeModeKey = 'settings.theme_mode';
  static const String _localeKey = 'settings.locale';
  static const String _onboardingKey = 'settings.has_seen_onboarding';

  /// Emits a fresh [SettingsSnapshot] whenever any value changes.
  Stream<SettingsSnapshot> get changes => _controller.stream;

  /// Loads the current snapshot from storage.
  Future<SettingsSnapshot> load() async {
    final themeRaw = await _read(_themeModeKey);
    final localeRaw = await _read(_localeKey);
    final onboardingRaw = await _read(_onboardingKey);
    return SettingsSnapshot(
      themeMode: _decodeThemeMode(themeRaw),
      locale: _decodeLocale(localeRaw),
      hasSeenOnboarding: onboardingRaw == 'true',
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _write(_themeModeKey, _encodeThemeMode(mode));
    await _emit();
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _delete(_localeKey);
    } else {
      await _write(_localeKey, locale.toLanguageTag());
    }
    await _emit();
  }

  Future<void> setHasSeenOnboarding({required bool seen}) async {
    await _write(_onboardingKey, seen ? 'true' : 'false');
    await _emit();
  }

  Future<void> _emit() async {
    if (_controller.isClosed) return;
    _controller.add(await load());
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on StorageException {
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on StorageException {
      // Best-effort; ignore storage failures.
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on StorageException {
      // Best-effort.
    }
  }

  static String _encodeThemeMode(AppThemeMode mode) => switch (mode) {
    AppThemeMode.light => 'light',
    AppThemeMode.dark => 'dark',
    AppThemeMode.system => 'system',
  };

  static AppThemeMode _decodeThemeMode(String? raw) => switch (raw) {
    'light' => AppThemeMode.light,
    'dark' => AppThemeMode.dark,
    _ => AppThemeMode.system,
  };

  static Locale? _decodeLocale(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('-');
    return parts.length == 1 ? Locale(parts[0]) : Locale(parts[0], parts[1]);
  }

  /// Closes the underlying change stream.
  Future<void> dispose() => _controller.close();
}

/// An immutable snapshot of the persisted app settings.
@immutable
class SettingsSnapshot {
  const SettingsSnapshot({
    required this.themeMode,
    required this.locale,
    required this.hasSeenOnboarding,
  });

  /// Sensible defaults: follow system theme, system locale, no onboarding seen.
  static const SettingsSnapshot defaults = SettingsSnapshot(
    themeMode: AppThemeMode.system,
    locale: null,
    hasSeenOnboarding: false,
  );

  final AppThemeMode themeMode;
  final Locale? locale;
  final bool hasSeenOnboarding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsSnapshot &&
          other.themeMode == themeMode &&
          other.locale == locale &&
          other.hasSeenOnboarding == hasSeenOnboarding;

  @override
  int get hashCode => Object.hash(themeMode, locale, hasSeenOnboarding);
}
