import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techgadoll_app/shared/widgets/rating_bar.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('RatingBar', () {
    testWidgets('displays rating text', (tester) async {
      await tester.pumpWidget(pumpApp(
        const RatingBar(rating: 4.5),
      ));

      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('shows 5 star icons', (tester) async {
      await tester.pumpWidget(pumpApp(
        const RatingBar(rating: 3.0),
      ));

      final starIcons = find.byType(Icon);
      expect(starIcons, findsNWidgets(5));
    });

    testWidgets('shows review count when provided', (tester) async {
      await tester.pumpWidget(pumpApp(
        const RatingBar(rating: 4.0, reviewCount: 128),
      ));

      expect(find.text('(128)'), findsOneWidget);
    });

    testWidgets('does not show review count when not provided', (tester) async {
      await tester.pumpWidget(pumpApp(
        const RatingBar(rating: 4.0),
      ));

      expect(find.textContaining('('), findsNothing);
    });

    testWidgets('shows zero rating correctly', (tester) async {
      await tester.pumpWidget(pumpApp(
        const RatingBar(rating: 0.0),
      ));

      expect(find.text('0.0'), findsOneWidget);
    });
  });
}
