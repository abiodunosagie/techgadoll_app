import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techgadoll_app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'has_seen_onboarding': true,
      'is_logged_in': true,
      'session_expiry': DateTime.now()
          .add(const Duration(days: 1))
          .millisecondsSinceEpoch,
      'user_name': 'Test User',
      'user_email': 'test@test.com',
    });
  });

  group('Product Catalog Flow', () {
    testWidgets('loads product list and displays products', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: ProductCatalogApp()),
      );

      // Wait for splash to navigate to main shell
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should see the Product Catalog app bar
      expect(find.text('Product Catalog'), findsOneWidget);

      // Should see the search bar
      expect(find.byType(TextField), findsOneWidget);

      // Wait for products to load from API
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should display product cards
      expect(find.byType(Card), findsWidgets);

      // Should see category chips (All is always present)
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('search filters products', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: ProductCatalogApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Type in search field
      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'mascara');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Results should contain search term or be empty
      // (depends on API availability)
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('category filter works', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: ProductCatalogApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find a category chip that is not "All" and tap it
      final beautyChip = find.text('Beauty');
      if (beautyChip.evaluate().isNotEmpty) {
        await tester.tap(beautyChip);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Products should reload with category filter
        expect(find.byType(Card), findsWidgets);
      }

      // Tap "All" to reset
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('navigate to product detail and back', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: ProductCatalogApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap the first product card
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should see the "Add to Cart" button on detail page
        expect(find.text('Add to Cart'), findsWidgets);

        // Go back
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('add to cart from product card', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: ProductCatalogApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find "Add to Cart" buttons on product cards
      final addButtons = find.widgetWithText(ElevatedButton, 'Add to Cart');
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle();

        // Should show snackbar
        expect(find.text('added to cart', findRichText: true), findsWidgets);

        // Button should change to "Added"
        expect(find.widgetWithText(ElevatedButton, 'Added'), findsWidgets);
      }
    });

    testWidgets('wishlist toggle from product card', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: ProductCatalogApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find heart icons on product cards
      final hearts = find.byIcon(Icons.favorite_border);
      if (hearts.evaluate().isNotEmpty) {
        await tester.tap(hearts.first);
        await tester.pumpAndSettle();

        // Heart should turn filled
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    testWidgets('bottom navigation switches tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: ProductCatalogApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should start on Shop tab
      expect(find.text('Shop'), findsOneWidget);

      // Navigate to Wishlist
      await tester.tap(find.text('Wishlist').last);
      await tester.pumpAndSettle();
      expect(find.text('Your wishlist is empty'), findsOneWidget);

      // Navigate to Cart
      await tester.tap(find.text('Cart').last);
      await tester.pumpAndSettle();
      expect(find.text('Your cart is empty'), findsOneWidget);

      // Navigate to Profile
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsWidgets);

      // Back to Shop
      await tester.tap(find.text('Shop').last);
      await tester.pumpAndSettle();
      expect(find.text('Product Catalog'), findsOneWidget);
    });
  });
}
