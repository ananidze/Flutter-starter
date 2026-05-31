import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/force_update/cubit/force_update_cubit.dart';
import 'package:flutter_starter/features/force_update/view/widgets/version_row.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ForceUpdateCubit>().state;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.system_update,
                  size: 88,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.forceUpdateTitle,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.forceUpdateMessage,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                VersionRow(
                  label: l10n.forceUpdateInstalledLabel,
                  value: state.currentVersion,
                ),
                VersionRow(
                  label: l10n.forceUpdateRequiredLabel,
                  value: state.minimumVersion,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: state.storeUrl.isEmpty
                        ? null
                        : () => unawaited(
                            context.read<ForceUpdateCubit>().openStore(),
                          ),
                    label: Text(l10n.forceUpdateOpenStore),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
