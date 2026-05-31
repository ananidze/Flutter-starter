import 'package:flutter/material.dart';

/// {@template app_inline_spinner}
/// A compact circular progress indicator sized to sit inside list tile
/// trailing slots and button labels (18×18 by default).
/// {@endtemplate}
class AppInlineSpinner extends StatelessWidget {
  /// {@macro app_inline_spinner}
  const AppInlineSpinner({
    this.size = 18,
    this.strokeWidth = 2,
    this.color,
    super.key,
  });

  /// Width and height of the spinner.
  final double size;

  /// Stroke width of the spinner ring.
  final double strokeWidth;

  /// Optional override for the ring color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}
