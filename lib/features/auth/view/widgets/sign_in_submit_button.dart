import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_state.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:form_inputs/form_inputs.dart';

class SignInSubmitButton extends StatelessWidget {
  const SignInSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SignInCubit, SignInState>(
      buildWhen: (p, c) => p.status != c.status || p.isValid != c.isValid,
      builder: (context, state) {
        final isLoading = state.status.isInProgress;
        return FilledButton(
          key: const Key('signInSubmit'),
          onPressed: isLoading || !state.isValid
              ? null
              : () => context.read<SignInCubit>().signInWithEmailAndPassword(),
          child: isLoading ? const AppInlineSpinner() : Text(l10n.signInSubmit),
        );
      },
    );
  }
}
