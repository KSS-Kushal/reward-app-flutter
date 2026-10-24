import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_empty_view.dart';
import 'app_error_view.dart';
import 'app_loader.dart';

/// Renders the loading / error / empty / success states of an [AsyncValue]
/// consistently across the app.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
    this.isEmpty,
    this.empty,
    this.compactError = false,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final Widget? loading;

  /// Returns `true` when [data] has nothing to show; [empty] is rendered then.
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final bool compactError;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (result) {
        if (isEmpty?.call(result) ?? false) {
          return empty ?? const AppEmptyView(title: 'Nothing here yet');
        }
        return data(result);
      },
      loading: () => loading ?? const AppLoader(),
      error: (error, _) =>
          AppErrorView(error: error, onRetry: onRetry, compact: compactError),
    );
  }
}
