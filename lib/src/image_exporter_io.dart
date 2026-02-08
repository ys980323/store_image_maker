import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const MethodChannel _imageExporterChannel = MethodChannel(
  'store_image_maker/image_exporter',
);

Future<String> savePngBytes(Uint8List bytes) async {
  if (Platform.isIOS) {
    final assetId = await _imageExporterChannel.invokeMethod<String>(
      'saveImageToPhotos',
      {'bytes': bytes},
    );
    if (assetId == null || assetId.isEmpty) {
      throw StateError('写真アプリへの保存に失敗しました。');
    }
    return 'iPhoneの写真アプリ (assetId: $assetId)';
  }

  final directory = await getApplicationDocumentsDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final path = '${directory.path}/store_image_$timestamp.png';
  final file = File(path);
  await file.writeAsBytes(bytes, flush: true);
  return path;
}
