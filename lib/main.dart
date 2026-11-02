import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/config/ad_config.dart';
import 'app/config/api_config.dart';
import 'app/config/app_config.dart';
import 'core/ads/ad_providers.dart';
import 'core/di/core_providers.dart';
import 'core/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error('Uncaught error', error: error, stackTrace: stackTrace);
    return true;
  };

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final preferences = await SharedPreferences.getInstance();

  AppLogger.info(
    'Starting ${AppConfig.appName} (${AppConfig.environment.name}, '
    'mockApi: ${AppConfig.useMockApi}, baseUrl: ${ApiConfig.baseUrl}, '
    'googleServerClientId: '
    '${AppConfig.isGoogleSignInConfigured ? AppConfig.googleServerClientId : '<NOT SET>'})',
  );

  AppLogger.info(
    'Ads: ${AdConfig.adsEnabled ? 'on' : 'off'}'
    '${AdConfig.useTestAds ? ' (test ads)' : ''}; settings from the backend',
  );

  final container = ProviderContainer(
    // Failed requests surface an error view with a retry button instead of
    // being retried silently in the background.
    retry: (_, _) => null,
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const KavodnikApp()),
  );

  // Ad SDKs start in the background; the app never waits for them.
  unawaited(container.read(adServiceProvider).initialize());
}
