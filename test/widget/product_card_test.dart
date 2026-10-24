import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/features/shopping/domain/entities/product.dart';
import 'package:kavodnik/features/shopping/presentation/widgets/product_card.dart';

import '../helpers/test_helpers.dart';

void main() {
  const product = Product(
    id: 'p1',
    merchantId: 'm_amazon',
    name: 'boAt Rockerz 450 Bluetooth Headphones',
    price: 1299,
    originalPrice: 3990,
    affiliateUrl: 'https://amzn.to/abc',
    rewardText: 'Up to ₹65 back',
  );

  Widget card(VoidCallback onBuyNow) => themed(
    SizedBox(
      width: 180,
      height: 180 + ProductCard.detailsHeight,
      child: ProductCard(product: product, onBuyNow: onBuyNow),
    ),
  );

  testWidgets('shows name, price, MRP, discount and reward', (tester) async {
    await tester.pumpWidget(card(() {}));
    expect(find.text(product.name), findsOneWidget);
    expect(find.text('₹1,299'), findsOneWidget);
    expect(find.text('₹3,990'), findsOneWidget);
    expect(find.text('67% OFF'), findsOneWidget);
    expect(find.text('Up to ₹65 back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Buy now calls back', (tester) async {
    var taps = 0;
    await tester.pumpWidget(card(() => taps++));
    await tester.tap(find.text('Buy now'));
    expect(taps, 1);
  });
}
