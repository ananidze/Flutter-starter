import 'package:formz/formz.dart';

/// Name Form Input Validation Error
enum NameValidationError {
  /// Name is empty (or contains only whitespace)
  empty,
}

/// {@template name}
/// Reusable name form input. Rejects empty or whitespace-only values.
/// {@endtemplate}
class Name extends FormzInput<String, NameValidationError> {
  /// {@macro name}
  const Name.pure() : super.pure('');

  /// {@macro name}
  const Name.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String value) {
    return value.trim().isEmpty ? NameValidationError.empty : null;
  }
}
