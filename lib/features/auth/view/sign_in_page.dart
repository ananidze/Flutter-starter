import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/sign_in/sign_in_cubit.dart';
import 'package:flutter_starter/features/auth/data/auth_repository.dart';
import 'package:flutter_starter/features/auth/view/widgets/widgets.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (context) => SignInCubit(context.read<AuthRepository>()),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signInTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SignInEmailField(),
            const SizedBox(height: 12),
            const SignInPasswordField(),
            const SizedBox(height: 8),
            const SignInErrorMessage(),
            const SizedBox(height: 16),
            const SignInSubmitButton(),
            const SizedBox(height: 24),
            AppLabeledDivider(label: l10n.commonOr),
            const SizedBox(height: 16),
            const GoogleSignInButton(),
            const SizedBox(height: 8),
            const AppleSignInButton(),
            const SizedBox(height: 24),
            TextButton(
              key: const Key('signInGoToSignUp'),
              onPressed: () => context.go('/signup'),
              child: Text(l10n.signInGoToSignUp),
            ),
          ],
        ),
      ),
    );
  }
}
