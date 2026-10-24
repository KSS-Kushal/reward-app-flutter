import '../../domain/entities/transaction.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

/// In-memory stand-in for the backend ledger.
///
/// Every mock data source that awards coins (rewards, quiz, articles...)
/// credits this ledger, so balances stay consistent across the app exactly
/// like they would with a real backend.
class MockWalletLedger {
  MockWalletLedger({DateTime? now}) {
    _seed(now ?? DateTime.now());
  }

  static const coinsPerCurrencyUnit = 100;
  static const minRedeemCoins = 1000;

  final List<TransactionModel> _transactions = [];
  int _sequence = 0;

  WalletModel get wallet {
    var balance = 0;
    var earned = 0;
    var pending = 0;
    var redeemed = 0;
    for (final tx in _transactions) {
      if (tx.status == TransactionStatus.failed) continue;
      if (tx.isCredit) {
        if (tx.status == TransactionStatus.pending) {
          pending += tx.amount;
        } else {
          balance += tx.amount;
          earned += tx.amount;
        }
      } else {
        balance -= tx.amount;
        redeemed += tx.amount;
      }
    }
    return WalletModel(
      balance: balance,
      totalEarned: earned,
      pendingCoins: pending,
      totalRedeemed: redeemed,
      coinsPerCurrencyUnit: coinsPerCurrencyUnit,
      currencySymbol: '₹',
      minRedeemCoins: minRedeemCoins,
    );
  }

  /// Newest first.
  List<TransactionModel> get transactions {
    final sorted = <TransactionModel>[..._transactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  int earnedSince(DateTime since) => _transactions
      .where(
        (tx) =>
            tx.isCredit &&
            tx.status == TransactionStatus.completed &&
            !tx.createdAt.isBefore(since),
      )
      .fold(0, (sum, tx) => sum + tx.amount);

  TransactionModel credit({
    required TransactionSource source,
    required String title,
    required int amount,
    String? description,
    TransactionStatus status = TransactionStatus.completed,
    DateTime? at,
  }) => _add(
    TransactionType.credit,
    source: source,
    title: title,
    amount: amount,
    description: description,
    status: status,
    at: at,
  );

  TransactionModel debit({
    required TransactionSource source,
    required String title,
    required int amount,
    String? description,
    String? reference,
    TransactionStatus status = TransactionStatus.completed,
    DateTime? at,
  }) => _add(
    TransactionType.debit,
    source: source,
    title: title,
    amount: amount,
    description: description,
    reference: reference,
    status: status,
    at: at,
  );

  TransactionModel _add(
    TransactionType type, {
    required TransactionSource source,
    required String title,
    required int amount,
    required TransactionStatus status,
    String? description,
    String? reference,
    DateTime? at,
  }) {
    final tx = TransactionModel(
      id: 'txn_${(++_sequence).toString().padLeft(4, '0')}',
      title: title,
      description: description,
      amount: amount,
      type: type,
      status: status,
      source: source,
      createdAt: at ?? DateTime.now(),
      reference: reference,
    );
    _transactions.add(tx);
    return tx;
  }

  void _seed(DateTime now) {
    DateTime ago({int days = 0, int hours = 0}) =>
        now.subtract(Duration(days: days, hours: hours));

    credit(
      source: TransactionSource.bonus,
      title: 'Welcome bonus',
      amount: 500,
      description: 'Thanks for joining Kavodnik!',
      at: ago(days: 30),
    );
    credit(
      source: TransactionSource.referral,
      title: 'Referral reward',
      amount: 250,
      description: 'Aman joined using your code',
      at: ago(days: 21),
    );
    credit(
      source: TransactionSource.quiz,
      title: 'Daily Quiz',
      amount: 80,
      description: '8 of 10 correct',
      at: ago(days: 12),
    );
    debit(
      source: TransactionSource.redeem,
      title: 'Redeemed to UPI',
      amount: 1000,
      description: 'ritik@upi',
      reference: 'PAYOUT-88213',
      at: ago(days: 10),
    );
    credit(
      source: TransactionSource.shopping,
      title: 'Myntra cashback',
      amount: 1200,
      description: 'Order #MY-55120',
      at: ago(days: 9),
    );
    credit(
      source: TransactionSource.spinWheel,
      title: 'Spin Wheel',
      amount: 50,
      at: ago(days: 6),
    );
    credit(
      source: TransactionSource.article,
      title: 'Read & Earn',
      amount: 20,
      description: '5 tips to save money every month',
      at: ago(days: 4),
    );
    credit(
      source: TransactionSource.scratchCard,
      title: 'Scratch Card',
      amount: 30,
      at: ago(days: 3),
    );
    credit(
      source: TransactionSource.checkIn,
      title: 'Daily Check-in',
      amount: 10,
      description: 'Day 1 streak',
      at: ago(days: 2),
    );
    credit(
      source: TransactionSource.checkIn,
      title: 'Daily Check-in',
      amount: 15,
      description: 'Day 2 streak',
      at: ago(days: 1),
    );
    credit(
      source: TransactionSource.shopping,
      title: 'Amazon cashback',
      amount: 340,
      description: 'Confirms after the return window closes',
      status: TransactionStatus.pending,
      at: ago(hours: 20),
    );
  }
}
