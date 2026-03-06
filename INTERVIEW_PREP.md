# Interview Prep: Product Catalog App

Read this before your interview. Everything is explained simply so you can recall it and explain it in your own words.

---

## 1. Architecture: How the App is Organized

### Folder Structure

Think of it like a house. Each room (feature) has everything it needs inside it. You do not store the kitchen sink in the bedroom closet.

```
lib/
  core/       → Stuff every room shares (paint colors, plumbing, electricity)
  shared/     → Furniture that works in any room (reusable widgets)
  features/   → The rooms themselves (cart, wishlist, products, etc.)
  routing/    → The hallways connecting the rooms (navigation)
```

**Why this way?** If someone says "change how the cart works," you go to `features/cart/` and everything you need is right there. You do not have to hunt through 5 different folders.

Each feature has the same internal layout:

```
features/products/
  data/
    models/        → What a product looks like (its shape/fields)
    repositories/  → How to get product data (from API or cache)
  presentation/
    providers/     → The brain (business logic, state management)
    screens/       → What the user sees (full pages)
    widgets/       → Smaller pieces used on those pages
```

**Simple way to say it:** "I used feature-first architecture. Each feature owns its own data layer and presentation layer. It keeps things organized and makes it easy to add new features without touching existing code."

### The Core Folder

This is the shared stuff:

- **cache/** → Saves API data to a local database (SQLite) so the app works offline. Data expires after 30 minutes.
- **network/** → Talks to the DummyJSON API. All the URLs are in one file. If the API address changes, you update one place.
- **theme/** → All the colors and styles. Light mode and dark mode.
- **constants/** → All the "magic numbers" in one place. Screen size breakpoints, how many products to load per page (20), how long to wait before searching (500ms).
- **utils/** → Helper tools. One validates data from the API (catches bad prices, broken image URLs). Another is a debouncer (waits for the user to stop typing before searching).

### Why Riverpod (Not BLoC)

**Simple explanation:** "I chose Riverpod because it gives me the same separation of business logic from UI that BLoC gives, but with way less code. BLoC makes you create 8+ classes per feature (events, states, bloc class). Riverpod does the same thing with just 2 classes: a state class and a notifier class. Also, Riverpod catches dependency errors at compile time, not at runtime, so you cannot ship a broken provider."

**If they push back:** "The assessment said any state management is fine. Riverpod is widely adopted, well-tested, and the Flutter team has endorsed it. For an app this size, BLoC would add a lot of ceremony without extra benefit."

### How Data Flows (Search Example)

Imagine a user searching for "phone":

1. User types "p-h-o-n-e" in the search bar. Each letter fires immediately.
2. The search text gets stored in a simple provider (like a variable).
3. The product list notifier is watching that variable. But it does NOT search right away.
4. It waits 500ms. If the user keeps typing, it resets the timer. This prevents 5 API calls for "p", "ph", "pho", "phon", "phone".
5. After 500ms of silence, it calls the API.
6. If the API fails (no internet), it checks the local SQLite cache for old data.
7. The results come back, the state updates, and the UI automatically rebuilds to show the new products.

**Simple way to say it:** "The UI writes to providers, the notifier reacts to those providers with debouncing, hits the API through the repository, and the UI rebuilds automatically when state changes."

### Offline / Caching

**Simple explanation:** "I used a cache-through pattern. The repository always tries the network first. If it succeeds, it saves the data to SQLite and returns it. If it fails, it checks SQLite for a cached version. The UI shows a little banner saying 'Showing cached data' so the user knows it might be stale. Cache expires after 30 minutes."

### Navigation (GoRouter)

**Simple explanation:** "All routes are defined in one file. GoRouter gives me deep linking for free, so `/products/5` goes straight to product 5. It handles the URL parameters and the back button automatically."

Routes:
- `/splash` → checks if user is logged in, redirects
- `/onboarding` → first-time intro (only shown once)
- `/login`, `/signup` → auth
- `/` → the main app with bottom tabs
- `/products/:id` → product detail
- `/showcase` → design system demo page

### Responsive Layout (Phone vs iPad)

This is important. Here is exactly how it works:

**On Phone (screen narrower than 768px):**
- Products show in a 2-column grid, full width.
- Tap a product, it pushes a new screen (slides in from the right).
- Hit back, you return to the list. Your scroll position is saved.

**On iPad/Tablet (screen 768px or wider) - Two stages:**

1. **Stage 1: No product selected yet.** The shop uses the FULL screen. Products show in 3 or 4 columns depending on width. Nice big grid, lots of products visible.

2. **Stage 2: User taps a product.** The screen SPLITS. Product list shrinks to the left side (380px, 2 columns). Product detail appears on the right side. You can tap different products on the left and the right side updates instantly. No page navigation needed.

3. **Going back to full width:** There is a close button (X) on the detail panel. Tap it, the detail closes, and you are back to the full-width grid.

**Why two stages?** If you always show the split, half the screen is wasted with an empty "Select a product" message before the user has even started browsing. This way, they get the full screen for browsing first.

**How it works in code:**
- `MainShell` has a `LayoutBuilder` that checks screen width.
- On tablet, it reads `selectedProductIdProvider`.
- If null (nothing selected), it shows full-width `ProductListScreen`.
- If a product is selected, it shows a `Row` with the list on the left and the detail on the right.
- The detail screen has an `onClose` callback that sets the selected ID back to null.
- The `ProductListScreen` is the SAME widget in both modes. On phone it pushes a route. On tablet it calls a callback. One widget, two behaviors.

**Simple way to say it:** "On tablet, the app starts with a full-width grid. When the user picks a product, it splits into master-detail. There is a close button to go back to full-width. The same ProductListScreen widget handles both phone and tablet. It just gets different callbacks."

---

## 2. Design System: The Reusable Widgets

### Three Rules I Followed

1. **Keep it simple.** Only require the parameters the widget actually needs. Everything else has a default.
2. **Use theme colors, not hardcoded colors.** Widgets read from `Theme.of(context).colorScheme`. This means they automatically work in both light and dark mode. No `if (isDark)` checks.
3. **One widget, one job.** `PriceTag` just shows prices. `RatingBar` just shows stars. `ProductCard` composes them together. Need a price somewhere else? Just use `PriceTag`.

### The Widgets

**ProductCard** - The product tile in the grid.
- Shows image, brand name, title, rating stars, price, wishlist heart, and "Add to Cart" button.
- It is a `ConsumerWidget` (not `StatelessWidget`) because it reads cart and wishlist state from Riverpod to know if the product is already in cart or wishlisted.
- The image has a `Hero` animation so it smoothly flies from the grid into the detail screen.
- Two soft shadows (not one) to look natural, like the card is slightly floating.
- Images load from the internet with `CachedNetworkImage`. Shows a spinner while loading, a fallback icon if it fails.

**PriceTag** - Shows the price.
- If there is a discount: shows the new price, the old price crossed out, and a red badge like "-15%".
- If price is null: shows "Price unavailable" in gray.
- Uses `Wrap` instead of `Row`. This is important. On narrow cards (like in the iPad split view), the price + old price + badge can be too wide to fit on one line. `Wrap` lets them flow to the next line instead of overflowing with those ugly yellow/black stripes.

**RatingBar** - Shows 1-5 stars.
- Stars can be full, half, or empty. Gold for filled, gray for empty.
- Star colors are hardcoded (not from theme) because gold stars should look the same in light and dark mode.

**CategoryChip** - The filter buttons ("All", "Beauty", "Fragrances", etc.).
- Green background when selected, outline when not selected.
- Compact size so they fit in the horizontal scroll.

**LoadingShimmer** - The skeleton loading screen.
- Shows while products are being fetched. Matches the shape of real product cards so the transition feels smooth.

**AppSearchBar** - The search field.
- Named `AppSearchBar` (not `SearchBar`) because Flutter already has a widget called `SearchBar` and they would conflict.
- Shows a clear (X) button only when there is text typed.

**EmptyState / ErrorState** - Shown when there are no results or something went wrong. ErrorState has a retry button.

### Theming

**Light theme:** Built with `ColorScheme.fromSeed()` which generates a full color palette from the primary green (#4EAC68). I manually overrode some surface colors to be clean white/gray instead of the slightly green-tinted ones that fromSeed generates.

**Dark theme:** I did NOT use `fromSeed()` for dark. Why? Because `fromSeed` adds a greenish tint to dark surfaces, and that looks weird for a product catalog. Instead, I manually set every dark color to neutral grays (#121212, #1E1E1E, #2A2A2A). Clean and professional.

**Dialog fix:** Material 3 puts a green tint on dialogs by default (from the primary color). I fixed this in the theme with `surfaceTintColor: Colors.transparent` so all dialogs are clean white/dark.

**Simple way to say it:** "Both themes are built on Material 3's ColorScheme. Light uses fromSeed with overrides. Dark uses a fully manual ColorScheme because fromSeed adds an unwanted color tint to dark surfaces. All widgets read from the theme, so they automatically adapt."

### Spec Deviations (Things I Did Differently)

- **Riverpod instead of BLoC.** Same quality, less code. Assessment allows any approach.
- **Iconsax instead of Material Icons.** More modern, consistent look across the whole app.
- **MasonryGridView instead of regular GridView.** Products have different heights (some have brand names, some do not). Masonry layout removes the wasted space that a fixed-height grid would create.
- **Extra features.** Added wishlist, cart, auth, onboarding, and splash. Not required, but shows I can build a complete app, not just a product list.

---

## 3. Testing: What I Tested and Why

### Unit Tests (Testing the Logic)

**Product Model tests (8 tests)** - "Can the app handle bad data from the API?"
- Valid JSON parses correctly.
- Missing fields (no brand, no thumbnail) do not crash. They use defaults.
- Negative price gets rejected (returns null, shows "Price unavailable").
- Fake image URLs (like `javascript:alert()`) get filtered out.
- Discount math is correct: price * (1 - discount/100).
- Two products with the same ID are considered equal.

**Why:** The data comes from an external API we do not control. If they send garbage, the app should handle it, not crash.

**Data Validator tests (12 tests)** - "Do our safety checks work?"
- `safePrice()`: accepts numbers, rejects negatives and non-numbers.
- `safeImageUrl()`: only accepts http/https URLs. Blocks everything else.
- `safeRating()`: clamps to 0-5. API sends 6.2? We show 5.0.
- `safeString()`: null or empty string? We use a default instead of showing blank.

**Product List Notifier tests (6 tests)** - "Does the state machine work correctly?"
- Starting up loads the first page of products.
- API failure shows an error state.
- "Load more" adds the next page to the existing list.
- When all products are loaded, "load more" does nothing (no wasted API calls).
- Empty search results show the empty state.
- Cached data sets the `isFromCache` flag so the UI can show a warning.

**Simple way to say it:** "I tested at three levels. Unit tests make sure the data parsing and state transitions are correct. Widget tests make sure the UI components render properly. Integration tests make sure everything works together end-to-end."

### Widget Tests (Testing the UI Components)

**PriceTag (5 tests):** Shows correct price, handles null, shows discount correctly, hides badge when no discount.

**RatingBar (5 tests):** Shows correct number, renders 5 stars, handles zero rating.

**EmptyState / ErrorState:** Text renders, retry button works.

All widget tests use a helper called `pumpApp()` that wraps the widget in a MaterialApp with the theme, so theme-dependent widgets work correctly in tests.

### Integration Tests (Testing the Whole App)

These launch the actual app and interact with it like a real user would:

1. **Products load** - App starts, products appear.
2. **Search works** - Type a query, products filter.
3. **Category filter works** - Tap "Beauty", only beauty products show.
4. **Detail navigation** - Tap a product, detail screen appears.
5. **Add to cart** - Tap the button, it changes to "Added", cart badge increments.
6. **Wishlist toggle** - Tap heart, it fills red. Tap again, it empties.
7. **Bottom nav** - All 4 tabs show their correct screens.

Run with: `flutter test integration_test/`

**Simple way to say it:** "Integration tests prove the whole app works as a system, not just individual pieces. They cover the main user journeys: browsing, searching, filtering, viewing details, managing cart and wishlist, and navigating between tabs."

---

## 4. Interview Q&A Cheat Sheet

Read these out loud a few times so they feel natural.

---

**Q: Why not BLoC?**

"BLoC is great but it adds a lot of boilerplate. For each feature you need Event classes, State classes, and a Bloc class. Riverpod gives me the same separation of logic from UI with just a state class and a notifier. Plus Riverpod catches dependency errors at compile time, not runtime. The assessment said any state management is fine."

---

**Q: How does offline work?**

"The repository tries the network first. If it works, it saves the response to SQLite. If the network fails, it checks SQLite for cached data. The cache expires after 30 minutes. The UI shows a little banner saying 'Showing cached data' so the user knows."

---

**Q: How would you scale this app?**

"The feature-first structure already supports scaling. Each new feature is its own folder. For a bigger app, I would add a domain layer with use cases to separate business logic from the repository, and switch from offset pagination to cursor-based pagination."

---

**Q: Why SharedPreferences for cart/wishlist?**

"Cart and wishlist are small. Usually under 50 items. SharedPreferences with JSON is simple and fast for that. SQLite would be overkill. If the data grew a lot, I could swap in SQLite or Hive since the storage is abstracted behind the notifier."

---

**Q: How does the iPad/tablet layout work?**

"On tablet, the app starts with a full-width product grid, 3 to 4 columns. When the user taps a product, the screen splits: product list on the left, detail on the right. There is a close button to go back to full-width. I used a LayoutBuilder to check screen width, and a simple provider to track which product is selected. Same ProductListScreen widget works in both modes."

---

**Q: Why not always show the split on tablet?**

"Because half the screen would be wasted showing 'Select a product' before the user has picked anything. Full-width first gives them more products to browse. The split activates when they actually engage with a product."

---

**Q: How do search and category work together?**

"DummyJSON does not support both in one query. So I fetch search results from the API, then filter by category on the client side. The notifier watches both the search and category providers and re-fetches when either changes, with debouncing."

---

**Q: What if the API sends bad data?**

"Every field goes through validators. Negative prices become null and show 'Price unavailable'. Bad image URLs get filtered out and show a placeholder icon. Ratings get clamped to 0 through 5. Strings get defaults instead of showing blank. I have 12 unit tests specifically for these validators."

---

**Q: Why MasonryGridView?**

"Products have different heights. Some have brand names, some do not. Titles vary. A regular GridView forces every card to the same height, which creates empty space below short cards. MasonryGridView lets each card be its natural height."

---

**Q: How does state persist across app restarts?**

"The notifier loads from SharedPreferences in its constructor and saves after every change. Models have toJson and fromJson methods for serialization. Cart, wishlist, and auth state all persist this way."

---

**Q: Walk me through adding to cart.**

"User taps Add to Cart. The button calls the cart notifier's addToCart method. It checks if the product is already in the cart. If yes, increment quantity. If no, add it with quantity 1. Then it saves to SharedPreferences. Because the state changed, every widget watching the cart provider rebuilds. The button changes from black 'Add to Cart' to green 'Added'. The badge on the Cart tab in the bottom nav increments. All automatic through Riverpod reactivity."

---

**Q: Why PriceTag uses Wrap instead of Row?**

"On narrow cards, like in the iPad split view, the discounted price plus the original price plus the discount badge do not fit on one line. Row would overflow and show ugly yellow/black stripes. Wrap lets the items flow to the next line gracefully."

---

**Q: Tell me about your design system.**

"I built 8 reusable components. Each one does one thing. They all read colors from the theme, so they work in light and dark mode automatically. They have minimal required parameters with sensible defaults. ProductCard composes PriceTag, RatingBar, and CachedNetworkImage together. There is a showcase screen at /showcase that displays every component in all its states, with a light/dark toggle."

---

You got this. Read through this a couple of times and practice saying the answers out loud. The key is: you understand WHY every decision was made, not just WHAT was done.
