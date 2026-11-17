import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_ja.dart';

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const MethodChannel _imageExporterChannel = MethodChannel(
  'store_image_maker/image_exporter',
);

Future<String> savePngBytes(
  Uint8List bytes, {
  AppLocalizations? localizations,
}) async {
  final l10n = localizations ?? AppLocalizationsJa();
  if (Platform.isIOS) {
    final assetId = await _imageExporterChannel.invokeMethod<String>(
      'saveImageToPhotos',
      {'bytes': bytes},
    );
    if (assetId == null || assetId.isEmpty) {
      throw StateError(l10n.photosSaveError);
    }
    return l10n.photosLocation(assetId);
  }

  final directory = await getApplicationDocumentsDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final path = '${directory.path}/store_image_$timestamp.png';
  final file = File(path);
  await file.writeAsBytes(bytes, flush: true);
  return path;
}
