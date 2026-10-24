import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../errors/errors.dart';

extension ContextExtensions on BuildContext {
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.textPrimary,
        ),
      );
  }

  /// Shows a user-safe message for any thrown error.
  void showErrorSnack(Object error) =>
      showSnack(userMessageFor(error), isError: true);
}
