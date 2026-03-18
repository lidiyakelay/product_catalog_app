# Product Catalog App

Flutter technical assessment implementation for a product catalog app using the DummyJSON API, with a reusable design system, responsive master-detail layout, deep linking, and test coverage.

## Setup & Run Instructions

### Prerequisites
- Flutter `3.35.1` (stable)
- Dart `3.9.0`

### Install dependencies
```bash
flutter pub get
```

### Run the app
```bash
flutter run
```

### Analyze and test
```bash
flutter analyze
flutter test
```

## Architecture Overview

### Folder structure
- `lib/app/`: app-level configuration (`constants`, `di`, `routes`, `theme`).
- `lib/core/`: shared core utilities and abstractions (`error`, `usecases`, `utils`).
- `lib/domain/`: business layer (`entities`, `repositories`, `usecases`).
- `lib/data/`: data layer (`datasources/remote`, `models`, `repositories`).
- `lib/presentation/`: UI and state (`pages`, `widgets`, `state_management`).
- `lib/app.dart`, `lib/main.dart`: app bootstrap and runtime wiring.
- `lib/bloc/`, `lib/ui/`, `lib/router/`: legacy folders retained during migration compatibility.

### State management approach
- `flutter_bloc` is used to separate business logic from UI.
- Product list state lives in `lib/presentation/state_management/product_list/` and handles explicit states: `initial`, `loading`, `loaded`, `error`, `empty`.
- Product detail state lives in `lib/presentation/state_management/product_detail/` and handles explicit states: `initial`, `loading`, `loaded`, `error`.
- Theme state is controlled via `ThemeCubit`.

### Key architectural decisions
- Repository + use case layering isolates network calls from UI state and keeps business logic testable.
- Debounced search (500ms) avoids excessive API requests.
- Infinite scroll is implemented through `ScrollController` + pagination (`limit/skip`).
- `GoRouter` is used through centralized routing in `lib/app/routes/app_router.dart` with deep linking (`/products/:id`).
- On tablet width (`>= 768`), the app switches to master-detail; on phone, it uses push navigation.

## Design System Rationale

### Component API choices
- `ProductCard`: receives a `Product`, optional `onTap`, and optional `isSelected` for tablet selection highlighting.
- `SearchBarWidget`: controlled input callback with reusable hint text.
- `CategoryChips`: simple selection API using `selectedCategory` + `onSelected`.
- `ErrorStateWidget`, `EmptyStateWidget`, and `NoSelectionWidget`: reusable state visuals for consistency.
- `ShimmerLoadingList` and `ProductCardSkeleton`: standard loading placeholder visuals.

### Theming strategy
- Light and dark themes are defined in `AppTheme`.
- Core visual tokens are centralized (`AppColors`, `AppTypography`, spacing, radius constants).
- Components consume theme values and adapt color semantics in both modes.

### Deviations from spec
- Combined search + category is implemented with server-side search, then category filtering client-side for the combined mode because the API does not provide a dedicated endpoint for search-within-category.
- Data validation logs are handled in model parsing (using `logger`) and fallback values are applied to prevent crashes.

## Limitations

- Offline caching is not implemented (optional enhancement B).
- Some advanced polish enhancements are partial/minimal (for example, full stagger choreography and custom pull-to-refresh animation can be improved).
- Persisting theme preference and filters across app restarts is not implemented.
- Category names use API slugs with formatting; richer display metadata is not provided by API.

If more time were available:
1. Add local cache (Hive/Isar) with stale-while-revalidate strategy and cache freshness indicators.
2. Improve animation system (staggered list entrance, shared transitions tuned by breakpoint).
3. Add more robust repository tests with mocked API client and error matrix.
4. Add golden tests for design system components in light and dark themes.

## AI Tools Usage

AI tools were used to accelerate scaffolding and repetitive setup, including:
- Initial project structure planning.
- Drafting component/state layer boilerplate.
- Generating baseline tests and README skeleton.

All generated outputs were reviewed, corrected, and refined manually:
- Routing and responsive behavior were adjusted for assignment requirements.
- Type/lint issues were fixed and verified through `flutter analyze`.
- Tests were validated by running `flutter test`.
- Component APIs and state flow were tuned for clarity and maintainability.
