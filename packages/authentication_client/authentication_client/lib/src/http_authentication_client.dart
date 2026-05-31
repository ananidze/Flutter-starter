import 'dart:async';
import 'dart:convert';

import 'package:authentication_client/authentication_client.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:token_storage/token_storage.dart';

/// Endpoint paths used by [HttpAuthenticationClient].
///
/// Override these if your backend exposes the authentication routes under
/// different paths.
@immutable
class AuthenticationEndpoints {
  /// {@macro authentication_endpoints}
  const AuthenticationEndpoints({
    this.signUp = '/auth/sign-up',
    this.signIn = '/auth/sign-in',
    this.signOut = '/auth/sign-out',
    this.refresh = '/auth/refresh',
    this.deleteAccount = '/auth/account',
    this.sendEmailLink = '/auth/email-link/send',
    this.verifyEmailLink = '/auth/email-link/verify',
    this.currentUser = '/auth/me',
  });

  /// POST — creates a new account. Body: `{ email, password, name? }`.
  final String signUp;

  /// POST — signs in with credentials. Body: `{ email, password }`.
  final String signIn;

  /// POST — invalidates the current refresh token.
  final String signOut;

  /// POST — exchanges a refresh token for a new access token.
  /// Body: `{ refresh_token }`.
  final String refresh;

  /// DELETE — deletes the current account.
  final String deleteAccount;

  /// POST — sends a magic-link email. Body: `{ email, app_package_name }`.
  final String sendEmailLink;

  /// POST — verifies an emailed magic link. Body: `{ email, email_link }`.
  final String verifyEmailLink;

  /// GET — returns the current authenticated user.
  final String currentUser;
}

/// {@template http_authentication_client}
/// An [AuthenticationClient] implementation that talks to a backend over HTTP
/// and persists session tokens in a [TokenStorage].
///
/// Endpoint paths can be customized via [AuthenticationEndpoints].
/// {@endtemplate}
class HttpAuthenticationClient implements AuthenticationClient {
  /// {@macro http_authentication_client}
  HttpAuthenticationClient({
    required Uri baseUrl,
    required TokenStorage tokenStorage,
    required TokenStorage refreshTokenStorage,
    http.Client? httpClient,
    AuthenticationEndpoints endpoints = const AuthenticationEndpoints(),
    String emailLinkScheme = 'https',
  }) : _baseUrl = baseUrl,
       _tokenStorage = tokenStorage,
       _refreshTokenStorage = refreshTokenStorage,
       _httpClient = httpClient ?? http.Client(),
       _endpoints = endpoints,
       _emailLinkScheme = emailLinkScheme {
    unawaited(_restoreSession());
  }

  final Uri _baseUrl;
  final TokenStorage _tokenStorage;
  final TokenStorage _refreshTokenStorage;
  final http.Client _httpClient;
  final AuthenticationEndpoints _endpoints;
  final String _emailLinkScheme;

  final BehaviorSubject<AuthenticationUser> _userSubject =
      BehaviorSubject<AuthenticationUser>.seeded(AuthenticationUser.anonymous);

  @override
  Stream<AuthenticationUser> get user => _userSubject.stream.distinct();

  Future<void> _restoreSession() async {
    try {
      final token = await _tokenStorage.readToken();
      if (token == null || token.isEmpty) return;
      final user = await _fetchCurrentUser(token);
      _userSubject.add(user);
    } on Object {
      await _clearTokens();
      _userSubject.add(AuthenticationUser.anonymous);
    }
  }

  Future<AuthenticationUser> _fetchCurrentUser(String accessToken) async {
    final response = await _httpClient.get(
      _resolve(_endpoints.currentUser),
      headers: {'authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _AuthHttpException(response.statusCode, response.body);
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final userJson = (body['user'] as Map<String, dynamic>?) ?? body;
    return AuthenticationUser(
      id: userJson['id'] as String? ?? '',
      email: userJson['email'] as String?,
      name: userJson['name'] as String?,
      photo: userJson['photo'] as String?,
      isNewUser: userJson['is_new_user'] as bool? ?? false,
    );
  }

  Future<AuthSession> _postForSession(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _httpClient.post(
      _resolve(path),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _AuthHttpException(response.statusCode, response.body);
    }
    return AuthSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> _persistSession(AuthSession session) async {
    await _tokenStorage.saveToken(session.accessToken);
    if (session.refreshToken.isEmpty) {
      await _refreshTokenStorage.clearToken();
    } else {
      await _refreshTokenStorage.saveToken(session.refreshToken);
    }
    _userSubject.add(session.user);
  }

  Future<void> _clearTokens() async {
    await _tokenStorage.clearToken();
    await _refreshTokenStorage.clearToken();
  }

  Uri _resolve(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    final base = _baseUrl.toString();
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final session = await _postForSession(_endpoints.signUp, {
        'email': email,
        'password': password,
        'name': ?name,
      });
      await _persistSession(session);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SignUpFailure(error), stackTrace);
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _postForSession(_endpoints.signIn, {
        'email': email,
        'password': password,
      });
      await _persistSession(session);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SignInFailure(error), stackTrace);
    }
  }

  @override
  Future<void> refreshSession() async {
    try {
      final refreshToken = await _refreshTokenStorage.readToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw StateError('No refresh token available');
      }
      final session = await _postForSession(_endpoints.refresh, {
        'refresh_token': refreshToken,
      });
      await _persistSession(session);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(RefreshSessionFailure(error), stackTrace);
    }
  }

  @override
  Future<void> sendLoginEmailLink({
    required String email,
    required String appPackageName,
  }) async {
    try {
      final response = await _httpClient.post(
        _resolve(_endpoints.sendEmailLink),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'app_package_name': appPackageName,
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _AuthHttpException(response.statusCode, response.body);
      }
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SendLoginEmailLinkFailure(error), stackTrace);
    }
  }

  @override
  bool isLogInWithEmailLink({required String emailLink}) {
    try {
      final uri = Uri.parse(emailLink);
      if (uri.scheme != _emailLinkScheme && uri.scheme != 'http') {
        return false;
      }
      return uri.queryParameters.containsKey('token') ||
          uri.queryParameters.containsKey('oobCode');
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(IsLogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  @override
  Future<void> logInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      final session = await _postForSession(_endpoints.verifyEmailLink, {
        'email': email,
        'email_link': emailLink,
      });
      await _persistSession(session);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithEmailLinkFailure(error), stackTrace);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Not yet implemented');
  }

  @override
  Future<void> signInWithApple() async {
    throw UnimplementedError('Not yet implemented');
  }

  @override
  Future<void> logOut() async {
    try {
      final accessToken = await _tokenStorage.readToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        await _httpClient.post(
          _resolve(_endpoints.signOut),
          headers: {'authorization': 'Bearer $accessToken'},
        );
      }
      await _clearTokens();
      _userSubject.add(AuthenticationUser.anonymous);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogOutFailure(error), stackTrace);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final accessToken = await _tokenStorage.readToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw StateError('No authenticated user to delete');
      }
      final response = await _httpClient.delete(
        _resolve(_endpoints.deleteAccount),
        headers: {'authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _AuthHttpException(response.statusCode, response.body);
      }
      await _clearTokens();
      _userSubject.add(AuthenticationUser.anonymous);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(DeleteAccountFailure(error), stackTrace);
    }
  }
}

class _AuthHttpException implements Exception {
  _AuthHttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'AuthHttpException($statusCode): $body';
}
