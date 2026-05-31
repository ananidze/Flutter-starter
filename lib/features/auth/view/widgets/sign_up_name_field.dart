import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_state.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class SignUpNameField extends StatelessWidget {
  const SignUpNameField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.name != c.name,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpName'),
          onChanged: context.read<SignUpCubit>().nameChanged,
          decoration: InputDecoration(
            labelText: l10n.signUpNameLabel,
            errorText: state.name.isPure || state.name.isValid
                ? null
                : l10n.signUpNameEmpty,
          ),
        );
      },
    );
  }
}
