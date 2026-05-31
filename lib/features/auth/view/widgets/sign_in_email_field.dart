import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_state.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class SignInEmailField extends StatelessWidget {
  const SignInEmailField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SignInCubit, SignInState>(
      buildWhen: (p, c) => p.email != c.email,
      builder: (context, state) {
        return TextField(
          key: const Key('signInEmail'),
          onChanged: context.read<SignInCubit>().emailChanged,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.emailLabel,
            errorText: state.email.isPure || state.email.isValid
                ? null
                : l10n.emailInvalid,
          ),
        );
      },
    );
  }
}
