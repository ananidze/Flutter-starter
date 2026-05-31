// This package is just an abstraction.
// See custom_authentication_client for a concrete implementation.

// ignore_for_file: prefer_const_constructors

import 'package:authentication_client/authentication_client.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class FakeAuthenticationClient extends Fake implements AuthenticationClient {}

void main() {
  test('AuthenticationClient can be implemented', () {
    expect(FakeAuthenticationClient.new, returnsNormally);
  });

  test('exports SignUpFailure', () {
    expect(() => SignUpFailure('oops'), returnsNormally);
  });

  test('exports SignInFailure', () {
    expect(() => SignInFailure('oops'), returnsNormally);
  });

  test('exports RefreshSessionFailure', () {
    expect(() => RefreshSessionFailure('oops'), returnsNormally);
  });

  test('exports SendLoginEmailLinkFailure', () {
    expect(() => SendLoginEmailLinkFailure('oops'), returnsNormally);
  });

  test('exports IsLogInWithEmailLinkFailure', () {
    expect(() => IsLogInWithEmailLinkFailure('oops'), returnsNormally);
  });

  test('exports LogInWithEmailLinkFailure', () {
    expect(() => LogInWithEmailLinkFailure('oops'), returnsNormally);
  });

  test('exports LogOutFailure', () {
    expect(() => LogOutFailure('oops'), returnsNormally);
  });

  test('exports DeleteAccountFailure', () {
    expect(() => DeleteAccountFailure('oops'), returnsNormally);
  });
}
