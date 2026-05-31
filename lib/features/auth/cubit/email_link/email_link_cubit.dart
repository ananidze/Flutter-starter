import 'package:bloc/bloc.dart';
import 'package:flutter_starter/features/auth/cubit/email_link/email_link_state.dart';
import 'package:flutter_starter/features/auth/data/auth_repository.dart';
import 'package:form_inputs/form_inputs.dart';

class EmailLinkCubit extends Cubit<EmailLinkState> {
  EmailLinkCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const EmailLinkState());

  final AuthRepository _authRepository;

  Future<void> verify({required String email, required String link}) async {
    if (state.status.isInProgress) return;
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        clearError: true,
      ),
    );
    try {
      await _authRepository.logInWithEmailLink(email: email, emailLink: link);
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
