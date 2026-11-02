import '../../mock/mock_latency.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import '../../network/api_response.dart';
import 'ad_settings_model.dart';

abstract interface class AdSettingsRemoteSource {
  Future<AdSettingsModel> fetch();
}

/// `GET /ads/config`. Public (no token), so ads can start before sign-in.
class AdSettingsApiSource implements AdSettingsRemoteSource {
  const AdSettingsApiSource(this._client);

  final ApiClient _client;

  @override
  Future<AdSettingsModel> fetch() => _client.get(
    ApiEndpoints.adsConfig,
    authenticated: false,
    parser: (data) => AdSettingsModel.fromJson(ApiResponse.asObject(data)),
  );
}

/// Mock backend: AdMob test ads with every placement on.
class AdSettingsMockSource implements AdSettingsRemoteSource {
  const AdSettingsMockSource();

  @override
  Future<AdSettingsModel> fetch() async {
    await MockLatency.simulate();
    return AdSettingsModel.developmentDefaults;
  }
}
