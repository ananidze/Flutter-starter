import 'package:analytics_client/analytics_client.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// {@template posthog_analytics_client}
/// A PostHog-backed [AnalyticsClient].
/// {@endtemplate}
class PostHogAnalyticsClient implements AnalyticsClient {
  /// {@macro posthog_analytics_client}
  PostHogAnalyticsClient({Posthog? posthog}) : _posthog = posthog ?? Posthog();

  final Posthog _posthog;

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    try {
      await _posthog.capture(
        eventName: name,
        properties: _sanitize(properties),
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
      await _posthog.screen(
        screenName: screenName,
        properties: _sanitize(properties),
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
      await _posthog.identify(
        userId: userId,
        userProperties: _sanitize(traits),
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(IdentifyUserFailure(error), stackTrace);
    }
  }

  @override
  Future<void> reset() async {
    try {
      await _posthog.reset();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ResetUserFailure(error), stackTrace);
    }
  }

  Map<String, Object>? _sanitize(Map<String, Object?> properties) {
    if (properties.isEmpty) return null;
    final out = <String, Object>{};
    for (final entry in properties.entries) {
      final value = entry.value;
      if (value != null) out[entry.key] = value;
    }
    return out.isEmpty ? null : out;
  }
}
