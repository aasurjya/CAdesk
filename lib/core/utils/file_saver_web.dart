import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Triggers a browser file download for the given content.
Future<void> saveFile(String content, String fileName) async {
  final parts = [content.toJS].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: 'application/json'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
