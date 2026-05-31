import 'dart:async';
import 'dart:developer';

import 'package:analytics_client/analytics_client.dart';
import 'package:bloc/bloc.dart';
import 'package:feature_flags_client/feature_flags_client.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/app/config/app_config.dart';
import 'package:flutter_starter/features/auth/auth.dart';
import 'package:flutter_starter/features/force_update/force_update.dart';
import 'package:flutter_starter/features/settings/settings.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage/storage.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  const secureStorage = SecureStorage();
  final sharedPrefs = await SharedPreferences.getInstance();
  final persistentStorage = PersistentStorage(sharedPreferences: sharedPrefs);

  String? initialToken;
  try {
    initialToken = await secureStorage.read(key: AuthRepository.tokenKey);
  } on StorageException {
    initialToken = null;
  }

  final settingsRepository = SettingsRepository(storage: persistentStorage);
  final initialSettings = await settingsRepository.load();
  // The App owns its own SettingsRepository; release this one immediately.
  await settingsRepository.dispose();

  final analyticsClient = InMemoryAnalyticsClient(
    logger: config.enableLogging ? log : null,
  );

  final featureFlagsClient = InMemoryFeatureFlagsClient(
    initialValues: const {
      ForceUpdateFlags.minimumVersion: '0.0.0',
      ForceUpdateFlags.storeUrl: '',
    },
  );
  try {
    await featureFlagsClient.initialize();
  } on FeatureFlagsException catch (error, stackTrace) {
    log('Feature flags init failed', error: error, stackTrace: stackTrace);
  }

  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    App(
      config: config,
      secureStorage: secureStorage,
      persistentStorage: persistentStorage,
      analyticsClient: analyticsClient,
      featureFlagsClient: featureFlagsClient,
      packageInfo: packageInfo,
      initialToken: initialToken,
      initialSettings: initialSettings,
    ),
  );
}
