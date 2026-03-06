# Product Catalog App

A Flutter application that displays a product catalog with a custom design system, responsive layouts, and offline support. Built for the Tech Gadol Senior Flutter Developer assessment.

## Setup & Run

**Requirements:** Flutter 3.38.4 (stable), Dart 3.10.3

```bash
git clone https://github.com/abiodunosagie/techgadoll_app.git
cd techgadoll_app
flutter pub get
flutter run
```

No API keys or environment variables needed. The app uses the public [DummyJSON](https://dummyjson.com) products API.

**Demo credentials:** `demo@techgadol.com` / `Demo1234`

```bash
# Run unit + widget tests
flutter test

# Run integration tests
flutter test integration_test/

# Static analysis
flutter analyze
```

## Architecture

The project follows a **feature-first** structure. Each feature owns its data and presentation layers. Shared UI components live in `shared/widgets/` as the design system.

```
lib/
  core/
    cache/            SQLite offline cache (sqflite)
    constants/        Breakpoints, page sizes, layout values
    network/          HTTP client, API endpoints
    theme/            Light + dark ThemeData, color tokens
    utils/            Validators, debouncer
  shared/widgets/     Reusable design system components
  features/
    auth/             Login, signup with form validation
    products/
      data/
        models/       ProductModel, CategoryModel, ProductsResponse
        repositories/ ProductRepository (network + cache)
      presentation/
        providers/    Riverpod providers and notifiers
        screens/      Product list, detail, responsive shell
        widgets/      Image gallery, info section
    cart/             Shopping cart with quantity management
    wishlist/         Wishlist with heart toggle
    profile/          User profile, stats, sign out
    onboarding/       First-launch onboarding flow
    splash/           Animated splash screen
    showcase/         Design system component showcase
  routing/            GoRouter with deep linking
test/
  unit/               Model parsing, validators, provider tests
  widget/             Design system component tests
  helpers/            Mock data and utilities
integration_test/     End-to-end flow tests
```

### State Management

I chose **Riverpod** for state management. The main reasons:

- **Compile-safe providers.** Dependencies are resolved at compile time. No runtime errors from missing providers in the widget tree.
- **Reactive data flow.** `StateNotifierProvider` manages the product list (pagination, search debounce, category filtering) in one testable notifier. `FutureProvider.family` handles product detail fetching with per-ID caching.
- **Minimal boilerplate.** No separate event/state class files. Business logic stays cleanly separated from UI without the overhead.

The data flow is straightforward: UI reads providers via `ref.watch()`, user interactions update `StateProvider` values (search query, selected category), and the `ProductListNotifier` reacts to changes via `ref.listen()`.

### Key Decisions

| Decision | Why |
|---|---|
| Feature-first folders | Each feature is self-contained. Easy to navigate and scale. |
| `CachedResult<T>` wrapper | Repository returns data + a `fromCache` flag so the UI can indicate stale data. |
| Client-side category + search filtering | DummyJSON doesn't support combined search + category queries. Search results are fetched from the API, then filtered by category locally. |
| Responsive shell with `LayoutBuilder` | Master-detail on tablets, push navigation on phones. Single widget handles the switch. |
| Debounce in the notifier | The search field fires `onChanged` immediately. The notifier debounces before hitting the API, keeping the widget layer pure. |
| MasonryGridView for product grid | Products have variable content height (brand, title length). Masonry layout avoids forced empty space below shorter cards. |
| SharedPreferences for cart/wishlist | Cart and wishlist state persists across app restarts without requiring a backend. JSON serialization via `toJson()`/`fromJson()` on models. |
| Iconsax icon set | Consistent, modern icon language across the entire app instead of default Material icons. |

## Design System

Reusable components with minimal, composable APIs:

| Component | Purpose |
|---|---|
| `ProductCard` | Grid card with image, brand, title, rating, price, wishlist toggle, and add-to-cart button. |
| `PriceTag` | Formatted price with discount badge. Handles null price gracefully. |
| `RatingBar` | 5-star display with filled, half, and empty states. |
| `CategoryChip` | Filter chip with animated selection. |
| `AppSearchBar` | Search field with clear button. Named to avoid SDK `SearchBar` conflict. |
| `LoadingShimmer` | Shimmer placeholder grid matching card proportions. |
| `ErrorState` | Error message with retry action. |
| `EmptyState` | Lottie-animated empty state for no-results and empty screens. |

### Theming

Two complete themes (light and dark) built on Material 3's `ColorScheme`. The light theme uses `ColorScheme.fromSeed()` with targeted overrides. The dark theme uses a manual `ColorScheme` constructor with neutral gray surfaces to prevent the warm green tint that `fromSeed` produces on dark backgrounds. Primary color: `#4EAC68`.

All components read colors from `Theme.of(context).colorScheme`, so they adapt to both themes automatically without any conditional `isDark` checks scattered through the codebase.

## Features

- **Product browsing** with paginated list, search with debounce, and category filtering
- **Product detail** with image gallery, specs, and stock status
- **Shopping cart** with quantity controls and persistent state across restarts
- **Wishlist** with heart toggle from any product card, dedicated wishlist screen
- **Responsive layout** adapting from phone to tablet (master-detail)
- **Offline support** via SQLite cache with stale-data indicator
- **Light and dark themes** with full Material 3 color system
- **Auth flow** with login, signup, session persistence, and onboarding

## Responsive Layout

The app adapts to phones, tablets, and large screens:

- **Phone:** Single-column grid (2 columns), push navigation to detail screen.
- **Tablet:** Master-detail layout. Product list on the left, detail on the right. Grid columns increase with screen width.
- **Auth screens:** Adaptive horizontal padding (wider margins on tablets) so form fields don't stretch edge to edge.
- **Breakpoints** are centralized in `AppConstants` for consistency.

## Offline Support

Products are cached locally using **sqflite**. When the network is unavailable, the app serves cached data and displays a subtle indicator. The `ProductRepository` implements a cache-through pattern: fetch from API, write to SQLite, fall back to cache on failure. Cache entries expire after a configurable TTL.

## Testing

- **Unit tests:** Model JSON parsing, data validators, `ProductListNotifier` state transitions (loading, pagination, search, category filtering, error handling, cache fallback).
- **Widget tests:** All design system components (EmptyState, ErrorState, PriceTag, RatingBar) tested for rendering, interaction, and edge cases.
- **Integration tests:** End-to-end flows covering product list loading, search filtering, category filtering, product detail navigation, add-to-cart, wishlist toggle, and bottom navigation tab switching. Run with `flutter test integration_test/`.

## Spec Deviations

- Used **Riverpod** instead of Bloc/Cubit. The assessment allows any state management approach.
- Added **splash screen**, **onboarding flow**, **auth screens**, **wishlist**, and **cart** beyond the spec to demonstrate a complete user experience.
- Used **Iconsax** icon set for a consistent, modern visual style across the app.
