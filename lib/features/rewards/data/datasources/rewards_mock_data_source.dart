import 'dart:math';

import '../../../../core/errors/errors.dart';
import '../../../../core/mock/mock_latency.dart';
import '../../../wallet/data/datasources/mock_wallet_ledger.dart';
import '../../../wallet/domain/entities/transaction.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/entities/reward_task.dart';
import '../models/reward_game_models.dart';
import '../models/reward_task_model.dart';
import 'rewards_remote_data_source.dart';

/// Simulates the backend reward engine: daily limits, streaks and random
/// prizes all live here (server side), never in the UI.
class RewardsMockDataSource implements RewardsRemoteDataSource {
  RewardsMockDataSource(
    this._ledger, {
    Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? Random(),
       _clock = clock ?? DateTime.now {
    _day = _today;
  }

  final MockWalletLedger _ledger;
  final Random _random;
  final DateTime Function() _clock;

  static const checkInRewards = [10, 15, 20, 25, 30, 40, 100];
  static const maxSpinsPerDay = 3;
  static const scratchCardsPerDay = 3;
  static const captchaAttemptsPerDay = 5;
  static const captchaReward = 5;

  static const _segments = [
    SpinSegmentModel(id: 's1', label: '5', coins: 5, colorHex: '#6A4BE0'),
    SpinSegmentModel(id: 's2', label: '20', coins: 20, colorHex: '#F7931A'),
    SpinSegmentModel(id: 's3', label: '10', coins: 10, colorHex: '#12A35C'),
    SpinSegmentModel(id: 's4', label: '50', coins: 50, colorHex: '#1F7AF0'),
    SpinSegmentModel(id: 's5', label: 'Oops', coins: 0, colorHex: '#E5484D'),
    SpinSegmentModel(id: 's6', label: '15', coins: 15, colorHex: '#D946EF'),
    SpinSegmentModel(id: 's7', label: '100', coins: 100, colorHex: '#F5B400'),
    SpinSegmentModel(id: 's8', label: '25', coins: 25, colorHex: '#0EA5A4'),
  ];

  /// Relative odds per segment (server-side prize table).
  static const _segmentWeights = [25, 15, 22, 6, 12, 14, 1, 5];

  late DateTime _day;

  // Streak: 2 consecutive check-ins before today.
  int _streak = 2;
  bool _claimedToday = false;
  int _spinsUsed = 0;
  int _scratchUsed = 0;
  int _captchaUsed = 0;
  int _captchaSequence = 0;
  String? _captchaId;
  String? _captchaCode;

  DateTime get _today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  void _rollOverDay() {
    final today = _today;
    if (today == _day) return;
    if (!_claimedToday) _streak = 0;
    _day = today;
    _claimedToday = false;
    _spinsUsed = 0;
    _scratchUsed = 0;
    _captchaUsed = 0;
  }

  int get _todayCheckInReward =>
      checkInRewards[_streak % checkInRewards.length];

  Future<void> _request() async {
    await MockLatency.simulate();
    _rollOverDay();
  }

  // -------------------------------------------------------------------------
  // Overview
  // -------------------------------------------------------------------------

  List<RewardTaskModel> _tasks() {
    RewardTaskStatus statusFor(int remaining) =>
        remaining > 0 ? RewardTaskStatus.available : RewardTaskStatus.completed;

    return [
      RewardTaskModel(
        id: 'task_check_in',
        type: RewardTaskType.dailyCheckIn,
        title: 'Daily Check-in',
        subtitle: _claimedToday
            ? 'Come back tomorrow'
            : 'Day ${_streak + 1} of your streak',
        actionLabel: 'Check-in',
        rewardCoins: _checkInStatus().todayReward,
        status: _claimedToday
            ? RewardTaskStatus.completed
            : RewardTaskStatus.available,
        remainingAttempts: _claimedToday ? 0 : 1,
        totalAttempts: 1,
      ),
      RewardTaskModel(
        id: 'task_spin',
        type: RewardTaskType.spinWheel,
        title: 'Spin Wheel',
        subtitle: 'Win up to 100 coins',
        actionLabel: 'Spin',
        rewardCoins: 100,
        status: statusFor(maxSpinsPerDay - _spinsUsed),
        remainingAttempts: maxSpinsPerDay - _spinsUsed,
        totalAttempts: maxSpinsPerDay,
      ),
      RewardTaskModel(
        id: 'task_scratch',
        type: RewardTaskType.scratchCard,
        title: 'Scratch Card',
        subtitle: 'Scratch to reveal coins',
        actionLabel: 'Play',
        rewardCoins: 50,
        status: statusFor(scratchCardsPerDay - _scratchUsed),
        remainingAttempts: scratchCardsPerDay - _scratchUsed,
        totalAttempts: scratchCardsPerDay,
      ),
      RewardTaskModel(
        id: 'task_captcha',
        type: RewardTaskType.captcha,
        title: 'Captcha Task',
        subtitle: 'Solve and earn $captchaReward coins each',
        actionLabel: 'Start',
        rewardCoins: captchaReward,
        status: statusFor(captchaAttemptsPerDay - _captchaUsed),
        remainingAttempts: captchaAttemptsPerDay - _captchaUsed,
        totalAttempts: captchaAttemptsPerDay,
      ),
    ];
  }

  @override
  Future<List<RewardTaskModel>> getDailyRewards() async {
    await _request();
    return _tasks();
  }

  @override
  Future<RewardSummaryModel> getSummary() async {
    await _request();
    final tasks = _tasks();
    return RewardSummaryModel(
      earnedToday: _ledger.earnedSince(_day),
      totalEarned: _ledger.wallet.totalEarned,
      currentStreak: _streak,
      tasksCompletedToday: tasks.where((t) => t.isCompleted).length,
      totalTasksToday: tasks.length,
    );
  }

  static const _rewardSources = {
    TransactionSource.checkIn,
    TransactionSource.spinWheel,
    TransactionSource.scratchCard,
    TransactionSource.captcha,
    TransactionSource.quiz,
    TransactionSource.article,
    TransactionSource.referral,
    TransactionSource.bonus,
  };

  @override
  Future<List<RewardActivityModel>> getHistory() async {
    await _request();
    return _ledger.transactions
        .where(
          (tx) =>
              tx.isCredit &&
              tx.status == TransactionStatus.completed &&
              _rewardSources.contains(tx.source),
        )
        .take(30)
        .map(
          (tx) => RewardActivityModel(
            id: tx.id,
            title: tx.title,
            description: tx.description,
            coins: tx.amount,
            earnedAt: tx.createdAt,
          ),
        )
        .toList(growable: false);
  }

  // -------------------------------------------------------------------------
  // Daily check-in
  // -------------------------------------------------------------------------

  @override
  Future<CheckInStatusModel> getCheckInStatus() async {
    await _request();
    return _checkInStatus();
  }

  CheckInStatusModel _checkInStatus() {
    final cycle = checkInRewards.length;
    // Position of today within the 7-day cycle.
    final claimedInCycle = _streak % cycle;
    final todayIndex = _claimedToday
        ? (claimedInCycle == 0 ? cycle - 1 : claimedInCycle - 1)
        : claimedInCycle;

    final days = [
      for (var i = 0; i < cycle; i++)
        CheckInDayModel(
          day: i + 1,
          coins: checkInRewards[i],
          state: i < todayIndex || (i == todayIndex && _claimedToday)
              ? CheckInDayState.claimed
              : i == todayIndex
              ? CheckInDayState.today
              : CheckInDayState.upcoming,
        ),
    ];

    return CheckInStatusModel(
      currentStreak: _streak,
      claimedToday: _claimedToday,
      todayReward: checkInRewards[todayIndex],
      days: days,
      nextCheckInAt: _claimedToday ? _day.add(const Duration(days: 1)) : null,
    );
  }

  @override
  Future<CheckInResultModel> claimCheckIn() async {
    await _request();
    if (_claimedToday) {
      throw const ValidationException(
        message: "You've already checked in today. Come back tomorrow!",
        code: 'already_claimed',
      );
    }
    final coins = _todayCheckInReward;
    _streak += 1;
    _claimedToday = true;
    _ledger.credit(
      source: TransactionSource.checkIn,
      title: 'Daily Check-in',
      amount: coins,
      description: 'Day $_streak streak',
    );
    return CheckInResultModel(coinsEarned: coins, newStreak: _streak);
  }

  // -------------------------------------------------------------------------
  // Spin wheel
  // -------------------------------------------------------------------------

  @override
  Future<SpinWheelConfigModel> getSpinWheel() async {
    await _request();
    return SpinWheelConfigModel(
      segments: _segments,
      remainingSpins: maxSpinsPerDay - _spinsUsed,
      maxSpinsPerDay: maxSpinsPerDay,
    );
  }

  @override
  Future<SpinResultModel> spin() async {
    await _request();
    if (_spinsUsed >= maxSpinsPerDay) {
      throw const ValidationException(
        message: 'No spins left today. Come back tomorrow!',
        code: 'no_spins_left',
      );
    }
    final segment = _segments[_weightedIndex(_segmentWeights)];
    _spinsUsed += 1;
    if (segment.coins > 0) {
      _ledger.credit(
        source: TransactionSource.spinWheel,
        title: 'Spin Wheel',
        amount: segment.coins,
      );
    }
    return SpinResultModel(
      segmentId: segment.id,
      coinsWon: segment.coins,
      remainingSpins: maxSpinsPerDay - _spinsUsed,
    );
  }

  int _weightedIndex(List<int> weights) {
    final total = weights.fold(0, (sum, w) => sum + w);
    var roll = _random.nextInt(total);
    for (var i = 0; i < weights.length; i++) {
      if (roll < weights[i]) return i;
      roll -= weights[i];
    }
    return weights.length - 1;
  }

  // -------------------------------------------------------------------------
  // Scratch card
  // -------------------------------------------------------------------------

  String? get _currentCardId => _scratchUsed < scratchCardsPerDay
      ? 'card_${_day.millisecondsSinceEpoch}_$_scratchUsed'
      : null;

  @override
  Future<ScratchCardStatusModel> getScratchCard() async {
    await _request();
    return ScratchCardStatusModel(
      cardId: _currentCardId,
      remainingCards: scratchCardsPerDay - _scratchUsed,
      totalCards: scratchCardsPerDay,
    );
  }

  @override
  Future<ScratchResultModel> revealScratchCard(String cardId) async {
    await _request();
    if (cardId != _currentCardId) {
      throw const ValidationException(
        message: 'This card has expired. Please try another one.',
        code: 'invalid_card',
      );
    }
    final coins = const [5, 10, 10, 15, 20, 25, 30, 50][_random.nextInt(8)];
    _scratchUsed += 1;
    _ledger.credit(
      source: TransactionSource.scratchCard,
      title: 'Scratch Card',
      amount: coins,
    );
    return ScratchResultModel(
      cardId: cardId,
      coinsWon: coins,
      remainingCards: scratchCardsPerDay - _scratchUsed,
      message: coins >= 30 ? 'Jackpot! Lucky you!' : 'Nice! Coins added.',
    );
  }

  // -------------------------------------------------------------------------
  // Captcha
  // -------------------------------------------------------------------------

  static const _captchaAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  Future<CaptchaChallengeModel> getCaptcha() async {
    await _request();
    _captchaId = 'captcha_${++_captchaSequence}';
    _captchaCode = List.generate(
      6,
      (_) => _captchaAlphabet[_random.nextInt(_captchaAlphabet.length)],
    ).join();
    return CaptchaChallengeModel(
      id: _captchaId!,
      previewText: _captchaCode,
      rewardCoins: captchaReward,
      remainingAttempts: captchaAttemptsPerDay - _captchaUsed,
      totalAttempts: captchaAttemptsPerDay,
    );
  }

  @override
  Future<CaptchaResultModel> submitCaptcha({
    required String challengeId,
    required String answer,
  }) async {
    await _request();
    if (_captchaUsed >= captchaAttemptsPerDay) {
      throw const ValidationException(
        message: 'No captcha attempts left today.',
        code: 'no_attempts_left',
      );
    }
    if (challengeId != _captchaId) {
      throw const ValidationException(
        message: 'This captcha has expired. Please load a new one.',
        code: 'captcha_expired',
      );
    }
    _captchaUsed += 1;
    _captchaId = null;
    final isCorrect = answer.trim().toUpperCase() == _captchaCode;
    if (isCorrect) {
      _ledger.credit(
        source: TransactionSource.captcha,
        title: 'Captcha Task',
        amount: captchaReward,
      );
    }
    return CaptchaResultModel(
      isCorrect: isCorrect,
      coinsEarned: isCorrect ? captchaReward : 0,
      remainingAttempts: captchaAttemptsPerDay - _captchaUsed,
      message: isCorrect
          ? 'Correct! +$captchaReward coins'
          : "That wasn't right. Try the next one.",
    );
  }
}
