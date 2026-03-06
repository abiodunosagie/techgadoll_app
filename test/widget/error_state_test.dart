import 'package:flutter_test/flutter_test.dart';
import 'package:techgadoll_app/shared/widgets/error_state.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ErrorState', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(pumpApp(
        ErrorState(
          message: 'Connection failed',
          onRetry: () {},
        ),
      ));

      expect(find.text('Connection failed'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button', (tester) async {
      await tester.pumpWidget(pumpApp(
        ErrorState(
          message: 'Error',
          onRetry: () {},
        ),
      ));

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button fires callback', (tester) async {
      var retried = false;

      await tester.pumpWidget(pumpApp(
        ErrorState(
          message: 'Error',
          onRetry: () => retried = true,
        ),
      ));

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });
}
