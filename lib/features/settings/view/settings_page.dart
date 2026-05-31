import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/app/router/app_routes.dart';
import 'package:flutter_starter/features/auth/auth.dart';
import 'package:flutter_starter/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_starter/features/settings/view/widgets/widgets.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();
    final isAuthed = context.select<AuthCubit, bool>(
      (c) => c.state == AuthStatus.authenticated,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          AppSectionHeader(title: l10n.settingsAppearance),
          RadioGroup<ThemeMode>(
            groupValue: state.themeMode,
            onChanged: (mode) {
              if (mode != null) unawaited(cubit.setThemeMode(mode));
            },
            child: Column(
              children: [
                ThemeModeOption(
                  mode: ThemeMode.system,
                  label: l10n.settingsThemeSystem,
                ),
                ThemeModeOption(
                  mode: ThemeMode.light,
                  label: l10n.settingsThemeLight,
                ),
                ThemeModeOption(
                  mode: ThemeMode.dark,
                  label: l10n.settingsThemeDark,
                ),
              ],
            ),
          ),
          const Divider(),
          AppSectionHeader(title: l10n.settingsLanguage),
          RadioGroup<Locale?>(
            groupValue: state.locale,
            onChanged: cubit.setLocale,
            child: Column(
              children: [
                LocaleOption(locale: null, label: l10n.settingsLocaleSystem),
                ...AppLocalizations.supportedLocales.map(
                  (locale) =>
                      LocaleOption(locale: locale, label: localeLabel(locale)),
                ),
              ],
            ),
          ),
          if (isAuthed) ...[
            const Divider(),
            AppSectionHeader(title: l10n.settingsAccount),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.settingsProfile),
              onTap: () => AppRoutes.profile.go(context),
            ),
          ],
          const Divider(),
          AppSectionHeader(title: l10n.settingsAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAbout),
            onTap: () => AppRoutes.about.go(context),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(l10n.settingsReplayOnboarding),
            subtitle: Text(l10n.settingsReplayOnboardingSubtitle),
            onTap: () => unawaited(cubit.resetOnboarding()),
          ),
        ],
      ),
    );
  }
}
