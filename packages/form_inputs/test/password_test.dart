import 'package:form_inputs/form_inputs.dart';
import 'package:test/test.dart';

void main() {
  group('Password', () {
    test('pure is invalid with empty error', () {
      expect(const Password.pure().error, PasswordValidationError.empty);
    });

    test('dirty empty value is invalid with empty error', () {
      expect(const Password.dirty().error, PasswordValidationError.empty);
    });

    test('value shorter than minLength is invalid with tooShort error', () {
      expect(
        const Password.dirty('short').error,
        PasswordValidationError.tooShort,
      );
    });

    test('value with minLength characters is valid', () {
      expect(const Password.dirty('password').error, isNull);
    });

    test('value longer than minLength is valid', () {
      expect(const Password.dirty('a_very_long_password').error, isNull);
    });
  });
}
