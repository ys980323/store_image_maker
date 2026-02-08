import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String> savePngBytes(Uint8List bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final path = '${directory.path}/store_image_$timestamp.png';
  final file = File(path);
  await file.writeAsBytes(bytes, flush: true);
  return path;
}
