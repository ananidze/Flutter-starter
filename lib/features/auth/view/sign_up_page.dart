import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_up/sign_up_cubit.dart';
import 'package:flutter_starter/features/auth/data/auth_repository.dart';
import 'package:flutter_starter/features/auth/view/widgets/widgets.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpCubit>(
      create: (context) => SignUpCubit(context.read<AuthRepository>()),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatelessWidget {
  const _SignUpView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signUpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SignUpNameField(),
            const SizedBox(height: 12),
            const SignUpEmailField(),
            const SizedBox(height: 12),
            const SignUpPasswordField(),
            const SizedBox(height: 12),
            const SignUpConfirmedPasswordField(),
            const SizedBox(height: 8),
            const SignUpErrorMessage(),
            const SizedBox(height: 16),
            const SignUpSubmitButton(),
            const SizedBox(height: 24),
            TextButton(
              key: const Key('signUpGoToSignIn'),
              onPressed: () => context.go('/login'),
              child: Text(l10n.signUpGoToSignIn),
            ),
          ],
        ),
      ),
    );
  }
}
