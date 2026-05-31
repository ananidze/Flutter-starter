import 'package:flutter/material.dart';

/// {@template app_section_header}
/// A small primary-tinted label used to group rows in a settings-style
/// `ListView` into logical sections.
/// {@endtemplate}
class AppSectionHeader extends StatelessWidget {
  /// {@macro app_section_header}
  const AppSectionHeader({
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
    super.key,
  });

  /// The section title.
  final String title;

  /// Padding around the title.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
