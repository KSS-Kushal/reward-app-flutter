import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/app_loader.dart';
import '../models/paginated_state.dart';

/// Lazily built list (or grid, when [gridDelegate] is set) for a
/// [PaginatedController], with pull-to-refresh, infinite scrolling and
/// loading / empty / error states.
class PaginatedListView<T> extends StatelessWidget {
  const PaginatedListView({
    required this.value,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    required this.empty,
    this.header,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.page,
      AppSpacing.lg,
      AppSpacing.page,
      AppSpacing.xxl,
    ),
    this.separator = const SizedBox(height: AppSpacing.md),
    this.gridDelegate,
    super.key,
  });

  final AsyncValue<PaginatedState<T>> value;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final AppEmptyView empty;
  final Widget? header;
  final EdgeInsets padding;
  final Widget separator;

  /// Lays items out in a grid instead of a list. [separator] is ignored;
  /// spacing comes from the delegate.
  final SliverGridDelegate? gridDelegate;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: value.when(
        loading: () => _scrollable([?header, const SkeletonList()]),
        error: (error, _) => _scrollable([
          ?header,
          AppErrorView(error: error, onRetry: onRefresh),
        ]),
        data: (state) {
          if (state.isEmpty) return _scrollable([?header, empty]);
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              if (metrics.pixels >= metrics.maxScrollExtent - 300) onLoadMore();
              return false;
            },
            child: gridDelegate != null
                ? _grid(context, state)
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: padding,
                    itemCount: state.items.length + (header == null ? 1 : 2),
                    separatorBuilder: (_, _) => separator,
                    itemBuilder: (context, index) {
                      if (header != null) {
                        if (index == 0) return header!;
                        index -= 1;
                      }
                      if (index < state.items.length) {
                        return itemBuilder(context, state.items[index]);
                      }
                      return _Footer(state: state, onRetry: onLoadMore);
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _grid(BuildContext context, PaginatedState<T> state) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverMainAxisGroup(
            slivers: [
              if (header != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: header,
                  ),
                ),
              SliverGrid.builder(
                gridDelegate: gridDelegate!,
                itemCount: state.items.length,
                itemBuilder: (context, index) =>
                    itemBuilder(context, state.items[index]),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: _Footer(state: state, onRetry: onLoadMore),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scrollable(List<Widget> children) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: padding,
    children: children,
  );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onRetry});

  final PaginatedState<Object?> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const AppLoader(padding: EdgeInsets.all(AppSpacing.md));
    }
    if (state.loadMoreError != null) {
      return AppErrorView(
        error: state.loadMoreError!,
        onRetry: onRetry,
        compact: true,
      );
    }
    return const SizedBox.shrink();
  }
}
