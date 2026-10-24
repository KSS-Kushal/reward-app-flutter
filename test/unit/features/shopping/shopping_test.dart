import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/errors/errors.dart';
import 'package:kavodnik/core/utils/formatters.dart';
import 'package:kavodnik/features/shopping/data/datasources/shopping_mock_data_source.dart';
import 'package:kavodnik/features/shopping/data/models/product_model.dart';
import 'package:kavodnik/features/shopping/data/repositories/shopping_repository_impl.dart';
import 'package:kavodnik/features/shopping/domain/usecases/shopping_usecases.dart';
import 'package:kavodnik/shared/models/paginated_list.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(disableMockLatency);

  const repository = ShoppingRepositoryImpl(ShoppingMockDataSource());

  group('ProductModel', () {
    test('parses a product from the API', () {
      final product = ProductModel.fromJson({
        'id': 'p1',
        'merchantId': 'm_amazon',
        'name': 'Wireless Earbuds',
        'imageUrl': 'https://cdn.example.com/p1.jpg',
        'price': '1299',
        'originalPrice': 3990,
        'affiliateUrl': 'https://amzn.to/abc123',
        'rating': 4.2,
      });
      expect(product.price, 1299);
      expect(product.currencySymbol, '₹');
      expect(product.hasDiscount, isTrue);
      expect(product.discountPercent, 67);
      expect(
        ProductModel.fromJson(product.toJson()).affiliateUrl,
        'https://amzn.to/abc123',
      );
    });

    test('no original price means no discount', () {
      final product = ProductModel.fromJson({
        'id': 'p2',
        'name': 'Rice',
        'price': 549,
        'affiliateUrl': 'https://x',
      });
      expect(product.originalPrice, isNull);
      expect(product.hasDiscount, isFalse);
      expect(product.discountPercent, 0);
    });

    test('products page uses the backend pagination object', () {
      final page = PaginatedList.fromJson({
        'items': [
          {'id': 'p1', 'name': 'A', 'price': 10, 'affiliateUrl': 'https://a'},
        ],
        'currentPage': 1,
        'limit': 20,
        'totalItems': 1,
        'totalPages': 1,
        'isLast': true,
        'hasNext': false,
      }, ProductModel.fromJson);
      expect(page.items.single.name, 'A');
      expect(page.hasMore, isFalse);
    });
  });

  group('mock catalogue', () {
    test(
      'lists shopping platforms including Amazon, Flipkart and Meesho',
      () async {
        final page = await repository.getMerchants();
        final names = page.items.map((m) => m.name);
        expect(names, containsAll(['Amazon', 'Flipkart', 'Meesho']));
      },
    );

    test('each platform has products with affiliate links', () async {
      final products = await repository.getProducts(merchantId: 'm_flipkart');
      expect(products.items, isNotEmpty);
      for (final product in products.items) {
        expect(product.merchantId, 'm_flipkart');
        expect(Uri.parse(product.affiliateUrl).isAbsolute, isTrue);
        expect(product.price, greaterThan(0));
      }
    });

    test('search filters products and blank search means no filter', () async {
      const useCase = GetMerchantProducts(repository);
      final all = await useCase(merchantId: 'm_amazon', search: '   ');
      final filtered = await useCase(merchantId: 'm_amazon', search: 'watch');
      expect(filtered.items.length, lessThan(all.items.length));
      expect(
        filtered.items.every((p) => p.name.toLowerCase().contains('watch')),
        isTrue,
      );
    });

    test('unknown platform is a 404', () {
      expect(
        repository.getProducts(merchantId: 'nope'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  test('Formatters.price', () {
    expect(Formatters.price(1299), '₹1,299');
    expect(Formatters.price(32990), '₹32,990');
    expect(Formatters.price(499.5), '₹499.50');
    expect(Formatters.price(10, symbol: r'$'), r'$10');
  });
}
