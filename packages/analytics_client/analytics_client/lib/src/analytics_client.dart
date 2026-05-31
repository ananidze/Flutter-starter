/// {@template analytics_exception}
/// Exceptions from the analytics client.
/// {@endtemplate}
abstract class AnalyticsException implements Exception {
  /// {@macro analytics_exception}
  const AnalyticsException(this.error);

  /// The error which was caught.
  final Object error;
}

/// {@template track_event_failure}
/// Thrown when tracking a custom event fails.
/// {@endtemplate}
class TrackEventFailure extends AnalyticsException {
  /// {@macro track_event_failure}
  const TrackEventFailure(super.error);
}

/// {@template identify_user_failure}
/// Thrown when identifying the current user fails.
/// {@endtemplate}
class IdentifyUserFailure extends AnalyticsException {
  /// {@macro identify_user_failure}
  const IdentifyUserFailure(super.error);
}

/// {@template reset_user_failure}
/// Thrown when resetting the current user (e.g. on sign-out) fails.
/// {@endtemplate}
class ResetUserFailure extends AnalyticsException {
  /// {@macro reset_user_failure}
  const ResetUserFailure(super.error);
}

/// {@template track_screen_failure}
/// Thrown when tracking a screen view fails.
/// {@endtemplate}
class TrackScreenFailure extends AnalyticsException {
  /// {@macro track_screen_failure}
  const TrackScreenFailure(super.error);
}

/// A generic analytics client interface.
///
/// Implementations are expected to be safe to call before the underlying
/// provider has finished initializing — implementations should buffer or
/// swallow early calls rather than throwing.
abstract class AnalyticsClient {
  /// Tracks a custom event with the given [name] and optional [properties].
  ///
  /// Throws a [TrackEventFailure] on failure.
  Future<void> track(String name, {Map<String, Object?> properties});

  /// Tracks a screen view with the given [screenName].
  ///
  /// Throws a [TrackScreenFailure] on failure.
  Future<void> screen(String screenName, {Map<String, Object?> properties});

  /// Associates subsequent events with the user identified by [userId].
  ///
  /// Optional [traits] are attached as user properties.
  ///
  /// Throws an [IdentifyUserFailure] on failure.
  Future<void> identify(String userId, {Map<String, Object?> traits});

  /// Clears the current user association, typically on sign-out.
  ///
  /// Throws a [ResetUserFailure] on failure.
  Future<void> reset();
}
