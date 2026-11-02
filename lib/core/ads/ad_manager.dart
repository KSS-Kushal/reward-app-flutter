import 'dart:async';

import '../utils/app_logger.dart';
import 'ad_models.dart';
import 'ad_service.dart';
import 'settings/ad_settings.dart';

/// The app's [AdService]: loads the admin settings at start-up, then
/// delegates to the service built from them.
///
/// - settings with `enabled: false` → [DisabledAdService] (no ads, rewards
///   collected without one);
/// - no settings at all → [UnavailableAdService] (no ads, rewards wait);
/// - otherwise the service from [createService].
class AdManager implements AdService {
  AdManager({
    required this._loadSettings,
    required this._createService,
    this.readyTimeout = const Duration(seconds: 15),
  });

  static const _tag = 'Ads';

  final Future<AdSettings?> Function() _loadSettings;
  final AdService Function(AdSettings) _createService;

  /// How long a rewarded request waits for start-up to finish.
  final Duration readyTimeout;

  final _ready = Completer<void>();
  bool _started = false;
  AdService? _service;

  @override
  bool get isEnabled => _service?.isEnabled ?? false;

  @override
  Future<void> initialize() {
    if (_started) return _ready.future;
    _started = true;
    unawaited(_start());
    return _ready.future;
  }

  Future<void> _start() async {
    try {
      final settings = await _loadSettings();
      if (settings == null) {
        _service = const UnavailableAdService();
      } else if (!settings.enabled) {
        AppLogger.info('Ads switched off by the admin', tag: _tag);
        _service = const DisabledAdService();
      } else {
        final service = _createService(settings);
        await service.initialize();
        _service = service;
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Ad start-up failed',
        tag: _tag,
        error: error,
        stackTrace: stackTrace,
      );
      _service = const UnavailableAdService();
    } finally {
      _ready.complete();
    }
  }

  @override
  Future<RewardedAdOutcome> showRewarded({
    required AdPlacement placement,
    String? customData,
  }) async {
    unawaited(initialize());
    await _ready.future.timeout(readyTimeout, onTimeout: () {});
    final service = _service;
    if (service == null) return const RewardedAdUnavailable();
    return service.showRewarded(placement: placement, customData: customData);
  }

  @override
  Future<void> onScreenChanged() async => _service?.onScreenChanged();

  @override
  List<AdUnit> bannerUnits(AdPlacement placement) =>
      _service?.bannerUnits(placement) ?? const [];

  @override
  void recordBannerShown(AdNetwork network) =>
      _service?.recordBannerShown(network);

  @override
  AdUnit? nativeUnit(AdPlacement placement) => _service?.nativeUnit(placement);
}
