import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:feature_flags_client/feature_flags_client.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/features/force_update/cubit/force_update_state.dart';
import 'package:pub_semver/pub_semver.dart';

/// Keys consumed by [ForceUpdateCubit]. Provision matching values in your
/// feature-flag provider (e.g. Firebase Remote Config) to roll out a forced
/// update without shipping a new build.
class ForceUpdateFlags {
  static const String minimumVersion = 'force_update_min_version';
  static const String storeUrl = 'force_update_store_url';
}

class ForceUpdateCubit extends Cubit<ForceUpdateState> {
  ForceUpdateCubit({
    required FeatureFlagsClient flags,
    required String currentVersion,
    Future<void> Function(String text)? clipboardWriter,
  }) : _flags = flags,
       _currentVersion = currentVersion,
       _clipboardWriter = clipboardWriter ?? _defaultClipboardWriter,
       super(ForceUpdateState(currentVersion: currentVersion)) {
    _subscription = _flags.onChanged.listen((_) => check());
    check();
  }

  final FeatureFlagsClient _flags;
  final String _currentVersion;
  final Future<void> Function(String text) _clipboardWriter;
  late final StreamSubscription<void> _subscription;

  void check() {
    final minRaw = _flags.getString(ForceUpdateFlags.minimumVersion);
    final storeUrl = _flags.getString(ForceUpdateFlags.storeUrl);

    final status = _evaluate(_currentVersion, minRaw);
    emit(
      state.copyWith(
        status: status,
        currentVersion: _currentVersion,
        minimumVersion: minRaw,
        storeUrl: storeUrl,
      ),
    );
  }

  /// Copies the store URL to the clipboard as a no-launcher fallback so the
  /// user can paste it into their browser. Apps that want true store-launch
  /// behavior can pass a `clipboardWriter` that wraps `url_launcher`.
  Future<void> openStore() async {
    if (state.storeUrl.isEmpty) return;
    await _clipboardWriter(state.storeUrl);
  }

  static Future<void> _defaultClipboardWriter(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }

  static ForceUpdateStatus _evaluate(String current, String minimum) {
    if (minimum.isEmpty) return ForceUpdateStatus.upToDate;
    final cur = _tryParse(current);
    final min = _tryParse(minimum);
    if (cur == null || min == null) return ForceUpdateStatus.upToDate;
    return cur < min ? ForceUpdateStatus.required : ForceUpdateStatus.upToDate;
  }

  static Version? _tryParse(String raw) {
    try {
      return Version.parse(raw);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
