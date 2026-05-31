import 'package:authentication_client/authentication_client.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_state.dart';
import 'package:flutter_starter/features/auth/data/auth_repository.dart';
import 'package:form_inputs/form_inputs.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._authRepository) : super(const SignInState());

  final AuthRepository _authRepository;

  void emailChanged(String value) {
    emit(state.copyWith(email: Email.dirty(value)));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: Password.dirty(value)));
  }

  Future<void> signInWithEmailAndPassword() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authRepository.signIn(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on SignInFailure catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.error.toString(),
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authRepository.signInWithGoogle();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on SignInWithGoogleFailure catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.error.toString(),
        ),
      );
    }
  }

  Future<void> signInWithApple() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authRepository.signInWithApple();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on SignInWithAppleFailure catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.error.toString(),
        ),
      );
    }
  }
}
