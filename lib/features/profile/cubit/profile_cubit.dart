import 'package:bloc/bloc.dart';
import 'package:flutter_starter/features/auth/data/auth_repository.dart';
import 'package:flutter_starter/features/profile/cubit/profile_state.dart';
import 'package:form_inputs/form_inputs.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthRepository authRepository,
    required String appPackageName,
  }) : _authRepository = authRepository,
       _appPackageName = appPackageName,
       super(const ProfileState());

  final AuthRepository _authRepository;
  final String _appPackageName;

  Future<void> signOut() async {
    if (state.isBusy) return;
    emit(
      state.copyWith(
        signOutStatus: FormzSubmissionStatus.inProgress,
        clearError: true,
      ),
    );
    try {
      await _authRepository.signOut();
      emit(state.copyWith(signOutStatus: FormzSubmissionStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          signOutStatus: FormzSubmissionStatus.failure,
          exceptionMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    if (state.isBusy) return;
    emit(
      state.copyWith(
        deleteStatus: FormzSubmissionStatus.inProgress,
        clearError: true,
      ),
    );
    try {
      await _authRepository.deleteAccount();
      emit(state.copyWith(deleteStatus: FormzSubmissionStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          deleteStatus: FormzSubmissionStatus.failure,
          exceptionMessage: e.toString(),
        ),
      );
    }
  }

  /// Sends a password-reset email to the currently signed-in user.
  ///
  /// Encapsulates "what email and what package to send to" so the page only
  /// needs to invoke a single no-arg method.
  Future<void> resetCurrentUserPassword() async {
    if (state.isBusy) return;
    final email = _authRepository.currentUser.email;
    if (email == null || email.isEmpty) {
      emit(
        state.copyWith(
          resetEmailStatus: FormzSubmissionStatus.failure,
          error: ProfileError.noEmailAssociated,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        resetEmailStatus: FormzSubmissionStatus.inProgress,
        clearError: true,
      ),
    );
    try {
      await _authRepository.sendPasswordResetEmail(
        email: email,
        appPackageName: _appPackageName,
      );
      emit(state.copyWith(resetEmailStatus: FormzSubmissionStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          resetEmailStatus: FormzSubmissionStatus.failure,
          exceptionMessage: e.toString(),
        ),
      );
    }
  }
}
