import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_state.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class SignUpPasswordField extends StatelessWidget {
  const SignUpPasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.password != c.password,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpPassword'),
          onChanged: context.read<SignUpCubit>().passwordChanged,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.passwordLabel,
            errorText: state.password.isPure || state.password.isValid
                ? null
                : l10n.passwordTooShort,
          ),
        );
      },
    );
  }
}
