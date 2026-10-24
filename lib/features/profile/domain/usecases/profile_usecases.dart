import '../../../../core/errors/errors.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/profile_stats.dart';
import '../repositories/profile_repository.dart';

class GetProfileStats {
  const GetProfileStats(this._repository);
  final ProfileRepository _repository;

  Future<ProfileStats> call() => _repository.getStats();
}

class UpdateProfile {
  const UpdateProfile(this._repository);
  final ProfileRepository _repository;

  static final _phonePattern = RegExp(r'^\+?[0-9 ]{7,16}$');

  Future<User> call({required String name, String? phone}) {
    final trimmedName = name.trim();
    final trimmedPhone = phone?.trim();
    final errors = <String, String>{
      if (trimmedName.length < 2) 'name': 'Please enter your full name.',
      if (trimmedPhone != null &&
          trimmedPhone.isNotEmpty &&
          !_phonePattern.hasMatch(trimmedPhone))
        'phone': 'Please enter a valid phone number.',
    };
    if (errors.isNotEmpty) {
      throw ValidationException(
        message: errors.values.first,
        fieldErrors: errors,
      );
    }
    return _repository.updateProfile(
      name: trimmedName,
      phone: trimmedPhone == null || trimmedPhone.isEmpty ? null : trimmedPhone,
    );
  }
}
