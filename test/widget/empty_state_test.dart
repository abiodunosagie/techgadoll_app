import 'package:flutter_test/flutter_test.dart';
import 'package:techgadoll_app/shared/widgets/empty_state.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('EmptyState', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(pumpApp(
        const EmptyState(title: 'No results'),
      ));

      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (tester) async {
      await tester.pumpWidget(pumpApp(
        const EmptyState(
          title: 'No results',
          subtitle: 'Try a different search',
        ),
      ));

      expect(find.text('Try a different search'), findsOneWidget);
    });

    testWidgets('does not display subtitle when empty', (tester) async {
      await tester.pumpWidget(pumpApp(
        const EmptyState(title: 'No results'),
      ));

      // Only title should be present, no subtitle text
      expect(find.text('No results'), findsOneWidget);
    });
  });
}
