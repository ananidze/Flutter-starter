import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_state.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class SignInPasswordField extends StatelessWidget {
  const SignInPasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SignInCubit, SignInState>(
      buildWhen: (p, c) => p.password != c.password,
      builder: (context, state) {
        return TextField(
          key: const Key('signInPassword'),
          onChanged: context.read<SignInCubit>().passwordChanged,
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
