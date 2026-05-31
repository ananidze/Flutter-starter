import 'package:flutter/material.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class EmailLinkBusyView extends StatelessWidget {
  const EmailLinkBusyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(context.l10n.emailLinkBusy),
      ],
    );
  }
}
