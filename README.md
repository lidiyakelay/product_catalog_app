# Product Catalog App

Flutter technical assessment implementation using DummyJSON, with a reusable design system, clean architecture layering, responsive master-detail behavior, deep linking, offline fallback cache, and test coverage.

## 1. Setup & Run Instructions

### Toolchain
- Flutter 3.35.1 (stable)
- Dart 3.9.0

### Install dependencies
```bash
flutter pub get
```

### Run the app
```bash
flutter run
```

### Quality checks
```bash
flutter analyze
flutter test
```

## 2. Architecture Overview

### Folder structure
- `lib/app/`: app-level wiring (`constants`, `di`, `routes`, `theme`).
- `lib/core/`: cross-cutting concerns (`error`, `usecases`, `utils`).
- `lib/domain/`: entities, repository contracts, use cases.
- `lib/data/`: remote/local datasources, models, repository implementation.
- `lib/presentation/`: pages, reusable widgets, Bloc/Cubit state management.
- `lib/main.dart`, `lib/app.dart`: bootstrap and app root composition.

### State management approach
- `flutter_bloc` with feature-scoped state:
	- `ProductListBloc`: pagination, filters, search debounce, refresh, cache source flag.
	- `ProductDetailBloc`: detail fetch and error states.
	- `ThemeCubit`: global light/dark mode control.

### Key architectural decisions
- Use case + repository boundaries keep UI independent from data sources.
- Remote-first strategy with local SQLite fallback for product data.
- Centralized routing with `go_router` and deep links (`/products/:id`, `/showcase`).
- Responsive behavior:
	- tablet/desktop (`>= 768`): master-detail split view.
	- phone: push navigation between list/detail.

## 3. Design System Rationale

### Component API choices
- `ProductCard`: domain-first API (`product`), plus optional `onTap` and `isSelected`.
- `SearchBarWidget`: reusable controlled input with `initialQuery` and `onChanged`.
- `CategoryChips`: clear selection contract (`selectedCategory`, `onSelected`).
- State components (`ErrorStateWidget`, `EmptyStateWidget`, `NoSelectionWidget`) provide consistent UX for async/loading edge cases.
- Loading components (`ProductCardSkeleton`, `ShimmerLoadingList`) standardize perceived performance behavior.

### Theming approach
- Light and dark themes are centralized in `AppTheme`.
- Components consume semantic theme values from `ThemeData` rather than hardcoded colors where possible.
- Theme mode is controlled via `ThemeCubit` and applied at app root with smooth transition animation.

### Deviations / practical handling
- API does not provide direct “search within category” endpoint, so combined mode is handled by searching then filtering by category.
- Imperfect API data is normalized in model parsing (fallback values, validation, and safe UI defaults).

## 4. Limitations

- Cache invalidation is currently TTL-based (6 hours) and simple; no background stale-while-revalidate pipeline yet.
- Offline fallback is focused on product/categorical/search list use cases; conflict resolution is not needed because data is read-only.
- Theme preference is not persisted across app restarts.
- Animation polish can still be extended (for example richer entrance choreography and more nuanced refresh visuals) while keeping UX simple.

With more time, I would add:
1. Persisted user preferences (theme, selected filters) and richer cache metadata (last sync timestamp per dataset).
2. Additional repository/data-source unit tests specifically for offline fallback branches.
3. Golden tests for key design-system widgets in both themes.
4. Lightweight performance benchmarking in profile mode for 100+ item scrolling.

## 5. AI Tools Usage

AI was used as an engineering accelerator, not as a source of final truth.

Where it helped:
- Generate and compare implementation options for architecture refactors, UI decomposition, and optional enhancements.
- Speed up repetitive boilerplate for Bloc wiring, tests, and docs structure.
- Surface edge cases and validation paths during iterative debugging.

What was intentionally refined manually:
- Final architecture boundaries and naming decisions.
- Error-handling behavior and user-facing messaging.
- Responsive layout behavior, navigation semantics, and UI polish trade-offs.
- Test expectations and failure-case behavior.

In short: AI assisted with throughput; design decisions, code quality checks, and final implementation choices were curated and validated manually.
