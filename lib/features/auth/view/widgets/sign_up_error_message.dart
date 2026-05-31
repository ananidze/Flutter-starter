import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_state.dart';

class SignUpErrorMessage extends StatelessWidget {
  const SignUpErrorMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.errorMessage != c.errorMessage,
      builder: (context, state) {
        final message = state.errorMessage;
        if (message == null) return const SizedBox.shrink();
        return Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        );
      },
    );
  }
}
