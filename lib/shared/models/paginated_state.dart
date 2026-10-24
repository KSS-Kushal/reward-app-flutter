import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';
import 'paginated_list.dart';

/// Accumulated pages of a lazily loaded list.
@immutable
class PaginatedState<T> {
  const PaginatedState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  bool get isEmpty => items.isEmpty;

  PaginatedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
  }) => PaginatedState(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreError: loadMoreError,
  );
}

/// Base controller for infinite lists. Subclasses only implement [fetchPage].
abstract class PaginatedController<T> extends AsyncNotifier<PaginatedState<T>> {
  Future<PaginatedList<T>> fetchPage(int page);

  @override
  Future<PaginatedState<T>> build() async {
    final first = await fetchPage(1);
    return PaginatedState(items: first.items, page: 1, hasMore: first.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await fetchPage(current.page + 1);
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          page: current.page + 1,
          hasMore: next.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Object catch (error) {
      AppLogger.warning('Loading next page failed', error: error);
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: error),
      );
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Replaces items in place (e.g. after marking a notification as read).
  void updateItems(List<T> Function(List<T> items) transform) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(items: transform(current.items)));
  }
}
