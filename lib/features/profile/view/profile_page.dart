import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/auth.dart';
import 'package:flutter_starter/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_starter/features/profile/cubit/profile_state.dart';
import 'package:flutter_starter/features/profile/view/widgets/widgets.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => ProfileCubit(
        authRepository: context.read<AuthRepository>(),
        appPackageName: context.read<PackageInfo>().packageName,
      ),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (p, c) =>
          p.error != c.error ||
          p.exceptionMessage != c.exceptionMessage ||
          p.resetEmailStatus != c.resetEmailStatus,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        final errorText = _resolveError(state, l10n);
        if (errorText != null) {
          messenger.showSnackBar(SnackBar(content: Text(errorText)));
        }
        if (state.resetEmailStatus.isSuccess) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.profilePasswordResetSent)),
          );
        }
      },
      builder: (context, state) {
        final isAuthed = context.select<AuthCubit, bool>(
          (c) => c.state == AuthStatus.authenticated,
        );
        return Scaffold(
          appBar: AppBar(title: Text(l10n.profileTitle)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const UserCard(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(l10n.profileSendPasswordReset),
                trailing: state.resetEmailStatus.isInProgress
                    ? const AppInlineSpinner()
                    : null,
                onTap: isAuthed && !state.isBusy
                    ? context.read<ProfileCubit>().resetCurrentUserPassword
                    : null,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.profileSignOut),
                trailing: state.signOutStatus.isInProgress
                    ? const AppInlineSpinner()
                    : null,
                onTap: state.isBusy
                    ? null
                    : context.read<ProfileCubit>().signOut,
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l10n.profileDeleteAccount,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                trailing: state.deleteStatus.isInProgress
                    ? const AppInlineSpinner()
                    : null,
                onTap: state.isBusy ? null : () => _confirmDelete(context),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _resolveError(ProfileState state, AppLocalizations l10n) {
    if (state.error != null) {
      return switch (state.error!) {
        ProfileError.noEmailAssociated => l10n.profileNoEmailAssociated,
      };
    }
    return state.exceptionMessage;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final confirmed = await showDeleteAccountDialog(context);
    if (confirmed ?? false) await cubit.deleteAccount();
  }
}
