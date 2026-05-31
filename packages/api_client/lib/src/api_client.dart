import 'dart:async';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:storage/storage.dart';

/// Signature of a callback that attempts to refresh the current session.
///
/// Returns `true` if a new access token was successfully obtained and
/// persisted (so a 401-failing request can be retried), `false` otherwise.
typedef RefreshSession = Future<bool> Function();

/// {@template api_client}
/// An HTTP client that wraps [Dio] with auth, refresh, 401, and logging
/// interceptors:
///
/// 1. Attaches a bearer token (read from [Storage]) to every outgoing request.
/// 2. On a 401 response, optionally invokes `refreshSession` and retries the
///    failed request once with the freshly-stored token. Concurrent 401s are
///    coalesced into a single refresh attempt.
/// 3. If `refreshSession` is not provided, or the refresh fails (or the retry
///    also returns 401), `onUnauthorized` is invoked exactly once and the
///    original error is propagated.
/// 4. Optionally pretty-prints requests/responses when `enableLogging` is set.
/// {@endtemplate}
class ApiClient {
  /// {@macro api_client}
  ApiClient({
    required String baseUrl,
    required Storage storage,
    required Future<void> Function() onUnauthorized,
    RefreshSession? refreshSession,
    String tokenKey = 'auth_token',
    bool enableLogging = false,
    Dio? dio,
  }) : _dio = dio ?? Dio(),
       _storage = storage,
       _tokenKey = tokenKey,
       _onUnauthorized = onUnauthorized,
       _refreshSession = refreshSession {
    _dio.options = _dio.options.copyWith(baseUrl: baseUrl);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storage.read(key: _tokenKey);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } on StorageException {
            // Proceed without the auth header if reading the token fails.
          }
          handler.next(options);
        },
        onError: _onError,
      ),
    );

    if (enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: false,
        ),
      );
    }
  }

  final Dio _dio;
  final Storage _storage;
  final String _tokenKey;
  final Future<void> Function() _onUnauthorized;
  final RefreshSession? _refreshSession;

  /// In-flight refresh, shared across concurrent 401s so we only refresh once.
  Future<bool>? _pendingRefresh;

  /// The underlying [Dio] instance used to make HTTP requests.
  Dio get dio => _dio;

  static const String _retriedFlag = 'x-api-client-retried';

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final request = err.requestOptions;
    final alreadyRetried = request.extra[_retriedFlag] == true;

    if (response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    if (_refreshSession == null) {
      await _onUnauthorized();
      handler.next(err);
      return;
    }

    final refreshed = await (_pendingRefresh ??= _runRefresh());
    if (!refreshed) {
      handler.next(err);
      return;
    }

    try {
      final retryResponse = await _retry(request);
      handler.resolve(retryResponse);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  Future<bool> _runRefresh() async {
    try {
      final ok = await _refreshSession!();
      if (!ok) await _onUnauthorized();
      return ok;
    } on Object {
      await _onUnauthorized();
      return false;
    } finally {
      _pendingRefresh = null;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions request) {
    final newOptions = Options(
      method: request.method,
      headers: Map<String, dynamic>.from(request.headers)
        ..remove('Authorization'),
      contentType: request.contentType,
      responseType: request.responseType,
      sendTimeout: request.sendTimeout,
      receiveTimeout: request.receiveTimeout,
      extra: {...request.extra, _retriedFlag: true},
    );
    return _dio.request<dynamic>(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      cancelToken: request.cancelToken,
      options: newOptions,
    );
  }
}
