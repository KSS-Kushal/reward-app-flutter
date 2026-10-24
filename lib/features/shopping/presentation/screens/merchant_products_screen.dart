import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../shared/components/paginated_list_view.dart';
import '../../domain/entities/merchant.dart';
import '../../domain/entities/product.dart';
import '../providers/shopping_providers.dart';
import '../widgets/merchant_widgets.dart';
import '../widgets/product_card.dart';
import '../widgets/store_info_sheet.dart';

/// Products of one platform. "Buy now" opens the product's affiliate link.
class MerchantProductsScreen extends ConsumerStatefulWidget {
  const MerchantProductsScreen({required this.merchantId, super.key});

  final String merchantId;

  @override
  ConsumerState<MerchantProductsScreen> createState() =>
      _MerchantProductsScreenState();
}

class _MerchantProductsScreenState
    extends ConsumerState<MerchantProductsScreen> {
  final _debouncer = Debouncer();
  String _search = '';

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _buyNow(Product product) async {
    final opened = await ref
        .read(externalLinkServiceProvider)
        .openUrl(product.affiliateUrl);
    if (!opened && mounted) {
      context.showSnack(
        'Could not open the store. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final merchant = ref.watch(merchantDetailProvider(widget.merchantId)).value;
    final query = (merchantId: widget.merchantId, search: _search);
    final products = ref.watch(merchantProductsProvider(query));
    final controller = ref.read(merchantProductsProvider(query).notifier);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return GradientPageScaffold(
      title: merchant?.name ?? 'Products',
      actions: [
        if (merchant != null)
          IconButton(
            tooltip: 'Offers & terms',
            color: AppColors.textOnDark,
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => StoreInfoSheet.show(context, merchant),
          ),
      ],
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
              hint: merchant == null
                  ? 'Search products'
                  : 'Search on ${merchant.name}',
              prefixIcon: Icons.search_rounded,
              textInputAction: TextInputAction.search,
              onChanged: (value) =>
                  _debouncer.run(() => setState(() => _search = value.trim())),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const columns = 2;
                const spacing = AppSpacing.md;
                final tileWidth =
                    (constraints.maxWidth -
                        AppSpacing.page * 2 -
                        spacing * (columns - 1)) /
                    columns;
                return PaginatedListView(
                  value: products,
                  onRefresh: controller.refresh,
                  onLoadMore: controller.loadMore,
                  header: merchant == null
                      ? null
                      : _RewardBanner(merchant: merchant),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    mainAxisExtent:
                        tileWidth + ProductCard.detailsHeight * textScale,
                  ),
                  empty: AppEmptyView(
                    title: _search.isEmpty
                        ? 'No products yet'
                        : 'No products match "$_search"',
                    message: 'Try another search or check back later.',
                    icon: Icons.shopping_bag_outlined,
                  ),
                  itemBuilder: (context, product) => ProductCard(
                    product: product,
                    onBuyNow: () => _buyNow(product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact platform banner above the grid.
class _RewardBanner extends StatelessWidget {
  const _RewardBanner({required this.merchant});

  final Merchant merchant;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primaryLight,
      shadow: null,
      onTap: () => StoreInfoSheet.show(context, merchant),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          MerchantLogo(merchant: merchant, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.rewardText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Buy through these links to earn rewards',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
