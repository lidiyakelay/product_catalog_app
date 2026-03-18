class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://dummyjson.com';
  static const int pageSize = 20;
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration cacheMaxAge = Duration(hours: 6);
  static const double tabletBreakpoint = 768.0;
  static const double listPanelWidth = 380.0;

  // User-facing error messages (do not expose raw exceptions)
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String productListErrorMessage = 'Unable to load products right now. Please try again.';
  static const String productDetailErrorMessage = 'Unable to load product details right now. Please try again.';
}
