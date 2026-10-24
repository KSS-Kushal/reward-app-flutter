import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../shared/models/paginated_list.dart';
import '../models/redeem_option_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

abstract interface class WalletRemoteDataSource {
  Future<WalletModel> getWallet();

  Future<PaginatedList<TransactionModel>> getTransactions({
    required int page,
    required int pageSize,
  });

  Future<List<RedeemOptionModel>> getRedeemOptions();

  Future<TransactionModel> redeem({
    required String optionId,
    required int coins,
    String? accountDetails,
  });
}

class WalletApiDataSource implements WalletRemoteDataSource {
  const WalletApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<WalletModel> getWallet() => _client.get(
    ApiEndpoints.wallet,
    parser: (data) => WalletModel.fromJson(ApiResponse.asObject(data)),
  );

  @override
  Future<PaginatedList<TransactionModel>> getTransactions({
    required int page,
    required int pageSize,
  }) => _client.get(
    ApiEndpoints.transactions,
    queryParameters: {'page': page, 'limit': pageSize},
    parser: (data) => PaginatedList.fromJson(
      ApiResponse.asObject(data),
      TransactionModel.fromJson,
    ),
  );

  @override
  Future<List<RedeemOptionModel>> getRedeemOptions() => _client.get(
    ApiEndpoints.redeemOptions,
    parser: (data) =>
        ApiResponse.asList(data)
            .map(RedeemOptionModel.fromJson)
            .toList(growable: false),
  );

  @override
  Future<TransactionModel> redeem({
    required String optionId,
    required int coins,
    String? accountDetails,
  }) => _client.post(
    ApiEndpoints.redeem,
    body: {
      'optionId': optionId,
      'coins': coins,
      'accountDetails': ?accountDetails,
    },
    parser: (data) => TransactionModel.fromJson(ApiResponse.asObject(data)),
  );
}
