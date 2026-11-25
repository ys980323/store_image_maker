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
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Image Maker'**
  String get appTitle;

  /// No description provided for @sampleHeadline.
  ///
  /// In en, this message translates to:
  /// **'Make your app shine'**
  String get sampleHeadline;

  /// No description provided for @presetName.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get presetName;

  /// No description provided for @presetNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a preset name'**
  String get presetNameHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @imageSizeError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the image size. Please choose a PNG or JPG screenshot.'**
  String get imageSizeError;

  /// No description provided for @imageReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the image data.'**
  String get imageReadError;

  /// No description provided for @selectScreenshotFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a screenshot first.'**
  String get selectScreenshotFirst;

  /// No description provided for @previewAreaError.
  ///
  /// In en, this message translates to:
  /// **'Could not access the preview area.'**
  String get previewAreaError;

  /// No description provided for @pngDataError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the PNG data.'**
  String get pngDataError;

  /// No description provided for @savingUnsupported.
  ///
  /// In en, this message translates to:
  /// **'The PNG was generated, but saving is not supported on this platform.'**
  String get savingUnsupported;

  /// No description provided for @resolutionError.
  ///
  /// In en, this message translates to:
  /// **'Could not resize the image to the output resolution.'**
  String get resolutionError;

  /// No description provided for @pageOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the page.'**
  String get pageOpenError;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get rateApp;

  /// No description provided for @livePreview.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get livePreview;

  /// No description provided for @livePreviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Changes appear in real time'**
  String get livePreviewDescription;

  /// No description provided for @expandPreview.
  ///
  /// In en, this message translates to:
  /// **'Expand preview'**
  String get expandPreview;

  /// No description provided for @restorePreview.
  ///
  /// In en, this message translates to:
  /// **'Restore preview'**
  String get restorePreview;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @presetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Save and load your settings'**
  String get presetsDescription;

  /// No description provided for @savePreset.
  ///
  /// In en, this message translates to:
  /// **'Save current settings as a preset'**
  String get savePreset;

  /// No description provided for @savedPresets.
  ///
  /// In en, this message translates to:
  /// **'Saved presets'**
  String get savedPresets;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate a PNG and save it to your device'**
  String get exportDescription;

  /// No description provided for @outputResolution.
  ///
  /// In en, this message translates to:
  /// **'Output resolution is fixed at {width} x {height} px'**
  String outputResolution(String width, String height);

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @generateAndSave.
  ///
  /// In en, this message translates to:
  /// **'Generate and save PNG'**
  String get generateAndSave;

  /// No description provided for @headlineHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your headline'**
  String get headlineHint;

  /// No description provided for @selectScreenshotPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a screenshot'**
  String get selectScreenshotPrompt;

  /// No description provided for @sourceImage.
  ///
  /// In en, this message translates to:
  /// **'Source image'**
  String get sourceImage;

  /// No description provided for @sourceImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Import a screenshot of your app'**
  String get sourceImageDescription;

  /// No description provided for @changeScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Change screenshot'**
  String get changeScreenshot;

  /// No description provided for @selectScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Select screenshot'**
  String get selectScreenshot;

  /// No description provided for @virtualNotch.
  ///
  /// In en, this message translates to:
  /// **'Virtual notch'**
  String get virtualNotch;

  /// No description provided for @virtualNotchDescription.
  ///
  /// In en, this message translates to:
  /// **'Overlay a virtual notch on the screenshot'**
  String get virtualNotchDescription;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @backgroundDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize your store image background'**
  String get backgroundDescription;

  /// No description provided for @solid.
  ///
  /// In en, this message translates to:
  /// **'Solid color'**
  String get solid;

  /// No description provided for @gradient.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get gradient;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get backgroundColor;

  /// No description provided for @startColor.
  ///
  /// In en, this message translates to:
  /// **'Start color'**
  String get startColor;

  /// No description provided for @endColor.
  ///
  /// In en, this message translates to:
  /// **'End color'**
  String get endColor;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @textDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust the appearance of your headline'**
  String get textDescription;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get titleHint;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get textColor;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get subtitle;

  /// No description provided for @subtitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a subtitle (optional)'**
  String get subtitleHint;

  /// No description provided for @subtitleColor.
  ///
  /// In en, this message translates to:
  /// **'Subtitle color'**
  String get subtitleColor;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @bottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get bottom;

  /// No description provided for @alignLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get alignLeft;

  /// No description provided for @alignCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get alignCenter;

  /// No description provided for @alignRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get alignRight;

  /// No description provided for @showPreview.
  ///
  /// In en, this message translates to:
  /// **'Show preview'**
  String get showPreview;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @previewError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the preview'**
  String get previewError;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColor;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @photosSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the image to Photos.'**
  String get photosSaveError;

  /// No description provided for @platformSaveUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Saving files is not supported on this platform.'**
  String get platformSaveUnsupported;

  /// No description provided for @presetSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved preset “{name}”.'**
  String presetSaved(String name);

  /// No description provided for @presetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted preset “{name}”.'**
  String presetDeleted(String name);

  /// No description provided for @presetApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied preset “{name}”.'**
  String presetApplied(String name);

  /// No description provided for @imagePickError.
  ///
  /// In en, this message translates to:
  /// **'Could not select the image: {error}'**
  String imagePickError(String error);

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved: {path}'**
  String imageSaved(String path);

  /// No description provided for @imageSaveError.
  ///
  /// In en, this message translates to:
  /// **'The PNG was generated, but could not be saved: {error}'**
  String imageSaveError(String error);

  /// No description provided for @imageGenerateError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the image: {error}'**
  String imageGenerateError(String error);

  /// No description provided for @notchSize.
  ///
  /// In en, this message translates to:
  /// **'Virtual notch size: {value}'**
  String notchSize(String value);

  /// No description provided for @deviceSize.
  ///
  /// In en, this message translates to:
  /// **'Device image size: {value}'**
  String deviceSize(String value);

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size: {value}'**
  String fontSize(String value);

  /// No description provided for @lineHeight.
  ///
  /// In en, this message translates to:
  /// **'Line height: {value}'**
  String lineHeight(String value);

  /// No description provided for @letterSpacing.
  ///
  /// In en, this message translates to:
  /// **'Letter spacing: {value}'**
  String letterSpacing(String value);

  /// No description provided for @photosLocation.
  ///
  /// In en, this message translates to:
  /// **'Photos on iPhone (assetId: {assetId})'**
  String photosLocation(String assetId);

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get colorSky;

  /// No description provided for @colorNavy.
  ///
  /// In en, this message translates to:
  /// **'Navy'**
  String get colorNavy;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get colorAmber;

  /// No description provided for @colorRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
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
