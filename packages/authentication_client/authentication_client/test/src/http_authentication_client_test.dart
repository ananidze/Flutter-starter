import 'dart:convert';

import 'package:authentication_client/authentication_client.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:token_storage/token_storage.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _FakeUri extends Fake implements Uri {}

class _FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUri());
    registerFallbackValue(_FakeBaseRequest());
  });

  group('HttpAuthenticationClient', () {
    final baseUrl = Uri.parse('https://api.example.com');

    late http.Client httpClient;
    late TokenStorage tokenStorage;
    late TokenStorage refreshTokenStorage;
    late HttpAuthenticationClient client;

    setUp(() {
      httpClient = _MockHttpClient();
      tokenStorage = InMemoryTokenStorage();
      refreshTokenStorage = InMemoryTokenStorage();
      when(
        () => httpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('{}', 401));
      client = HttpAuthenticationClient(
        baseUrl: baseUrl,
        tokenStorage: tokenStorage,
        refreshTokenStorage: refreshTokenStorage,
        httpClient: httpClient,
      );
    });

    String sessionJson({String id = 'u1', String email = 'a@b.com'}) =>
        jsonEncode({
          'access_token': 'access-123',
          'refresh_token': 'refresh-456',
          'expires_in': 3600,
          'user': {
            'id': id,
            'email': email,
            'name': 'Test',
            'photo': null,
            'is_new_user': false,
          },
        });

    test('signIn persists session and emits user', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(sessionJson(), 200));

      await client.signIn(email: 'a@b.com', password: 'pw');

      expect(await tokenStorage.readToken(), 'access-123');
      expect(await refreshTokenStorage.readToken(), 'refresh-456');
      await expectLater(
        client.user,
        emits(predicate<AuthenticationUser>((u) => u.id == 'u1')),
      );
    });

    test('signUp wraps errors in SignUpFailure', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{"error":"bad"}', 400));

      expect(
        () => client.signUp(email: 'a@b.com', password: 'pw'),
        throwsA(isA<SignUpFailure>()),
      );
    });

    test('logOut clears tokens and emits anonymous', () async {
      await tokenStorage.saveToken('access-123');
      await refreshTokenStorage.saveToken('refresh-456');
      when(
        () => httpClient.post(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('', 204));

      await client.logOut();

      expect(await tokenStorage.readToken(), isNull);
      expect(await refreshTokenStorage.readToken(), isNull);
    });

    test('refreshSession fails when no refresh token is stored', () async {
      expect(
        client.refreshSession,
        throwsA(isA<RefreshSessionFailure>()),
      );
    });

    test('isLogInWithEmailLink detects token query param', () {
      expect(
        client.isLogInWithEmailLink(
          emailLink: 'https://example.com/auth?token=abc',
        ),
        isTrue,
      );
      expect(
        client.isLogInWithEmailLink(emailLink: 'https://example.com/auth'),
        isFalse,
      );
    });
  });
}
