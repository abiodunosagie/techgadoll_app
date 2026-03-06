import 'package:go_router/go_router.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/products/presentation/screens/responsive_product_shell.dart';
import '../features/showcase/presentation/screens/showcase_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ResponsiveProductShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ProductListScreen(),
          routes: [
            GoRoute(
              path: 'products/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return ProductDetailScreen(productId: id);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/showcase',
      builder: (context, state) => const ShowcaseScreen(),
    ),
  ],
);
