import 'package:flutter/foundation.dart';

/// Coin balance summary. The backend is the source of truth for every value.
@immutable
class Wallet {
  const Wallet({
    required this.balance,
    required this.totalEarned,
    required this.pendingCoins,
    required this.totalRedeemed,
    required this.coinsPerCurrencyUnit,
    required this.currencySymbol,
    required this.minRedeemCoins,
  });

  /// Spendable coins.
  final int balance;
  final int totalEarned;

  /// Earned but not yet confirmed (e.g. shopping cashback).
  final int pendingCoins;
  final int totalRedeemed;

  /// How many coins make one unit of currency (e.g. 100 coins = ₹1).
  final int coinsPerCurrencyUnit;
  final String currencySymbol;
  final int minRedeemCoins;

  double get balanceInCurrency =>
      coinsPerCurrencyUnit == 0 ? 0 : balance / coinsPerCurrencyUnit;

  bool get canRedeem => balance >= minRedeemCoins;
}
