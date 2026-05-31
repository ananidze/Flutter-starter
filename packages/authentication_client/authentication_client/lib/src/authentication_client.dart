import 'dart:async';

import 'package:authentication_client/authentication_client.dart';

/// {@template authentication_exception}
/// Exceptions from the authentication client.
/// {@endtemplate}
abstract class AuthenticationException implements Exception {
  /// {@macro authentication_exception}
  const AuthenticationException(this.error);

  /// The error which was caught.
  final Object error;
}

/// {@template sign_up_failure}
/// Thrown during the sign up process if a failure occurs.
/// {@endtemplate}
class SignUpFailure extends AuthenticationException {
  /// {@macro sign_up_failure}
  const SignUpFailure(super.error);
}

/// {@template sign_in_failure}
/// Thrown during the sign in process if a failure occurs.
/// {@endtemplate}
class SignInFailure extends AuthenticationException {
  /// {@macro sign_in_failure}
  const SignInFailure(super.error);
}

/// {@template refresh_session_failure}
/// Thrown during the refresh session process if a failure occurs.
/// {@endtemplate}
class RefreshSessionFailure extends AuthenticationException {
  /// {@macro refresh_session_failure}
  const RefreshSessionFailure(super.error);
}

/// {@template send_login_email_link_failure}
/// Thrown during the sending login email link process if a failure occurs.
/// {@endtemplate}
class SendLoginEmailLinkFailure extends AuthenticationException {
  /// {@macro send_login_email_link_failure}
  const SendLoginEmailLinkFailure(super.error);
}

/// {@template is_log_in_email_link_failure}
/// Thrown during the validation of the email link process if a failure occurs.
/// {@endtemplate}
class IsLogInWithEmailLinkFailure extends AuthenticationException {
  /// {@macro is_log_in_email_link_failure}
  const IsLogInWithEmailLinkFailure(super.error);
}

/// {@template log_in_with_email_link_failure}
/// Thrown during the sign in with email link process if a failure occurs.
/// {@endtemplate}
class LogInWithEmailLinkFailure extends AuthenticationException {
  /// {@macro log_in_with_email_link_failure}
  const LogInWithEmailLinkFailure(super.error);
}

/// {@template log_out_failure}
/// Thrown during the logout process if a failure occurs.
/// {@endtemplate}
class LogOutFailure extends AuthenticationException {
  /// {@macro log_out_failure}
  const LogOutFailure(super.error);
}

/// {@template delete_account_failure}
/// Thrown during the delete account process if a failure occurs.
/// {@endtemplate}
class DeleteAccountFailure extends AuthenticationException {
  /// {@macro delete_account_failure}
  const DeleteAccountFailure(super.error);
}

/// {@template sign_in_with_google_failure}
/// Thrown during the sign in with Google process if a failure occurs.
/// {@endtemplate}
class SignInWithGoogleFailure extends AuthenticationException {
  /// {@macro sign_in_with_google_failure}
  const SignInWithGoogleFailure(super.error);
}

/// {@template sign_in_with_apple_failure}
/// Thrown during the sign in with Apple process if a failure occurs.
/// {@endtemplate}
class SignInWithAppleFailure extends AuthenticationException {
  /// {@macro sign_in_with_apple_failure}
  const SignInWithAppleFailure(super.error);
}

/// A generic Authentication Client Interface backed by a custom backend.
abstract class AuthenticationClient {
  /// Stream of [AuthenticationUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [AuthenticationUser.anonymous] if the user is not authenticated.
  Stream<AuthenticationUser> get user;

  /// Creates a new account with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  });

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [SignInFailure] if an exception occurs.
  Future<void> signIn({
    required String email,
    required String password,
  });

  /// Refreshes the current session using the stored refresh token.
  ///
  /// Throws a [RefreshSessionFailure] if an exception occurs.
  Future<void> refreshSession();

  /// Sends an authentication link to the provided [email].
  ///
  /// Opening the link should redirect to the app with [appPackageName]
  /// and authenticate the user based on the provided email link.
  ///
  /// Throws a [SendLoginEmailLinkFailure] if an exception occurs.
  Future<void> sendLoginEmailLink({
    required String email,
    required String appPackageName,
  });

  /// Checks if an incoming [emailLink] is a sign-in with email link.
  ///
  /// Throws a [IsLogInWithEmailLinkFailure] if an exception occurs.
  bool isLogInWithEmailLink({required String emailLink});

  /// Signs in with the provided [email] and [emailLink].
  ///
  /// Throws a [LogInWithEmailLinkFailure] if an exception occurs.
  Future<void> logInWithEmailLink({
    required String email,
    required String emailLink,
  });

  /// Signs in via Google OAuth.
  ///
  /// Throws a [SignInWithGoogleFailure] if an exception occurs.
  Future<void> signInWithGoogle();

  /// Signs in via Apple OAuth.
  ///
  /// Throws a [SignInWithAppleFailure] if an exception occurs.
  Future<void> signInWithApple();

  /// Signs out the current user which will emit
  /// [AuthenticationUser.anonymous] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut();

  /// Deletes the current user account.
  ///
  /// Throws a [DeleteAccountFailure] if an exception occurs.
  Future<void> deleteAccount();
}
