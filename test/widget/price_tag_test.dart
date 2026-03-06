import 'package:flutter_test/flutter_test.dart';
import 'package:techgadoll_app/shared/widgets/price_tag.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('PriceTag', () {
    testWidgets('shows formatted price', (tester) async {
      await tester.pumpWidget(pumpApp(
        const PriceTag(price: 49.99),
      ));

      expect(find.text('\$49.99'), findsOneWidget);
    });

    testWidgets('shows "Price unavailable" for null price', (tester) async {
      await tester.pumpWidget(pumpApp(
        const PriceTag(price: null),
      ));

      expect(find.text('Price unavailable'), findsOneWidget);
    });

    testWidgets('shows discounted price and original crossed out', (tester) async {
      await tester.pumpWidget(pumpApp(
        const PriceTag(price: 100.0, discountPercentage: 20),
      ));

      expect(find.text('\$80.00'), findsOneWidget);
      expect(find.text('\$100.00'), findsOneWidget);
      expect(find.text('-20%'), findsOneWidget);
    });

    testWidgets('shows no discount badge when percentage is 0', (tester) async {
      await tester.pumpWidget(pumpApp(
        const PriceTag(price: 50.0, discountPercentage: 0),
      ));

      expect(find.text('\$50.00'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    });
  });
}
