import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/product_providers.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';

class ResponsiveProductShell extends ConsumerWidget {
  final Widget child;

  const ResponsiveProductShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= AppConstants.tabletBreakpoint;

        if (!isTablet) {
          return child;
        }

        final selectedId = ref.watch(selectedProductIdProvider);

        return Row(
          children: [
            SizedBox(
              width: AppConstants.masterPaneWidth,
              child: ProductListScreen(
                isTabletLeftPane: true,
                onProductSelected: (id) {
                  ref.read(selectedProductIdProvider.notifier).state = id;
                  context.go('/products/$id');
                },
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: selectedId != null
                  ? ProductDetailScreen(
                      key: ValueKey(selectedId),
                      productId: selectedId,
                    )
                  : const EmptyState(
                      title: 'Select a product',
                      subtitle:
                          'Choose a product from the list to view its details.',
                      icon: Icons.touch_app_outlined,
                    ),
            ),
          ],
        );
      },
    );
  }
}
