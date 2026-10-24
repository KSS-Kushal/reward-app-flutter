import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/redeem_option.dart';

class RedeemOptionModel extends RedeemOption {
  const RedeemOptionModel({
    required super.id,
    required super.method,
    required super.name,
    required super.description,
    required super.minCoins,
    required super.processingTime,
    super.accountLabel,
  });

  factory RedeemOptionModel.fromJson(Map<String, dynamic> json) =>
      RedeemOptionModel(
        id: json.readString('id'),
        method: json.readEnum('method', RedeemMethod.values, RedeemMethod.upi),
        name: json.readString('name'),
        description: json.readString('description'),
        minCoins: json.readInt('minCoins'),
        processingTime: json.readString('processingTime'),
        accountLabel: json.readStringOrNull('accountLabel'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'method': method.name,
    'name': name,
    'description': description,
    'minCoins': minCoins,
    'processingTime': processingTime,
    'accountLabel': accountLabel,
  };
}
