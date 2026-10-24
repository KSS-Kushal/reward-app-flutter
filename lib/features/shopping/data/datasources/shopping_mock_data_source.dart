import '../../../../core/errors/errors.dart';
import '../../../../core/mock/mock_latency.dart';
import '../../../../shared/models/paginated_list.dart';
import '../models/merchant_model.dart';
import '../models/product_model.dart';
import 'shopping_remote_data_source.dart';

/// Mock affiliate catalogue.
///
/// "Buy now" links open each platform's real search page for the product, so
/// the flow can be tried end to end. The real backend returns proper
/// affiliate links (with a user sub-id) instead.
class ShoppingMockDataSource implements ShoppingRemoteDataSource {
  const ShoppingMockDataSource();

  static const _marketplace = MerchantCategoryModel(
    id: 'marketplace',
    name: 'Marketplace',
  );
  static const _fashion = MerchantCategoryModel(id: 'fashion', name: 'Fashion');
  static const _beauty = MerchantCategoryModel(id: 'beauty', name: 'Beauty');
  static const _electronics = MerchantCategoryModel(
    id: 'electronics',
    name: 'Electronics',
  );
  static const _grocery = MerchantCategoryModel(id: 'grocery', name: 'Grocery');
  static const _categories = [
    _marketplace,
    _fashion,
    _beauty,
    _electronics,
    _grocery,
  ];

  static const _terms = [
    'Rewards are tracked only when you open the product from Kavodnik.',
    'Complete your purchase in the same session.',
    'Rewards are confirmed after the return window closes.',
    'Using coupons not listed here may void rewards.',
  ];

  static final _merchants = [
    _merchant(
      'm_amazon',
      'Amazon',
      _marketplace,
      5,
      '#FF9900',
      'https://www.amazon.in/s?k=',
      featured: true,
    ),
    _merchant(
      'm_flipkart',
      'Flipkart',
      _marketplace,
      6,
      '#2874F0',
      'https://www.flipkart.com/search?q=',
      featured: true,
    ),
    _merchant(
      'm_meesho',
      'Meesho',
      _marketplace,
      8,
      '#9F2089',
      'https://www.meesho.com/search?q=',
      featured: true,
    ),
    _merchant(
      'm_myntra',
      'Myntra',
      _fashion,
      8,
      '#FF3F6C',
      'https://www.myntra.com/',
    ),
    _merchant(
      'm_ajio',
      'AJIO',
      _fashion,
      7,
      '#2C4152',
      'https://www.ajio.com/search/?text=',
    ),
    _merchant(
      'm_nykaa',
      'Nykaa',
      _beauty,
      6,
      '#FC2779',
      'https://www.nykaa.com/search/result/?q=',
    ),
    _merchant(
      'm_croma',
      'Croma',
      _electronics,
      3,
      '#12DAA8',
      'https://www.croma.com/searchB?q=',
    ),
    _merchant(
      'm_jiomart',
      'JioMart',
      _grocery,
      4,
      '#0078AD',
      'https://www.jiomart.com/search/',
    ),
  ];

  static MerchantModel _merchant(
    String id,
    String name,
    MerchantCategoryModel category,
    double cashback,
    String color,
    String searchUrl, {
    bool featured = false,
  }) {
    return MerchantModel(
      id: id,
      name: name,
      category: category,
      rewardText: 'Up to ${cashback.toStringAsFixed(0)}% back as coins',
      cashbackPercent: cashback,
      description:
          'Buy on $name through Kavodnik and earn up to '
          '${cashback.toStringAsFixed(0)}% back as coins on eligible orders.',
      // Mock only: the platform's search URL. Product links append the name.
      trackingUrl: searchUrl,
      brandColorHex: color,
      isFeatured: featured,
      terms: _terms,
      offers: [
        OfferModel(
          id: '${id}_o1',
          title: 'Extra 10% off for new users',
          description: 'Valid on your first order above ₹999.',
          couponCode: '${name.toUpperCase().replaceAll(' ', '')}10',
          expiresAt: DateTime.now().add(const Duration(days: 14)),
        ),
      ],
    );
  }

  /// (name, price, original price, rating) per category.
  static const Map<String, List<(String, double, double?, double)>> _catalogue =
      {
        'marketplace': [
          ('boAt Rockerz 450 Bluetooth Headphones', 1299, 3990, 4.2),
          ('Redmi 13C 5G (4GB RAM, 128GB)', 9999, 13999, 4.1),
          ('Prestige Iris 750W Mixer Grinder', 2899, 4695, 4.3),
          ('Fire-Boltt Ninja Smart Watch', 1099, 6999, 3.9),
          ('Milton Thermosteel Flask 1L', 849, 1265, 4.4),
          ('Cotton Bedsheet Double with 2 Pillow Covers', 499, 1499, 4.0),
          ('Wildcraft 35L Casual Backpack', 1149, 2299, 4.2),
          ('Philips Trimmer BT1232', 1199, 1595, 4.3),
          ('Pigeon Non-Stick Cookware Set (3 pcs)', 999, 2195, 4.1),
          ('Mi Power Bank 20000mAh', 1899, 2499, 4.4),
          ('Lenovo Wireless Mouse', 449, 899, 4.2),
          ('Kurta Set for Women (Rayon)', 399, 1299, 3.9),
        ],
        'fashion': [
          ("Men's Slim Fit Casual Shirt", 699, 1999, 4.1),
          ("Women's Printed Anarkali Kurta", 899, 2499, 4.2),
          ('Running Shoes for Men', 1299, 3499, 4.0),
          ('Denim Jacket Unisex', 1499, 3999, 4.3),
          ("Women's Handbag", 799, 2299, 4.0),
          ('Classic Analog Watch', 1199, 2999, 4.2),
          ('Cotton Polo T-Shirt (Pack of 2)', 649, 1598, 4.1),
          ('Ethnic Jutti for Women', 549, 1299, 3.9),
        ],
        'beauty': [
          ('Vitamin C Face Serum 30ml', 449, 599, 4.3),
          ('Matte Liquid Lipstick', 349, 499, 4.2),
          ('Sunscreen SPF 50 PA+++ 50g', 399, 499, 4.4),
          ('Hair Dryer 1200W', 899, 1499, 4.1),
          ('Kajal Eyeliner (Pack of 2)', 249, 350, 4.3),
          ('Body Lotion 400ml', 299, 425, 4.2),
        ],
        'electronics': [
          ('55" 4K Ultra HD Smart LED TV', 32990, 54990, 4.3),
          ('Wireless Earbuds with ANC', 2499, 5999, 4.1),
          ('1.5 Ton 3 Star Inverter Split AC', 33490, 52990, 4.2),
          ('Laptop 15.6" Core i5, 16GB, 512GB SSD', 52990, 72990, 4.3),
          ('Bluetooth Party Speaker 40W', 3499, 7999, 4.0),
          ('Fully Automatic Front Load Washer 7kg', 28990, 41990, 4.4),
        ],
        'grocery': [
          ('Basmati Rice 5kg', 549, 799, 4.3),
          ('Sunflower Oil 1L', 139, 185, 4.2),
          ('Assorted Dry Fruits 500g', 499, 899, 4.1),
          ('Green Tea (100 bags)', 349, 525, 4.4),
          ('Detergent Powder 4kg', 459, 620, 4.2),
          ('Atta Whole Wheat 10kg', 429, 550, 4.3),
        ],
      };

  @override
  Future<List<MerchantCategoryModel>> getCategories() async {
    await MockLatency.simulate();
    return _categories;
  }

  @override
  Future<PaginatedList<MerchantModel>> getMerchants({
    required int page,
    required int pageSize,
    String? categoryId,
    String? search,
  }) async {
    await MockLatency.simulate();
    final needle = search?.toLowerCase();
    final filtered = _merchants
        .where((m) => categoryId == null || m.category.id == categoryId)
        .where((m) => needle == null || m.name.toLowerCase().contains(needle))
        .toList();
    return _page(filtered, page, pageSize);
  }

  @override
  Future<MerchantModel> getMerchant(String id) async {
    await MockLatency.simulate();
    return _find(id);
  }

  @override
  Future<PaginatedList<ProductModel>> getProducts({
    required String merchantId,
    required int page,
    required int pageSize,
    String? search,
  }) async {
    await MockLatency.simulate();
    final merchant = _find(merchantId);
    final needle = search?.toLowerCase();
    final products = _productsFor(merchant)
        .where((p) => needle == null || p.name.toLowerCase().contains(needle))
        .toList();
    return _page(products, page, pageSize);
  }

  MerchantModel _find(String id) => _merchants.firstWhere(
    (m) => m.id == id,
    orElse: () => throw const ServerException(
      message: 'This store is no longer available.',
      statusCode: 404,
    ),
  );

  List<ProductModel> _productsFor(MerchantModel merchant) {
    final items = _catalogue[merchant.category.id] ?? const [];
    final searchUrl = merchant.trackingUrl;
    return [
      for (var i = 0; i < items.length; i++)
        ProductModel(
          id: '${merchant.id}_p$i',
          merchantId: merchant.id,
          name: items[i].$1,
          imageUrl: 'https://picsum.photos/seed/${merchant.id}_p$i/400/400',
          price: items[i].$2,
          originalPrice: items[i].$3,
          rating: items[i].$4,
          affiliateUrl: '$searchUrl${Uri.encodeQueryComponent(items[i].$1)}',
          rewardText:
              'Up to ₹${(items[i].$2 * merchant.cashbackPercent / 100).round()} '
              'back',
        ),
    ];
  }

  static PaginatedList<T> _page<T>(List<T> all, int page, int pageSize) {
    final start = (page - 1) * pageSize;
    return PaginatedList(
      items: all.skip(start).take(pageSize).toList(growable: false),
      page: page,
      pageSize: pageSize,
      totalCount: all.length,
      hasMore: start + pageSize < all.length,
    );
  }
}
