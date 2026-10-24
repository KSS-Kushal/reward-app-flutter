import '../entities/support_info.dart';

abstract interface class SupportRepository {
  Future<SupportInfo> getSupportInfo();
}
