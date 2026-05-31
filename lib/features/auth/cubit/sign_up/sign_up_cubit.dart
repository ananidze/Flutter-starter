import 'package:authentication_client/authentication_client.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_state.dart';
import 'package:flutter_starter/features/auth/data/auth_repository.dart';
import 'package:form_inputs/form_inputs.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authRepository) : super(const SignUpState());

  final AuthRepository _authRepository;

  void nameChanged(String value) {
    emit(state.copyWith(name: Name.dirty(value)));
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: Email.dirty(value)));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    final confirmed = ConfirmedPassword.dirty(
      password: value,
      value: state.confirmedPassword.value,
    );
    emit(state.copyWith(password: password, confirmedPassword: confirmed));
  }

  void confirmedPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmedPassword: ConfirmedPassword.dirty(
          password: state.password.value,
          value: value,
        ),
      ),
    );
  }

  Future<void> signUp() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authRepository.signUp(
        email: state.email.value,
        password: state.password.value,
        name: state.name.value,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on SignUpFailure catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.error.toString(),
        ),
      );
    }
  }
}
