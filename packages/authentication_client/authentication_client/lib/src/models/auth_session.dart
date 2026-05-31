import 'package:authentication_client/authentication_client.dart';

/// {@template auth_session}
/// Represents an authenticated session returned by the backend.
///
/// Contains an access token, a refresh token, and the authenticated user
/// profile.
/// {@endtemplate}
class AuthSession {
  /// {@macro auth_session}
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  /// Decodes a session from a JSON object returned by the backend.
  ///
  /// Expects the following shape:
  /// ```json
  /// {
  ///   "access_token": "...",
  ///   "refresh_token": "...",
  ///   "user": {
  ///     "id": "...",
  ///     "email": "...",
  ///     "name": "...",
  ///     "photo": "...",
  ///     "is_new_user": false
  ///   }
  /// }
  /// ```
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? const {};
    return AuthSession(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String? ?? '',
      user: AuthenticationUser(
        id: userJson['id'] as String,
        email: userJson['email'] as String?,
        name: userJson['name'] as String?,
        photo: userJson['photo'] as String?,
        isNewUser: userJson['is_new_user'] as bool? ?? false,
      ),
    );
  }

  /// The short-lived access token used to authenticate API requests.
  final String accessToken;

  /// The long-lived refresh token used to mint new access tokens.
  final String refreshToken;

  /// The authenticated user.
  final AuthenticationUser user;
}
