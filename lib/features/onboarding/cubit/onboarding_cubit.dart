import 'package:bloc/bloc.dart';
import 'package:flutter_starter/features/onboarding/cubit/onboarding_state.dart';
import 'package:flutter_starter/features/settings/data/settings_repository.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required SettingsRepository settingsRepository,
    List<OnboardingSlide>? slides,
  }) : _settingsRepository = settingsRepository,
       super(
         OnboardingState(slides: slides ?? defaultOnboardingSlides),
       );

  final SettingsRepository _settingsRepository;

  /// Called by the page whenever the user swipes to a new slide so the
  /// indicator and button label stay in sync.
  void pageChanged(int index) {
    if (index == state.currentIndex) return;
    emit(state.copyWith(currentIndex: index));
  }

  /// Records that onboarding is finished. The router observes the
  /// SettingsRepository change stream and redirects away from
  /// `/onboarding` once persistence completes.
  Future<void> complete() =>
      _settingsRepository.setHasSeenOnboarding(seen: true);
}
