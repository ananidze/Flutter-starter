import 'package:form_inputs/form_inputs.dart';
import 'package:test/test.dart';

void main() {
  group('Name', () {
    test('pure is invalid', () {
      expect(const Name.pure().error, NameValidationError.empty);
    });

    test('empty string is invalid', () {
      expect(const Name.dirty().error, NameValidationError.empty);
    });

    test('whitespace-only is invalid', () {
      expect(const Name.dirty('   ').error, NameValidationError.empty);
    });

    test('non-empty value is valid', () {
      expect(const Name.dirty('Demo User').error, isNull);
    });
  });
}
