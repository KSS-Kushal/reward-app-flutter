import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../providers/profile_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return GradientPageScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push notifications'),
                  subtitle: const Text('Rewards, reminders and offers'),
                  value: settings.pushNotificationsEnabled,
                  onChanged: (value) =>
                      controller.setPushNotifications(enabled: value),
                ),
                SwitchListTile(
                  title: const Text('Sound effects'),
                  subtitle: const Text('Play sounds in games'),
                  value: settings.soundEffectsEnabled,
                  onChanged: (value) =>
                      controller.setSoundEffects(enabled: value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              '${AppConfig.appName} · ${AppConfig.environment.name}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
