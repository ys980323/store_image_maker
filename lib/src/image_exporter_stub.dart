import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_ja.dart';

import 'dart:typed_data';

Future<String> savePngBytes(
  Uint8List bytes, {
  AppLocalizations? localizations,
}) async {
  final l10n = localizations ?? AppLocalizationsJa();
  throw UnsupportedError(l10n.platformSaveUnsupported);
}
