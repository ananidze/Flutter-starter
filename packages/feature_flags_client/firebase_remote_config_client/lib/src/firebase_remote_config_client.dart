import 'dart:async';

import 'package:feature_flags_client/feature_flags_client.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// {@template firebase_remote_config_client}
/// A Firebase Remote Config-backed [FeatureFlagsClient].
/// {@endtemplate}
class FirebaseRemoteConfigClient implements FeatureFlagsClient {
  /// {@macro firebase_remote_config_client}
  FirebaseRemoteConfigClient({
    required FirebaseRemoteConfig remoteConfig,
    Duration fetchTimeout = const Duration(seconds: 10),
    Duration minimumFetchInterval = const Duration(hours: 1),
  }) : _remoteConfig = remoteConfig,
       _fetchTimeout = fetchTimeout,
       _minimumFetchInterval = minimumFetchInterval;

  final FirebaseRemoteConfig _remoteConfig;
  final Duration _fetchTimeout;
  final Duration _minimumFetchInterval;
  StreamSubscription<RemoteConfigUpdate>? _updatesSubscription;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<void> initialize({Map<String, Object> defaults = const {}}) async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: _fetchTimeout,
          minimumFetchInterval: _minimumFetchInterval,
        ),
      );
      if (defaults.isNotEmpty) {
        await _remoteConfig.setDefaults(defaults);
      }
      _updatesSubscription = _remoteConfig.onConfigUpdated.listen((_) async {
        try {
          await _remoteConfig.activate();
        } on Exception {
          // ignore activation failures from realtime updates
        }
        _changes.add(null);
      });
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FeatureFlagsInitializationFailure(error),
        stackTrace,
      );
    }
  }

  @override
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _changes.add(null);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FeatureFlagsRefreshFailure(error),
        stackTrace,
      );
    }
  }

  @override
  Stream<void> get onChanged => _changes.stream;

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    final value = _remoteConfig.getValue(key);
    return value.source == ValueSource.valueStatic
        ? defaultValue
        : value.asBool();
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final value = _remoteConfig.getValue(key);
    return value.source == ValueSource.valueStatic
        ? defaultValue
        : value.asString();
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    final value = _remoteConfig.getValue(key);
    return value.source == ValueSource.valueStatic
        ? defaultValue
        : value.asInt();
  }

  @override
  double getDouble(String key, {double defaultValue = 0}) {
    final value = _remoteConfig.getValue(key);
    return value.source == ValueSource.valueStatic
        ? defaultValue
        : value.asDouble();
  }

  /// Closes the change-event stream and cancels realtime listeners.
  Future<void> dispose() async {
    await _updatesSubscription?.cancel();
    await _changes.close();
  }
}
