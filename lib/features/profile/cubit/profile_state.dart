import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';

/// Semantic, locale-agnostic error keys emitted by `ProfileCubit` for
/// conditions the UI knows how to translate.
enum ProfileError { noEmailAssociated }

class ProfileState extends Equatable {
  const ProfileState({
    this.deleteStatus = FormzSubmissionStatus.initial,
    this.signOutStatus = FormzSubmissionStatus.initial,
    this.resetEmailStatus = FormzSubmissionStatus.initial,
    this.error,
    this.exceptionMessage,
  });

  final FormzSubmissionStatus deleteStatus;
  final FormzSubmissionStatus signOutStatus;
  final FormzSubmissionStatus resetEmailStatus;

  /// Semantic cubit-originated error; resolve to a localized string in UI.
  final ProfileError? error;

  /// Raw exception text passed through from a caught [Exception]. Not
  /// expected to be user-facing in production — most apps should surface a
  /// generic localized message instead. Kept here so the boilerplate is
  /// honest about where the gap is.
  final String? exceptionMessage;

  bool get isBusy =>
      deleteStatus.isInProgress ||
      signOutStatus.isInProgress ||
      resetEmailStatus.isInProgress;

  ProfileState copyWith({
    FormzSubmissionStatus? deleteStatus,
    FormzSubmissionStatus? signOutStatus,
    FormzSubmissionStatus? resetEmailStatus,
    ProfileError? error,
    String? exceptionMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      deleteStatus: deleteStatus ?? this.deleteStatus,
      signOutStatus: signOutStatus ?? this.signOutStatus,
      resetEmailStatus: resetEmailStatus ?? this.resetEmailStatus,
      error: clearError ? null : (error ?? this.error),
      exceptionMessage: clearError
          ? null
          : (exceptionMessage ?? this.exceptionMessage),
    );
  }

  @override
  List<Object?> get props => [
    deleteStatus,
    signOutStatus,
    resetEmailStatus,
    error,
    exceptionMessage,
  ];
}
