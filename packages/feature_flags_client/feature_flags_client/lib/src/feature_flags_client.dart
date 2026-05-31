/// {@template feature_flags_exception}
/// Exceptions from the feature flags client.
/// {@endtemplate}
abstract class FeatureFlagsException implements Exception {
  /// {@macro feature_flags_exception}
  const FeatureFlagsException(this.error);

  /// The underlying error.
  final Object error;
}

/// {@template feature_flags_initialization_failure}
/// Thrown when initializing the underlying feature flags provider fails.
/// {@endtemplate}
class FeatureFlagsInitializationFailure extends FeatureFlagsException {
  /// {@macro feature_flags_initialization_failure}
  const FeatureFlagsInitializationFailure(super.error);
}

/// {@template feature_flags_refresh_failure}
/// Thrown when refreshing remote values fails.
/// {@endtemplate}
class FeatureFlagsRefreshFailure extends FeatureFlagsException {
  /// {@macro feature_flags_refresh_failure}
  const FeatureFlagsRefreshFailure(super.error);
}

/// A generic feature flags / remote-config client interface.
///
/// Implementations must return values immediately from a local cache (or
/// supplied defaults) — async refresh is exposed via [refresh].
abstract class FeatureFlagsClient {
  /// Initializes the underlying provider with [defaults] as the in-memory
  /// fallback before the first [refresh] succeeds.
  ///
  /// Throws a [FeatureFlagsInitializationFailure] on failure.
  Future<void> initialize({Map<String, Object> defaults = const {}});

  /// Fetches the latest remote values.
  ///
  /// Throws a [FeatureFlagsRefreshFailure] on failure.
  Future<void> refresh();

  /// A stream that emits whenever values change (either from a [refresh] or a
  /// realtime update from the underlying provider).
  Stream<void> get onChanged;

  /// Returns the boolean value for [key], falling back to [defaultValue].
  bool getBool(String key, {bool defaultValue = false});

  /// Returns the string value for [key], falling back to [defaultValue].
  String getString(String key, {String defaultValue = ''});

  /// Returns the integer value for [key], falling back to [defaultValue].
  int getInt(String key, {int defaultValue = 0});

  /// Returns the double value for [key], falling back to [defaultValue].
  double getDouble(String key, {double defaultValue = 0});
}
