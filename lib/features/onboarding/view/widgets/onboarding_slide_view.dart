import 'package:flutter/material.dart';
import 'package:flutter_starter/features/onboarding/cubit/onboarding_state.dart';
import 'package:flutter_starter/l10n/l10n.dart';

class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({required this.slide, super.key});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final (title, body) = _copyFor(slide, l10n);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(slide.icon, size: 96, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  (String title, String body) _copyFor(
    OnboardingSlide slide,
    AppLocalizations l10n,
  ) => switch (slide) {
    OnboardingSlide.welcome => (
      l10n.onboardingSlideWelcomeTitle,
      l10n.onboardingSlideWelcomeBody,
    ),
    OnboardingSlide.auth => (
      l10n.onboardingSlideAuthTitle,
      l10n.onboardingSlideAuthBody,
    ),
    OnboardingSlide.flags => (
      l10n.onboardingSlideFlagsTitle,
      l10n.onboardingSlideFlagsBody,
    ),
  };
}
