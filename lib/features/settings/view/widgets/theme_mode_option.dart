import 'package:flutter/material.dart';
import 'package:flutter_starter/features/settings/data/app_theme_mode.dart';

class ThemeModeOption extends StatelessWidget {
  const ThemeModeOption({
    required this.mode,
    required this.label,
    super.key,
  });

  final AppThemeMode mode;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppThemeMode>(value: mode, title: Text(label));
  }
}
