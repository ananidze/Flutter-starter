import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Identifies a slide in the onboarding deck. The icon lives here (it's
/// presentation-agnostic data), but the title and body are resolved from
/// `AppLocalizations` at build time so locale switches take effect mid-flow.
enum OnboardingSlide {
  welcome(Icons.rocket_launch_outlined),
  auth(Icons.lock_outline),
  flags(Icons.insights_outlined)
  ;

  const OnboardingSlide(this.icon);

  final IconData icon;
}

/// Default slide order. Override by passing `slides` to `OnboardingCubit`.
const List<OnboardingSlide> defaultOnboardingSlides = [
  OnboardingSlide.welcome,
  OnboardingSlide.auth,
  OnboardingSlide.flags,
];

class OnboardingState extends Equatable {
  const OnboardingState({
    this.currentIndex = 0,
    this.slides = defaultOnboardingSlides,
  });

  final int currentIndex;
  final List<OnboardingSlide> slides;

  bool get isLast => currentIndex >= slides.length - 1;
  bool get isFirst => currentIndex == 0;
  int get total => slides.length;

  OnboardingState copyWith({int? currentIndex, List<OnboardingSlide>? slides}) {
    return OnboardingState(
      currentIndex: currentIndex ?? this.currentIndex,
      slides: slides ?? this.slides,
    );
  }

  @override
  List<Object?> get props => [currentIndex, slides];
}
