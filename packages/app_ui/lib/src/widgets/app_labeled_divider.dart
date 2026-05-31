import 'package:flutter/material.dart';

/// {@template app_labeled_divider}
/// A horizontal divider with a centered text label, commonly used to
/// separate primary form actions from secondary ones (e.g. "or").
/// {@endtemplate}
class AppLabeledDivider extends StatelessWidget {
  /// {@macro app_labeled_divider}
  const AppLabeledDivider({
    required this.label,
    this.horizontalPadding = 12,
    super.key,
  });

  /// The text shown between the two divider segments.
  final String label;

  /// Horizontal padding around [label].
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(label),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
