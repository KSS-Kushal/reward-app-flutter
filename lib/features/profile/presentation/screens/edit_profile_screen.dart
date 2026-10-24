import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/errors/errors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';
import '../providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final _nameController = TextEditingController(
    text: ref.read(currentUserProvider)?.name,
  );
  late final _phoneController = TextEditingController(
    text: ref.read(currentUserProvider)?.phone,
  );
  late final _emailController = TextEditingController(
    text: ref.read(currentUserProvider)?.email,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final saved = await ref
        .read(editProfileControllerProvider.notifier)
        .save(name: _nameController.text, phone: _phoneController.text);
    if (saved && mounted) {
      context.showSnack('Profile updated');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final submission = ref.watch(editProfileControllerProvider);
    final error = submission.error;
    final fieldErrors = error is ValidationException
        ? error.fieldErrors
        : const <String, String>{};

    return GradientPageScaffold(
      title: 'Edit Profile',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          if (user != null)
            Center(
              child: AppAvatar(
                name: user.name,
                imageUrl: user.avatarUrl,
                size: AppSizes.avatarLg,
                borderColor: AppColors.primary,
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          AppTextField(
            controller: _nameController,
            label: 'Full name',
            prefixIcon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            errorText: fieldErrors['name'],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            enabled: false,
            controller: _emailController,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _phoneController,
            label: 'Phone (optional)',
            hint: '+91 98765 43210',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            errorText: fieldErrors['phone'],
          ),
          if (error != null && fieldErrors.isEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              userMessageFor(error),
              style: const TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Save changes',
            isLoading: submission.isLoading,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
