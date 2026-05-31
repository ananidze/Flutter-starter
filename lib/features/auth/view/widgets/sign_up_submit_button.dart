import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_state.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:form_inputs/form_inputs.dart';

class SignUpSubmitButton extends StatelessWidget {
  const SignUpSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.status != c.status || p.isValid != c.isValid,
      builder: (context, state) {
        final isLoading = state.status.isInProgress;
        return FilledButton(
          key: const Key('signUpSubmit'),
          onPressed: isLoading || !state.isValid
              ? null
              : () => context.read<SignUpCubit>().signUp(),
          child: isLoading ? const AppInlineSpinner() : Text(l10n.signUpSubmit),
        );
      },
    );
  }
}
