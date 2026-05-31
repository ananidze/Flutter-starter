import 'package:flutter/material.dart';
import 'package:flutter_starter/app/router/app_routes.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class EmailLinkErrorView extends StatelessWidget {
  const EmailLinkErrorView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.link_off, size: 64, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          l10n.emailLinkErrorTitle,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => AppRoutes.login.go(context),
          child: Text(l10n.emailLinkBackToSignIn),
        ),
      ],
    );
  }
}
