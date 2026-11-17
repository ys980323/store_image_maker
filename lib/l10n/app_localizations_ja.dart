// Generated with Flutter's standard localization delegates for SDK compatibility.
// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ストアイメージ作成';

  @override
  String get sampleHeadline => 'あなたのアプリを、もっと魅力的に';

  @override
  String get presetName => 'プリセット名';

  @override
  String get presetNameHint => 'プリセット名を入力';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get imageSizeError => '画像サイズを取得できませんでした。PNG/JPGのスクリーンショットを選択してください。';

  @override
  String get imageReadError => '画像データを読み込めませんでした。';

  @override
  String get selectScreenshotFirst => '先にスクリーンショット画像を選択してください。';

  @override
  String get previewAreaError => 'プレビュー領域を取得できませんでした。';

  @override
  String get pngDataError => 'PNGデータの生成に失敗しました。';

  @override
  String get savingUnsupported => 'PNGは生成しました。現在のプラットフォームは保存非対応です。';

  @override
  String get resolutionError => '出力解像度の正規化に失敗しました。';

  @override
  String get pageOpenError => 'ページを開けませんでした。';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get rateApp => 'アプリを評価する';

  @override
  String get livePreview => 'ライブプレビュー';

  @override
  String get livePreviewDescription => '設定変更はリアルタイム反映されます';

  @override
  String get expandPreview => 'プレビューを拡大';

  @override
  String get restorePreview => 'プレビューを戻す';

  @override
  String get presets => 'プリセット';

  @override
  String get presetsDescription => '設定を保存・読み込みできます';

  @override
  String get savePreset => '現在の設定をプリセットとして保存';

  @override
  String get savedPresets => '保存済みプリセット';

  @override
  String get delete => '削除';

  @override
  String get export => '書き出し';

  @override
  String get exportDescription => 'PNGを生成し、端末へ保存します';

  @override
  String outputResolution(String width, String height) {
    return '出力解像度は $width x $height px に固定されています';
  }

  @override
  String get generating => '生成中...';

  @override
  String get generateAndSave => 'PNGを生成して保存';

  @override
  String get headlineHint => 'キャッチコピーを入力してください';

  @override
  String get selectScreenshotPrompt => 'スクリーンショットを選択';

  @override
  String get sourceImage => '素材画像';

  @override
  String get sourceImageDescription => 'アプリのスクリーンショットを取り込みます';

  @override
  String get changeScreenshot => 'スクリーンショット変更';

  @override
  String get selectScreenshot => 'スクリーンショット選択';

  @override
  String get virtualNotch => '仮想ノッチ';

  @override
  String get virtualNotchDescription => 'スクショ上に仮想ノッチを重ねて表示';

  @override
  String get background => '背景';

  @override
  String get backgroundDescription => 'ストアイメージの背景をカスタマイズします';

  @override
  String get solid => '単色';

  @override
  String get gradient => 'グラデーション';

  @override
  String get backgroundColor => '背景色';

  @override
  String get startColor => '開始色';

  @override
  String get endColor => '終了色';

  @override
  String get text => '文字';

  @override
  String get textDescription => 'キャッチコピーの見た目を調整します';

  @override
  String get title => 'タイトル';

  @override
  String get titleHint => 'タイトルを入力';

  @override
  String get textColor => '文字色';

  @override
  String get subtitle => 'サブテキスト';

  @override
  String get subtitleHint => 'サブテキストを入力（任意）';

  @override
  String get subtitleColor => 'サブテキスト文字色';

  @override
  String get top => '上部';

  @override
  String get bottom => '下部';

  @override
  String get alignLeft => '左寄せ';

  @override
  String get alignCenter => '中央';

  @override
  String get alignRight => '右寄せ';

  @override
  String get showPreview => 'プレビュー表示';

  @override
  String get preview => 'プレビュー';

  @override
  String get close => '閉じる';

  @override
  String get previewError => 'プレビューの生成に失敗しました';

  @override
  String get custom => 'カスタム';

  @override
  String get customColor => 'カスタムカラー';

  @override
  String get apply => '適用';

  @override
  String get photosSaveError => '写真アプリへの保存に失敗しました。';

  @override
  String get platformSaveUnsupported => 'このプラットフォームではファイル保存に対応していません。';

  @override
  String presetSaved(String name) {
    return 'プリセット「$name」を保存しました';
  }

  @override
  String presetDeleted(String name) {
    return 'プリセット「$name」を削除しました';
  }

  @override
  String presetApplied(String name) {
    return 'プリセット「$name」を適用しました';
  }

  @override
  String imagePickError(String error) {
    return '画像選択に失敗しました: $error';
  }

  @override
  String imageSaved(String path) {
    return '画像を保存しました: $path';
  }

  @override
  String imageSaveError(String error) {
    return 'PNGは生成しましたが、保存に失敗しました: $error';
  }

  @override
  String imageGenerateError(String error) {
    return '画像生成に失敗しました: $error';
  }

  @override
  String notchSize(String value) {
    return '仮想ノッチサイズ: $value';
  }

  @override
  String deviceSize(String value) {
    return '端末画像サイズ: $value';
  }

  @override
  String fontSize(String value) {
    return 'フォントサイズ: $value';
  }

  @override
  String lineHeight(String value) {
    return '行間: $value';
  }

  @override
  String letterSpacing(String value) {
    return '文字間隔: $value';
  }

  @override
  String photosLocation(String assetId) {
    return 'iPhoneの写真アプリ (assetId: $assetId)';
  }

  @override
  String get colorWhite => 'White';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorSky => 'Sky';

  @override
  String get colorNavy => 'Navy';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorOrange => 'Orange';
}
