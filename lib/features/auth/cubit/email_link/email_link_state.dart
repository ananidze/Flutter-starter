import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';

class EmailLinkState extends Equatable {
  const EmailLinkState({
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final String? errorMessage;

  EmailLinkState copyWith({
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmailLinkState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
