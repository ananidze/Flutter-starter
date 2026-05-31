import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:flutter_starter/features/auth/data/auth_status.dart';
import 'package:storage/storage.dart';

/// Wraps an [AuthenticationClient] and a [Storage] for token persistence.
///
/// Exposes:
///   - a [Stream] of [AuthStatus] derived from the underlying user stream
///   - a synchronous [currentUser] snapshot of the latest emitted user
///   - pass-throughs for sign-in / sign-up / OAuth / password reset /
///     change password / delete account / sign-out / refresh
class AuthRepository {
  AuthRepository({
    required AuthenticationClient client,
    required Storage storage,
  }) : _client = client,
       _storage = storage {
    _subscription = _client.user.listen((u) => _currentUser = u);
  }

  final AuthenticationClient _client;
  final Storage _storage;
  late final StreamSubscription<AuthenticationUser> _subscription;
  AuthenticationUser _currentUser = AuthenticationUser.anonymous;

  /// Key under which a session marker is stored. `bootstrap` reads this on
  /// startup to seed the initial [AuthStatus] and avoid a `/login` flicker
  /// when a session already exists.
  static const String tokenKey = 'auth_token';

  /// Emits the current [AuthStatus] whenever the underlying user changes.
  Stream<AuthStatus> get status => _client.user.map(_toStatus);

  /// The latest [AuthenticationUser] emitted on the underlying user stream.
  ///
  /// Returns [AuthenticationUser.anonymous] until the first emission.
  AuthenticationUser get currentUser => _currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _client.signIn(email: email, password: password);
    await _writeToken('email-$email');
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    await _client.signUp(email: email, password: password, name: name);
    await _writeToken('email-$email');
  }

  Future<void> signInWithGoogle() async {
    await _client.signInWithGoogle();
    await _writeToken('google');
  }

  Future<void> signInWithApple() async {
    await _client.signInWithApple();
    await _writeToken('apple');
  }

  Future<void> sendPasswordResetEmail({
    required String email,
    required String appPackageName,
  }) {
    return _client.sendLoginEmailLink(
      email: email,
      appPackageName: appPackageName,
    );
  }

  /// Completes sign-in via an email-link previously delivered by
  /// [sendPasswordResetEmail] (or a separate magic-link flow).
  Future<void> logInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    await _client.logInWithEmailLink(email: email, emailLink: emailLink);
    await _writeToken('email-link-$email');
  }

  /// `true` if [emailLink] is recognized as a sign-in link by the underlying
  /// auth client.
  bool isLogInWithEmailLink({required String emailLink}) =>
      _client.isLogInWithEmailLink(emailLink: emailLink);

  Future<void> signOut() async {
    await _client.logOut();
    await _clearToken();
  }

  Future<void> deleteAccount() async {
    await _client.deleteAccount();
    await _clearToken();
  }

  Future<void> refreshSession() => _client.refreshSession();

  /// Best-effort refresh used by `ApiClient`: returns `true` if a new access
  /// token was obtained, `false` otherwise. Never throws.
  Future<bool> tryRefreshSession() async {
    try {
      await _client.refreshSession();
      return true;
    } on Object {
      return false;
    }
  }

  Future<void> _writeToken(String tag) async {
    try {
      await _storage.write(key: tokenKey, value: 'fake-token-$tag');
    } on StorageException {
      // best-effort; storage may be unavailable (e.g. in widget tests)
    }
  }

  Future<void> _clearToken() async {
    try {
      await _storage.delete(key: tokenKey);
    } on StorageException {
      // best-effort; ignore storage failures on sign-out
    }
  }

  /// Releases the underlying user-stream subscription.
  Future<void> dispose() => _subscription.cancel();

  static AuthStatus _toStatus(AuthenticationUser user) =>
      user.isAnonymous ? AuthStatus.unauthenticated : AuthStatus.authenticated;
}
