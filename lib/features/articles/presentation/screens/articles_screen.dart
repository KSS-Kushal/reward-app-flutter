import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/ads/ad_models.dart';
import '../../../../core/ads/widgets/banner_ad_slot.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../shared/components/paginated_list_view.dart';
import '../providers/article_providers.dart';
import '../widgets/article_card.dart';

/// "Read Article": every article, filterable by category.
class ArticlesScreen extends ConsumerStatefulWidget {
  const ArticlesScreen({super.key});

  @override
  ConsumerState<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends ConsumerState<ArticlesScreen> {
  String? _categoryId;

  @override
  Widget build(BuildContext context) {
    final query = (categoryId: _categoryId, rewardableOnly: false);
    final articles = ref.watch(articlesProvider(query));
    final controller = ref.read(articlesProvider(query).notifier);
    final categories = ref.watch(articleCategoriesProvider).value ?? const [];

    return GradientPageScaffold(
      title: 'Articles',
      bottomBar: const BannerAdSlot(placement: AdPlacement.article),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                0,
              ),
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: _categoryId == null,
                  onTap: () => setState(() => _categoryId = null),
                ),
                for (final category in categories)
                  _CategoryChip(
                    label: category.name,
                    selected: _categoryId == category.id,
                    onTap: () => setState(() => _categoryId = category.id),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PaginatedListView(
              value: articles,
              onRefresh: controller.refresh,
              onLoadMore: controller.loadMore,
              empty: const AppEmptyView(
                title: 'No articles',
                message: 'Check back soon for new reads.',
                icon: Icons.article_outlined,
              ),
              itemBuilder: (context, article) => ArticleCard(
                article: article,
                onTap: () => context.push(AppRoutes.articleDetail(article.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
