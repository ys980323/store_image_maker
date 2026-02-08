import 'package:flutter_test/flutter_test.dart';
import 'package:store_image_maker/main.dart';

void main() {
  testWidgets('app title is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const StoreImageMakerApp());

    expect(find.text('ストアイメージ作成'), findsAtLeastNWidgets(1));
    expect(find.text('PNGを生成して保存'), findsOneWidget);
  });
}
