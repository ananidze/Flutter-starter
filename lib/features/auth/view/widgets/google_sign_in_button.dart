import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_cubit.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('signInGoogle'),
      onPressed: () => context.read<SignInCubit>().signInWithGoogle(),
      icon: const Icon(Icons.g_mobiledata),
      label: Text(context.l10n.signInWithGoogle),
    );
  }
}
