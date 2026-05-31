import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_state.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class SignUpConfirmedPasswordField extends StatelessWidget {
  const SignUpConfirmedPasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.confirmedPassword != c.confirmedPassword,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpConfirmedPassword'),
          onChanged: context.read<SignUpCubit>().confirmedPasswordChanged,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.signUpConfirmPasswordLabel,
            errorText:
                state.confirmedPassword.isPure ||
                    state.confirmedPassword.isValid
                ? null
                : l10n.signUpPasswordsMismatch,
          ),
        );
      },
    );
  }
}
