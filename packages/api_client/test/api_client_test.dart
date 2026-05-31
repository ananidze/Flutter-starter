import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storage/storage.dart';

class _MockStorage extends Mock implements Storage {}

/// An interceptor used in tests to short-circuit the Dio request pipeline
/// after the [ApiClient]'s interceptors have run. This lets the tests inspect
/// the final [RequestOptions.headers] and assert on auth header behavior.
class _TerminatingInterceptor extends Interceptor {
  _TerminatingInterceptor({this.statusCode = 200});

  final int statusCode;

  RequestOptions? lastRequest;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    lastRequest = options;
    if (statusCode >= 200 && statusCode < 300) {
      handler.resolve(
        Response<Object?>(requestOptions: options, statusCode: statusCode),
      );
    } else {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response<Object?>(
            requestOptions: options,
            statusCode: statusCode,
          ),
          type: DioExceptionType.badResponse,
        ),
        true,
      );
    }
  }
}

void main() {
  group('ApiClient', () {
    const baseUrl = 'https://api.example.com';
    const tokenKey = 'auth_token';

    late Storage storage;

    setUp(() {
      storage = _MockStorage();
    });

    ApiClient buildClient({
      required _TerminatingInterceptor terminator,
      required Future<void> Function() onUnauthorized,
    }) {
      final dio = Dio();
      final client = ApiClient(
        baseUrl: baseUrl,
        storage: storage,
        onUnauthorized: onUnauthorized,
        dio: dio,
      );
      client.dio.interceptors.add(terminator);
      return client;
    }

    test(
      'attaches Authorization header when storage returns a token',
      () async {
        when(
          () => storage.read(key: tokenKey),
        ).thenAnswer((_) async => 'abc123');

        final terminator = _TerminatingInterceptor();
        final client = buildClient(
          terminator: terminator,
          onUnauthorized: () async {},
        );

        await client.dio.get<Object?>('/users');

        expect(
          terminator.lastRequest?.headers['Authorization'],
          'Bearer abc123',
        );
      },
    );

    test(
      'does not attach Authorization header when storage returns null',
      () async {
        when(() => storage.read(key: tokenKey)).thenAnswer((_) async => null);

        final terminator = _TerminatingInterceptor();
        final client = buildClient(
          terminator: terminator,
          onUnauthorized: () async {},
        );

        await client.dio.get<Object?>('/users');

        expect(
          terminator.lastRequest?.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );

    test(
      '401 response triggers onUnauthorized once and propagates the error',
      () async {
        when(() => storage.read(key: tokenKey)).thenAnswer((_) async => null);

        var callCount = 0;
        final terminator = _TerminatingInterceptor(statusCode: 401);
        final client = buildClient(
          terminator: terminator,
          onUnauthorized: () async {
            callCount++;
          },
        );

        await expectLater(
          client.dio.get<Object?>('/users'),
          throwsA(isA<DioException>()),
        );
        expect(callCount, 1);
      },
    );

    test(
      'swallows StorageException and proceeds without auth header',
      () async {
        when(
          () => storage.read(key: tokenKey),
        ).thenThrow(const StorageException('boom'));

        final terminator = _TerminatingInterceptor();
        final client = buildClient(
          terminator: terminator,
          onUnauthorized: () async {},
        );

        await client.dio.get<Object?>('/users');

        expect(
          terminator.lastRequest?.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );
  });
}
