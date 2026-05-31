import 'package:form_inputs/form_inputs.dart';
import 'package:test/test.dart';

void main() {
  group('ConfirmedPassword', () {
    test('pure is invalid with empty error', () {
      expect(
        const ConfirmedPassword.pure().error,
        ConfirmedPasswordValidationError.empty,
      );
    });

    test('empty dirty value is invalid with empty error', () {
      expect(
        const ConfirmedPassword.dirty(password: 'abc').error,
        ConfirmedPasswordValidationError.empty,
      );
    });

    test('non-matching value is invalid with mismatch error', () {
      expect(
        const ConfirmedPassword.dirty(password: 'abc', value: 'xyz').error,
        ConfirmedPasswordValidationError.mismatch,
      );
    });

    test('matching value is valid', () {
      expect(
        const ConfirmedPassword.dirty(password: 'abc', value: 'abc').error,
        isNull,
      );
    });
  });
}
