# Product Catalog App

A Flutter application that displays a product catalog using a custom design system, built for the Tech Gadol Senior Flutter Developer assessment.

## Setup & Run Instructions

**Flutter version:** 3.38.4 (stable channel)

```bash
# Clone the repository
git clone https://github.com/abiodunosagie/techgadoll_app.git
cd techgadoll_app

# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Run analysis
flutter analyze
```

The app targets iOS, Android, and Web platforms. No environment variables or API keys are needed since it uses the public DummyJSON API.

## Architecture Overview

### Folder Structure

```
lib/
  core/
    cache/            SQLite-based offline caching
    constants/        App-wide constants (page size, breakpoints)
    network/          HTTP client and API endpoints
    theme/            Colors, ThemeData (light + dark)
    utils/            Data validators, debouncer
  shared/widgets/     Design system components (reusable across features)
  features/
    products/
      data/
        models/       ProductModel, CategoryModel, ProductsResponse
        repositories/ ProductRepository (API + cache layer)
      presentation/
        providers/    Riverpod state management
        screens/      ProductListScreen, ProductDetailScreen, ResponsiveShell
        widgets/      ProductImageGallery, ProductInfoSection
    onboarding/       One-time onboarding flow
    showcase/         Component showcase screen (Enhancement A)
    splash/           Animated splash screen
  routing/            GoRouter configuration with deep linking
test/
  unit/               Model parsing, validators, provider state tests
  widget/             Design system component widget tests
  helpers/            Mock data and test utilities
```

### State Management: Riverpod

I chose Riverpod over Bloc for this project because:

- **Compile-safe dependency injection.** Providers are resolved at compile time, eliminating runtime errors from missing providers in the widget tree.
- **Fine-grained reactivity.** `StateNotifierProvider` for the product list manages pagination, search debounce, and category filtering in a single, testable notifier. `FutureProvider.family` handles individual product detail fetching with automatic caching per product ID.
- **No boilerplate.** Riverpod eliminates the need for separate event/state classes, reducing the number of files while keeping business logic cleanly separated from UI.

State flow: UI reads providers via `ref.watch()`, user actions update `StateProvider` values (search query, selected category), and the `ProductListNotifier` reacts to these changes automatically via `ref.listen()`.

### Key Architectural Decisions

| Decision | Rationale |
|---|---|
| Feature-first folder structure | Each feature owns its own data and presentation layers. Shared widgets live in `shared/` as the design system. |
| `CachedResult<T>` wrapper | Repository methods return both the data and a `fromCache` boolean, allowing the UI to show a visual indicator when serving cached data. |
| Client-side filtering for search + category | DummyJSON does not support searching within a category. When both are active, search results are fetched then filtered by category client-side. |
| `ShellRoute` for responsive layout | The `ResponsiveProductShell` wraps product routes and uses `LayoutBuilder` to switch between master-detail (tablet) and push navigation (phone). |
| Debounce in the notifier, not the widget | The search `TextField` fires `onChanged` immediately. The notifier debounces before making API calls. This keeps the widget pure and the debounce testable. |

## Design System Rationale

### Components

| Component | API | Notes |
|---|---|---|
| `ProductCard` | `product`, `onTap`, `isSelected` | Displays thumbnail, brand, title, rating, and price. `isSelected` highlights the card in tablet master-detail. |
| `PriceTag` | `price`, `discountPercentage`, `fontSize` | Handles `null` price with "Price unavailable" text. Shows original price crossed out with discount badge when applicable. |
| `RatingBar` | `rating`, `reviewCount`, `size` | 5-star display with filled, half, and empty states. Optional review count. |
| `CategoryChip` | `label`, `isSelected`, `onTap` | Animated selection state with primary color fill. |
| `AppSearchBar` | `onChanged`, `hintText`, `initialValue` | TextField with search icon and clear button. Named `AppSearchBar` to avoid SDK conflict. |
| `LoadingShimmer` | `itemCount` | Shimmer grid matching ProductCard proportions. |
| `ErrorState` | `message`, `onRetry` | Error icon, message, and retry button. |
| `EmptyState` | `title`, `subtitle`, `icon` | Centered message for no-results states. |

### Theming

Both light and dark themes are built from `ColorScheme.fromSeed(seedColor: primaryGreen)` with manual overrides for card, chip, input, and button themes. The primary color is `#4EAC68`. Components read colors from `Theme.of(context)` and `AppColors` constants, so they adapt to both themes automatically.

### Deviations from Spec

- Used Riverpod instead of the encouraged Bloc/Cubit. The assessment states any solution is acceptable.
- Added splash screen and onboarding flow beyond the spec to demonstrate a polished user experience.

## Limitations

With more time, I would improve:

- **Integration tests.** Add end-to-end tests with `integration_test` package covering the full user flow (search, filter, navigate to detail, responsive layout).
- **Cache invalidation UI.** Add a pull-to-refresh gesture that forces a fresh API call and clears stale cache.
- **Hero animations (Enhancement C).** Add shared element transitions between the product thumbnail in the list and the detail image gallery.
- **Staggered animations.** Add staggered fade-in animations for grid items on first load.
- **Accessibility.** Add semantic labels to all interactive elements and test with screen readers.
- **Error recovery on pagination.** Currently, if a "load more" request fails, the error is silently swallowed. A snackbar notification would improve UX.

## AI Tools Usage

I used Claude (Anthropic) as an AI assistant during development. Here is how it was used:

- **Project scaffolding.** Generated the initial folder structure, pubspec.yaml dependencies, and boilerplate files.
- **Design system components.** Generated initial widget implementations for ProductCard, PriceTag, RatingBar, and other design system components. I reviewed and refined the component APIs to ensure they were minimal and composable.
- **State management setup.** Generated the Riverpod provider structure and ProductListNotifier. I refined the search + category combination logic and the CachedResult wrapper pattern.
- **Test generation.** Generated test scaffolding for models, validators, and widget tests. I adjusted async timing in provider tests and added edge case coverage.
- **Offline caching.** Generated the SQLite cache implementation. I reviewed the cache invalidation strategy and the cache-through pattern in the repository.

All generated code was reviewed, tested, and refined before committing. The architecture decisions (Riverpod over Bloc, CachedResult pattern, client-side category filtering, ShellRoute for responsive layout) were deliberate choices, not AI defaults.
