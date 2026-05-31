import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_state.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class SignUpEmailField extends StatelessWidget {
  const SignUpEmailField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.email != c.email,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpEmail'),
          onChanged: context.read<SignUpCubit>().emailChanged,
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
