import 'dart:io';

/// Platform-aware handler for WebView file upload chooser callbacks.
///
/// When the ITD portal requests a file via `<input type="file">`, the
/// WebView's `onShowFileChooser` callback delegates to this handler,
/// which provides the path of the previously exported JSON file.
class FileUploadHandler {
  const FileUploadHandler({required this.filePath});

  /// Absolute path to the file to upload (e.g., the exported ITR-1 JSON).
  final String filePath;

  /// Returns a list of file paths to provide to the WebView file chooser.
  ///
  /// Returns an empty list if the file does not exist.
  List<String> getFilePaths() {
    if (!File(filePath).existsSync()) return [];
    return [filePath];
  }

  /// Validates that the file exists and is non-empty.
  bool get isValid {
    final file = File(filePath);
    return file.existsSync() && file.lengthSync() > 0;
  }

  /// Returns the file name without the directory path.
  String get fileName {
    final segments = filePath.split(Platform.pathSeparator);
    return segments.isNotEmpty ? segments.last : filePath;
  }

  /// Returns the file size in bytes, or 0 if the file does not exist.
  int get fileSizeBytes {
    final file = File(filePath);
    return file.existsSync() ? file.lengthSync() : 0;
  }
}
