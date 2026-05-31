import 'package:formz/formz.dart';

/// Confirmed Password Form Input Validation Error
enum ConfirmedPasswordValidationError {
  /// Confirmed password is empty
  empty,

  /// Confirmed password does not match the source password
  mismatch,
}

/// {@template confirmed_password}
/// Reusable confirmed-password form input. Considered valid when the value
/// matches the source [password] supplied at construction.
/// {@endtemplate}
class ConfirmedPassword
    extends FormzInput<String, ConfirmedPasswordValidationError> {
  /// {@macro confirmed_password}
  const ConfirmedPassword.pure({this.password = ''}) : super.pure('');

  /// {@macro confirmed_password}
  const ConfirmedPassword.dirty({required this.password, String value = ''})
    : super.dirty(value);

  /// The source password this confirmation must match.
  final String password;

  @override
  ConfirmedPasswordValidationError? validator(String value) {
    if (value.isEmpty) return ConfirmedPasswordValidationError.empty;
    return value == password ? null : ConfirmedPasswordValidationError.mismatch;
  }
}
