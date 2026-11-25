// Keep the standard Flutter Material API for compatibility with older SDKs.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_image_maker/main.dart';

void main() {
  for (final language in ['ja', 'en', 'fr']) {
    testWidgets('editor uses $language locale with English fallback', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.binding.platformDispatcher.localeTestValue = Locale(language);
      addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
      await tester.pumpWidget(const StoreImageMakerApp());
      await tester.pumpAndSettle();

      final english = language != 'ja';
      expect(
        find.text(english ? 'Store Image Maker' : 'ストアイメージ作成'),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.text(english ? 'Generate and save PNG' : 'PNGを生成して保存'),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(
        find.text(english ? 'Privacy Policy' : 'プライバシーポリシー'),
        findsOneWidget,
      );
    });
  }
}
