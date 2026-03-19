import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Saves content to the device documents directory.
Future<void> saveFile(String content, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = p.join(dir.path, fileName);
  await File(filePath).writeAsString(content);
}
