import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_cubit.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('signInApple'),
      onPressed: () => context.read<SignInCubit>().signInWithApple(),
      icon: const Icon(Icons.apple),
      label: Text(context.l10n.signInWithApple),
    );
  }
}
