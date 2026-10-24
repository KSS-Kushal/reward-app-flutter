import 'package:flutter/foundation.dart';

enum TransactionType { credit, debit }

enum TransactionStatus { completed, pending, failed }

/// Where coins came from or went to.
enum TransactionSource {
  checkIn,
  spinWheel,
  scratchCard,
  captcha,
  quiz,
  article,
  shopping,
  referral,
  redeem,
  bonus,
}

@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.status,
    required this.source,
    required this.createdAt,
    this.description,
    this.reference,
  });

  final String id;
  final String title;
  final String? description;

  /// Absolute number of coins; direction is given by [type].
  final int amount;
  final TransactionType type;
  final TransactionStatus status;
  final TransactionSource source;
  final DateTime createdAt;

  /// External reference (payout id, order id...).
  final String? reference;

  bool get isCredit => type == TransactionType.credit;

  /// Signed amount: positive for credits, negative for debits.
  int get signedAmount => isCredit ? amount : -amount;
}
