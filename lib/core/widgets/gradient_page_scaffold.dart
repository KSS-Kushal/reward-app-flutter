import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

/// Page layout shared by every screen: the dark green gradient header from
/// the home screen with a rounded light "sheet" holding the content.
class GradientPageScaffold extends StatelessWidget {
  const GradientPageScaffold({
    required this.title,
    required this.body,
    this.actions = const [],
    this.showBack = true,
    this.headerBottom,
    this.floatingActionButton,
    this.bottomBar,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final bool showBack;

  /// Optional content rendered inside the header (e.g. a balance card).
  final Widget? headerBottom;
  final Widget? floatingActionButton;

  /// Pinned below [body], e.g. a banner ad. It owns the bottom safe area.
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        floatingActionButton: floatingActionButton,
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            if (canPop)
                              const BackButton(color: AppColors.textOnDark)
                            else
                              const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.textOnDark,
                                  ),
                                ),
                              ),
                            ),
                            ...actions,
                          ],
                        ),
                      ),
                      if (headerBottom != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.sm,
                            AppSpacing.md,
                            AppSpacing.sm,
                            0,
                          ),
                          child: headerBottom,
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.sheetTop,
                  child: ColoredBox(
                    color: AppColors.background,
                    child: bottomBar == null
                        ? SizedBox.expand(child: body)
                        : Column(
                            children: [
                              Expanded(child: body),
                              bottomBar!,
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
