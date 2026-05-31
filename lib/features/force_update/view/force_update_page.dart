import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/force_update/cubit/force_update_cubit.dart';
import 'package:flutter_starter/features/force_update/view/widgets/version_row.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

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
                        : () => unawaited(_openStore(state.storeUrl)),
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

  Future<void> _openStore(String storeUrl) async {
    final uri = Uri.tryParse(storeUrl);
    if (uri == null || !uri.hasScheme) {
      await Clipboard.setData(ClipboardData(text: storeUrl));
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: storeUrl));
      }
    } on Exception {
      await Clipboard.setData(ClipboardData(text: storeUrl));
    }
  }
}
