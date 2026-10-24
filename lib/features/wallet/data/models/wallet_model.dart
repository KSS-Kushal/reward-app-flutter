import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.balance,
    required super.totalEarned,
    required super.pendingCoins,
    required super.totalRedeemed,
    required super.coinsPerCurrencyUnit,
    required super.currencySymbol,
    required super.minRedeemCoins,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    balance: json.readInt('balance'),
    totalEarned: json.readInt('totalEarned'),
    pendingCoins: json.readInt('pendingCoins'),
    totalRedeemed: json.readInt('totalRedeemed'),
    coinsPerCurrencyUnit: json.readInt('coinsPerCurrencyUnit', fallback: 100),
    currencySymbol: json.readString('currencySymbol', fallback: '₹'),
    minRedeemCoins: json.readInt('minRedeemCoins', fallback: 1000),
  );

  Map<String, dynamic> toJson() => {
    'balance': balance,
    'totalEarned': totalEarned,
    'pendingCoins': pendingCoins,
    'totalRedeemed': totalRedeemed,
    'coinsPerCurrencyUnit': coinsPerCurrencyUnit,
    'currencySymbol': currencySymbol,
    'minRedeemCoins': minRedeemCoins,
  };
}
