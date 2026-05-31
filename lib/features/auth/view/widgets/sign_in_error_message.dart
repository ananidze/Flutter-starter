import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_state.dart';

class SignInErrorMessage extends StatelessWidget {
  const SignInErrorMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInCubit, SignInState>(
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
