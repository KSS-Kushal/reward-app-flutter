import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../shared/components/paginated_list_view.dart';
import '../providers/shopping_providers.dart';
import '../widgets/merchant_widgets.dart';

class ShopAndEarnScreen extends ConsumerStatefulWidget {
  const ShopAndEarnScreen({super.key});

  @override
  ConsumerState<ShopAndEarnScreen> createState() => _ShopAndEarnScreenState();
}

class _ShopAndEarnScreenState extends ConsumerState<ShopAndEarnScreen> {
  final _debouncer = Debouncer();
  String? _categoryId;
  String _search = '';

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = (categoryId: _categoryId, search: _search);
    final merchants = ref.watch(merchantsProvider(query));
    final controller = ref.read(merchantsProvider(query).notifier);
    final categories = ref.watch(merchantCategoriesProvider).value ?? const [];

    return GradientPageScaffold(
      title: 'Shop & Earn',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              0,
            ),
            child: AppTextField(
              hint: 'Search platforms',
              prefixIcon: Icons.search_rounded,
              textInputAction: TextInputAction.search,
              onChanged: (value) =>
                  _debouncer.run(() => setState(() => _search = value.trim())),
            ),
          ),
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
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _categoryId == null,
                    onSelected: (_) => setState(() => _categoryId = null),
                  ),
                ),
                for (final category in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _categoryId == category.id,
                      onSelected: (_) =>
                          setState(() => _categoryId = category.id),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PaginatedListView(
              value: merchants,
              onRefresh: controller.refresh,
              onLoadMore: controller.loadMore,
              empty: const AppEmptyView(
                title: 'No shops found',
                message: 'Try a different search or category.',
                icon: Icons.storefront_outlined,
              ),
              itemBuilder: (context, merchant) => MerchantCard(
                merchant: merchant,
                onTap: () =>
                    context.push(AppRoutes.merchantProducts(merchant.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
