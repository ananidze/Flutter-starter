import 'dart:async';

import 'package:authentication_client/authentication_client.dart';

/// {@template fake_authentication_client}
/// An in-memory [AuthenticationClient] used as a Tier 2 scaffold.
///
/// This implementation does not talk to any backend or persist anything to
/// storage. A real backend-backed implementation is intended to replace it
/// later.
/// {@endtemplate}
class FakeAuthenticationClient implements AuthenticationClient {
  /// {@macro fake_authentication_client}
  FakeAuthenticationClient({AuthenticationUser? initialUser})
    : _current = initialUser ?? AuthenticationUser.anonymous;

  AuthenticationUser _current;
  final StreamController<AuthenticationUser> _controller =
      StreamController<AuthenticationUser>.broadcast();

  @override
  Stream<AuthenticationUser> get user async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _emit(AuthenticationUser(id: 'fake-$email', email: email));
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    _emit(AuthenticationUser(id: 'fake-$email', email: email, name: name));
  }

  @override
  Future<void> signInWithGoogle() async {
    _emit(
      const AuthenticationUser(
        id: 'fake-google-user',
        email: 'demo@gmail.com',
        name: 'Demo User',
      ),
    );
  }

  @override
  Future<void> signInWithApple() async {
    _emit(
      const AuthenticationUser(
        id: 'fake-apple-user',
        email: 'demo@privaterelay.appleid.com',
        name: 'Demo User',
      ),
    );
  }

  @override
  Future<void> logOut() async {
    _emit(AuthenticationUser.anonymous);
  }

  @override
  Future<void> deleteAccount() async {
    _emit(AuthenticationUser.anonymous);
  }

  @override
  Future<void> refreshSession() => Future.value();

  @override
  bool isLogInWithEmailLink({required String emailLink}) {
    try {
      final uri = Uri.parse(emailLink);
      return uri.queryParameters.containsKey('token') ||
          uri.queryParameters.containsKey('oobCode');
    } on FormatException {
      return false;
    }
  }

  @override
  Future<void> sendLoginEmailLink({
    required String email,
    required String appPackageName,
  }) async {
    // No-op in the fake client — pretend the email was sent successfully.
  }

  @override
  Future<void> logInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    _emit(AuthenticationUser(id: 'fake-email-link-$email', email: email));
  }

  /// Closes the underlying stream controller.
  Future<void> dispose() => _controller.close();

  void _emit(AuthenticationUser user) {
    _current = user;
    _controller.add(user);
  }
}
