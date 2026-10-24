import '../../../../core/mock/mock_latency.dart';
import '../models/support_info_model.dart';
import 'support_remote_data_source.dart';

class SupportMockDataSource implements SupportRemoteDataSource {
  const SupportMockDataSource();

  @override
  Future<SupportInfoModel> getSupportInfo() async {
    await MockLatency.simulate();
    return const SupportInfoModel(
      email: 'support@kavodnik.app',
      phone: '+91 80 4000 1234',
      chatUrl: 'https://wa.me/918040001234',
      workingHours: 'Mon – Sat, 10:00 AM – 7:00 PM IST',
      faqs: [
        FaqModel(
          question: 'How do I earn coins?',
          answer:
              'Complete daily rewards (check-in, spin wheel, scratch cards, '
              'captcha), play quizzes, read articles, shop through partner '
              'stores and invite friends.',
        ),
        FaqModel(
          question: 'When can I redeem my coins?',
          answer:
              'Once you reach the minimum balance shown in your wallet '
              '(usually 1,000 coins) you can redeem to UPI, Paytm or gift '
              'cards.',
        ),
        FaqModel(
          question: 'Why is my cashback pending?',
          answer:
              'Shopping cashback is confirmed after the store\'s return '
              'window closes, which can take up to 60 days.',
        ),
        FaqModel(
          question: 'My redemption has not arrived yet',
          answer:
              'Most payouts are processed within 24–48 hours. If it has '
              'been longer, contact us with your transaction ID.',
        ),
        FaqModel(
          question: 'Can I use multiple accounts?',
          answer:
              'No. Each person may use one account. Duplicate accounts are '
              'suspended and their rewards forfeited.',
        ),
      ],
    );
  }
}
