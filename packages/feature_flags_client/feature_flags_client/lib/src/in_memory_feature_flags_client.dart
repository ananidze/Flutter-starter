import 'dart:async';

import 'package:feature_flags_client/feature_flags_client.dart';

/// {@template in_memory_feature_flags_client}
/// An in-memory [FeatureFlagsClient] suitable for development, tests, and as
/// a fallback when no remote provider is configured.
///
/// Values supplied to the constructor act as the initial state; additional
/// values can be set via [setValues] / [setValue].
/// {@endtemplate}
class InMemoryFeatureFlagsClient implements FeatureFlagsClient {
  /// {@macro in_memory_feature_flags_client}
  InMemoryFeatureFlagsClient({Map<String, Object> initialValues = const {}})
    : _values = {...initialValues};

  final Map<String, Object> _values;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Replaces all values with [values] and emits a change event.
  void setValues(Map<String, Object> values) {
    _values
      ..clear()
      ..addAll(values);
    _changes.add(null);
  }

  /// Sets a single [key] to [value] and emits a change event.
  void setValue(String key, Object value) {
    _values[key] = value;
    _changes.add(null);
  }

  /// Closes the underlying change stream.
  Future<void> dispose() => _changes.close();

  @override
  Future<void> initialize({Map<String, Object> defaults = const {}}) async {
    for (final entry in defaults.entries) {
      _values.putIfAbsent(entry.key, () => entry.value);
    }
  }

  @override
  Future<void> refresh() async {
    _changes.add(null);
  }

  @override
  Stream<void> get onChanged => _changes.stream;

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    final v = _values[key];
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    return defaultValue;
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final v = _values[key];
    return v?.toString() ?? defaultValue;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    final v = _values[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }

  @override
  double getDouble(String key, {double defaultValue = 0}) {
    final v = _values[key];
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? defaultValue;
    return defaultValue;
  }
}
