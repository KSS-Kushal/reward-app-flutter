import 'package:flutter/foundation.dart';

enum RedeemMethod { upi, paytm, amazonPay, googlePlay }

/// A payout channel the user can convert coins into.
@immutable
class RedeemOption {
  const RedeemOption({
    required this.id,
    required this.method,
    required this.name,
    required this.description,
    required this.minCoins,
    required this.processingTime,
    this.accountLabel,
  });

  final String id;
  final RedeemMethod method;
  final String name;
  final String description;
  final int minCoins;

  /// e.g. "Within 24 hours".
  final String processingTime;

  /// Label of the account field ("UPI ID", "Email"). `null` when the payout
  /// goes to the account on file.
  final String? accountLabel;
}
