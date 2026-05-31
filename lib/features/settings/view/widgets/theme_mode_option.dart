import 'package:flutter/material.dart';

class ThemeModeOption extends StatelessWidget {
  const ThemeModeOption({
    required this.mode,
    required this.label,
    super.key,
  });

  final ThemeMode mode;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(value: mode, title: Text(label));
  }
}
