import 'package:formz/formz.dart';

/// Password Form Input Validation Error
enum PasswordValidationError {
  /// Password is empty
  empty,

  /// Password is shorter than [Password.minLength]
  tooShort,
}

/// {@template password}
/// Reusable password form input. Requires a minimum of
/// [Password.minLength] characters.
/// {@endtemplate}
class Password extends FormzInput<String, PasswordValidationError> {
  /// {@macro password}
  const Password.pure() : super.pure('');

  /// {@macro password}
  const Password.dirty([super.value = '']) : super.dirty();

  /// Minimum number of characters required for a password to be valid.
  static const int minLength = 8;

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < minLength) return PasswordValidationError.tooShort;
    return null;
  }
}
