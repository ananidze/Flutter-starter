import 'package:analytics_client/analytics_client.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// {@template firebase_analytics_client}
/// A Firebase Analytics-backed [AnalyticsClient].
/// {@endtemplate}
class FirebaseAnalyticsClient implements AnalyticsClient {
  /// {@macro firebase_analytics_client}
  const FirebaseAnalyticsClient({required FirebaseAnalytics firebaseAnalytics})
    : _firebaseAnalytics = firebaseAnalytics;

  final FirebaseAnalytics _firebaseAnalytics;

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    try {
      await _firebaseAnalytics.logEvent(
        name: name,
        parameters: _sanitize(properties),
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(TrackEventFailure(error), stackTrace);
    }
  }

  @override
  Future<void> screen(
    String screenName, {
    Map<String, Object?> properties = const {},
  }) async {
    try {
      await _firebaseAnalytics.logScreenView(
        screenName: screenName,
        parameters: _sanitize(properties),
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(TrackScreenFailure(error), stackTrace);
    }
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object?> traits = const {},
  }) async {
    try {
      await _firebaseAnalytics.setUserId(id: userId);
      for (final entry in traits.entries) {
        await _firebaseAnalytics.setUserProperty(
          name: entry.key,
          value: entry.value?.toString(),
        );
      }
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(IdentifyUserFailure(error), stackTrace);
    }
  }

  @override
  Future<void> reset() async {
    try {
      await _firebaseAnalytics.setUserId();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ResetUserFailure(error), stackTrace);
    }
  }

  /// Firebase Analytics only accepts `String`, `num`, and `bool` parameter
  /// values; this drops nulls and coerces anything else via `toString()`.
  Map<String, Object>? _sanitize(Map<String, Object?> properties) {
    if (properties.isEmpty) return null;
    final out = <String, Object>{};
    for (final entry in properties.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String || value is num || value is bool) {
        out[entry.key] = value;
      } else {
        out[entry.key] = value.toString();
      }
    }
    return out.isEmpty ? null : out;
  }
}
