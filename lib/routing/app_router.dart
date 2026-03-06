import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/products/presentation/screens/main_shell.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';
import '../features/showcase/presentation/screens/showcase_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/showcase',
      builder: (context, state) => const ShowcaseScreen(),
    ),
  ],
);
