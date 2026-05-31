import 'package:analytics_client/analytics_client.dart';

/// {@template analytics_record}
/// A recorded analytics call kept in memory by [InMemoryAnalyticsClient].
/// {@endtemplate}
class AnalyticsRecord {
  /// {@macro analytics_record}
  const AnalyticsRecord({
    required this.kind,
    required this.name,
    this.properties = const {},
    this.userId,
  });

  /// Kind of the call: `'event'`, `'screen'`, `'identify'`, or `'reset'`.
  final String kind;

  /// Event name, screen name, or user id (for identify/reset).
  final String name;

  /// Properties or traits associated with the call.
  final Map<String, Object?> properties;

  /// Optional userId at the time of the call.
  final String? userId;

  @override
  String toString() =>
      'AnalyticsRecord($kind, $name, props=$properties, user=$userId)';
}

/// {@template in_memory_analytics_client}
/// An in-memory [AnalyticsClient] suitable for development, debug builds,
/// and overrides where no real analytics destination is wired up.
///
/// Each call is appended to [records] and (optionally) printed via the
/// provided `logger`.
/// {@endtemplate}
class InMemoryAnalyticsClient implements AnalyticsClient {
  /// {@macro in_memory_analytics_client}
  InMemoryAnalyticsClient({void Function(String message)? logger})
    : _logger = logger;

  final void Function(String message)? _logger;
  final List<AnalyticsRecord> _records = [];
  String? _currentUserId;

  /// All recorded calls, in order.
  List<AnalyticsRecord> get records => List.unmodifiable(_records);

  /// The currently identified user, if any.
  String? get currentUserId => _currentUserId;

  void _add(AnalyticsRecord record) {
    _records.add(record);
    _logger?.call(record.toString());
  }

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    _add(
      AnalyticsRecord(
        kind: 'event',
        name: name,
        properties: properties,
        userId: _currentUserId,
      ),
    );
  }

  @override
  Future<void> screen(
    String screenName, {
    Map<String, Object?> properties = const {},
  }) async {
    _add(
      AnalyticsRecord(
        kind: 'screen',
        name: screenName,
        properties: properties,
        userId: _currentUserId,
      ),
    );
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object?> traits = const {},
  }) async {
    _currentUserId = userId;
    _add(
      AnalyticsRecord(
        kind: 'identify',
        name: userId,
        properties: traits,
        userId: userId,
      ),
    );
  }

  @override
  Future<void> reset() async {
    _add(
      AnalyticsRecord(kind: 'reset', name: '', userId: _currentUserId),
    );
    _currentUserId = null;
  }
}
