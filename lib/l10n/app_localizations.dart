// Generated with Flutter's standard localization delegates for SDK compatibility.
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'ストアイメージ作成'**
  String get appTitle;

  /// No description provided for @sampleHeadline.
  ///
  /// In ja, this message translates to:
  /// **'あなたのアプリを、もっと魅力的に'**
  String get sampleHeadline;

  /// No description provided for @presetName.
  ///
  /// In ja, this message translates to:
  /// **'プリセット名'**
  String get presetName;

  /// No description provided for @presetNameHint.
  ///
  /// In ja, this message translates to:
  /// **'プリセット名を入力'**
  String get presetNameHint;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @imageSizeError.
  ///
  /// In ja, this message translates to:
  /// **'画像サイズを取得できませんでした。PNG/JPGのスクリーンショットを選択してください。'**
  String get imageSizeError;

  /// No description provided for @imageReadError.
  ///
  /// In ja, this message translates to:
  /// **'画像データを読み込めませんでした。'**
  String get imageReadError;

  /// No description provided for @selectScreenshotFirst.
  ///
  /// In ja, this message translates to:
  /// **'先にスクリーンショット画像を選択してください。'**
  String get selectScreenshotFirst;

  /// No description provided for @previewAreaError.
  ///
  /// In ja, this message translates to:
  /// **'プレビュー領域を取得できませんでした。'**
  String get previewAreaError;

  /// No description provided for @pngDataError.
  ///
  /// In ja, this message translates to:
  /// **'PNGデータの生成に失敗しました。'**
  String get pngDataError;

  /// No description provided for @savingUnsupported.
  ///
  /// In ja, this message translates to:
  /// **'PNGは生成しました。現在のプラットフォームは保存非対応です。'**
  String get savingUnsupported;

  /// No description provided for @resolutionError.
  ///
  /// In ja, this message translates to:
  /// **'出力解像度の正規化に失敗しました。'**
  String get resolutionError;

  /// No description provided for @pageOpenError.
  ///
  /// In ja, this message translates to:
  /// **'ページを開けませんでした。'**
  String get pageOpenError;

  /// No description provided for @privacyPolicy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get termsOfService;

  /// No description provided for @rateApp.
  ///
  /// In ja, this message translates to:
  /// **'アプリを評価する'**
  String get rateApp;

  /// No description provided for @livePreview.
  ///
  /// In ja, this message translates to:
  /// **'ライブプレビュー'**
  String get livePreview;

  /// No description provided for @livePreviewDescription.
  ///
  /// In ja, this message translates to:
  /// **'設定変更はリアルタイム反映されます'**
  String get livePreviewDescription;

  /// No description provided for @expandPreview.
  ///
  /// In ja, this message translates to:
  /// **'プレビューを拡大'**
  String get expandPreview;

  /// No description provided for @restorePreview.
  ///
  /// In ja, this message translates to:
  /// **'プレビューを戻す'**
  String get restorePreview;

  /// No description provided for @presets.
  ///
  /// In ja, this message translates to:
  /// **'プリセット'**
  String get presets;

  /// No description provided for @presetsDescription.
  ///
  /// In ja, this message translates to:
  /// **'設定を保存・読み込みできます'**
  String get presetsDescription;

  /// No description provided for @savePreset.
  ///
  /// In ja, this message translates to:
  /// **'現在の設定をプリセットとして保存'**
  String get savePreset;

  /// No description provided for @savedPresets.
  ///
  /// In ja, this message translates to:
  /// **'保存済みプリセット'**
  String get savedPresets;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @export.
  ///
  /// In ja, this message translates to:
  /// **'書き出し'**
  String get export;

  /// No description provided for @exportDescription.
  ///
  /// In ja, this message translates to:
  /// **'PNGを生成し、端末へ保存します'**
  String get exportDescription;

  /// No description provided for @outputResolution.
  ///
  /// In ja, this message translates to:
  /// **'出力解像度は {width} x {height} px に固定されています'**
  String outputResolution(String width, String height);

  /// No description provided for @generating.
  ///
  /// In ja, this message translates to:
  /// **'生成中...'**
  String get generating;

  /// No description provided for @generateAndSave.
  ///
  /// In ja, this message translates to:
  /// **'PNGを生成して保存'**
  String get generateAndSave;

  /// No description provided for @headlineHint.
  ///
  /// In ja, this message translates to:
  /// **'キャッチコピーを入力してください'**
  String get headlineHint;

  /// No description provided for @selectScreenshotPrompt.
  ///
  /// In ja, this message translates to:
  /// **'スクリーンショットを選択'**
  String get selectScreenshotPrompt;

  /// No description provided for @sourceImage.
  ///
  /// In ja, this message translates to:
  /// **'素材画像'**
  String get sourceImage;

  /// No description provided for @sourceImageDescription.
  ///
  /// In ja, this message translates to:
  /// **'アプリのスクリーンショットを取り込みます'**
  String get sourceImageDescription;

  /// No description provided for @changeScreenshot.
  ///
  /// In ja, this message translates to:
  /// **'スクリーンショット変更'**
  String get changeScreenshot;

  /// No description provided for @selectScreenshot.
  ///
  /// In ja, this message translates to:
  /// **'スクリーンショット選択'**
  String get selectScreenshot;

  /// No description provided for @virtualNotch.
  ///
  /// In ja, this message translates to:
  /// **'仮想ノッチ'**
  String get virtualNotch;

  /// No description provided for @virtualNotchDescription.
  ///
  /// In ja, this message translates to:
  /// **'スクショ上に仮想ノッチを重ねて表示'**
  String get virtualNotchDescription;

  /// No description provided for @background.
  ///
  /// In ja, this message translates to:
  /// **'背景'**
  String get background;

  /// No description provided for @backgroundDescription.
  ///
  /// In ja, this message translates to:
  /// **'ストアイメージの背景をカスタマイズします'**
  String get backgroundDescription;

  /// No description provided for @solid.
  ///
  /// In ja, this message translates to:
  /// **'単色'**
  String get solid;

  /// No description provided for @gradient.
  ///
  /// In ja, this message translates to:
  /// **'グラデーション'**
  String get gradient;

  /// No description provided for @backgroundColor.
  ///
  /// In ja, this message translates to:
  /// **'背景色'**
  String get backgroundColor;

  /// No description provided for @startColor.
  ///
  /// In ja, this message translates to:
  /// **'開始色'**
  String get startColor;

  /// No description provided for @endColor.
  ///
  /// In ja, this message translates to:
  /// **'終了色'**
  String get endColor;

  /// No description provided for @text.
  ///
  /// In ja, this message translates to:
  /// **'文字'**
  String get text;

  /// No description provided for @textDescription.
  ///
  /// In ja, this message translates to:
  /// **'キャッチコピーの見た目を調整します'**
  String get textDescription;

  /// No description provided for @title.
  ///
  /// In ja, this message translates to:
  /// **'タイトル'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In ja, this message translates to:
  /// **'タイトルを入力'**
  String get titleHint;

  /// No description provided for @textColor.
  ///
  /// In ja, this message translates to:
  /// **'文字色'**
  String get textColor;

  /// No description provided for @subtitle.
  ///
  /// In ja, this message translates to:
  /// **'サブテキスト'**
  String get subtitle;

  /// No description provided for @subtitleHint.
  ///
  /// In ja, this message translates to:
  /// **'サブテキストを入力（任意）'**
  String get subtitleHint;

  /// No description provided for @subtitleColor.
  ///
  /// In ja, this message translates to:
  /// **'サブテキスト文字色'**
  String get subtitleColor;

  /// No description provided for @top.
  ///
  /// In ja, this message translates to:
  /// **'上部'**
  String get top;

  /// No description provided for @bottom.
  ///
  /// In ja, this message translates to:
  /// **'下部'**
  String get bottom;

  /// No description provided for @alignLeft.
  ///
  /// In ja, this message translates to:
  /// **'左寄せ'**
  String get alignLeft;

  /// No description provided for @alignCenter.
  ///
  /// In ja, this message translates to:
  /// **'中央'**
  String get alignCenter;

  /// No description provided for @alignRight.
  ///
  /// In ja, this message translates to:
  /// **'右寄せ'**
  String get alignRight;

  /// No description provided for @showPreview.
  ///
  /// In ja, this message translates to:
  /// **'プレビュー表示'**
  String get showPreview;

  /// No description provided for @preview.
  ///
  /// In ja, this message translates to:
  /// **'プレビュー'**
  String get preview;

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @previewError.
  ///
  /// In ja, this message translates to:
  /// **'プレビューの生成に失敗しました'**
  String get previewError;

  /// No description provided for @custom.
  ///
  /// In ja, this message translates to:
  /// **'カスタム'**
  String get custom;

  /// No description provided for @customColor.
  ///
  /// In ja, this message translates to:
  /// **'カスタムカラー'**
  String get customColor;

  /// No description provided for @apply.
  ///
  /// In ja, this message translates to:
  /// **'適用'**
  String get apply;

  /// No description provided for @photosSaveError.
  ///
  /// In ja, this message translates to:
  /// **'写真アプリへの保存に失敗しました。'**
  String get photosSaveError;

  /// No description provided for @platformSaveUnsupported.
  ///
  /// In ja, this message translates to:
  /// **'このプラットフォームではファイル保存に対応していません。'**
  String get platformSaveUnsupported;

  /// No description provided for @presetSaved.
  ///
  /// In ja, this message translates to:
  /// **'プリセット「{name}」を保存しました'**
  String presetSaved(String name);

  /// No description provided for @presetDeleted.
  ///
  /// In ja, this message translates to:
  /// **'プリセット「{name}」を削除しました'**
  String presetDeleted(String name);

  /// No description provided for @presetApplied.
  ///
  /// In ja, this message translates to:
  /// **'プリセット「{name}」を適用しました'**
  String presetApplied(String name);

  /// No description provided for @imagePickError.
  ///
  /// In ja, this message translates to:
  /// **'画像選択に失敗しました: {error}'**
  String imagePickError(String error);

  /// No description provided for @imageSaved.
  ///
  /// In ja, this message translates to:
  /// **'画像を保存しました: {path}'**
  String imageSaved(String path);

  /// No description provided for @imageSaveError.
  ///
  /// In ja, this message translates to:
  /// **'PNGは生成しましたが、保存に失敗しました: {error}'**
  String imageSaveError(String error);

  /// No description provided for @imageGenerateError.
  ///
  /// In ja, this message translates to:
  /// **'画像生成に失敗しました: {error}'**
  String imageGenerateError(String error);

  /// No description provided for @notchSize.
  ///
  /// In ja, this message translates to:
  /// **'仮想ノッチサイズ: {value}'**
  String notchSize(String value);

  /// No description provided for @deviceSize.
  ///
  /// In ja, this message translates to:
  /// **'端末画像サイズ: {value}'**
  String deviceSize(String value);

  /// No description provided for @fontSize.
  ///
  /// In ja, this message translates to:
  /// **'フォントサイズ: {value}'**
  String fontSize(String value);

  /// No description provided for @lineHeight.
  ///
  /// In ja, this message translates to:
  /// **'行間: {value}'**
  String lineHeight(String value);

  /// No description provided for @letterSpacing.
  ///
  /// In ja, this message translates to:
  /// **'文字間隔: {value}'**
  String letterSpacing(String value);

  /// No description provided for @photosLocation.
  ///
  /// In ja, this message translates to:
  /// **'iPhoneの写真アプリ (assetId: {assetId})'**
  String photosLocation(String assetId);

  /// No description provided for @colorWhite.
  ///
  /// In ja, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorBlack.
  ///
  /// In ja, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorSky.
  ///
  /// In ja, this message translates to:
  /// **'Sky'**
  String get colorSky;

  /// No description provided for @colorNavy.
  ///
  /// In ja, this message translates to:
  /// **'Navy'**
  String get colorNavy;

  /// No description provided for @colorTeal.
  ///
  /// In ja, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorGreen.
  ///
  /// In ja, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorAmber.
  ///
  /// In ja, this message translates to:
  /// **'Amber'**
  String get colorAmber;

  /// No description provided for @colorRose.
  ///
  /// In ja, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// No description provided for @colorPurple.
  ///
  /// In ja, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorOrange.
  ///
  /// In ja, this message translates to:
  /// **'Orange'**
  String get colorOrange;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
