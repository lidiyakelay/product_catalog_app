import 'package:logger/logger.dart';

final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

String validateImageUrl(String url, String field, dynamic id) {
  if (url.isEmpty) {
    _logger.w('Product $id: Missing $field URL');
    return '';
  }
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) {
    _logger.w('Product $id: Invalid $field URL: $url');
    return '';
  }
  return url;
}
