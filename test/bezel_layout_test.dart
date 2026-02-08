import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_image_maker/main.dart';

void main() {
  test('store image output size is fixed for App Store', () {
    expect(kStoreImageOutputWidth, 1290);
    expect(kStoreImageOutputHeight, 2796);
    expect(kStoreImageOutputAspectRatio, closeTo(1290 / 2796, 1e-12));
  });

  test('bezel adds 10px on each side', () {
    final layout = BezelLayout.forScreenshotSize(const Size(1028, 1920));

    expect(layout.outerWidth, closeTo(1048, 1e-9));
    expect(layout.outerHeight, closeTo(1940, 1e-9));
  });

  test('scaled inner area keeps original screenshot aspect ratio', () {
    const source = Size(1028, 1920);
    final layout = BezelLayout.forScreenshotSize(source);

    const maxWidth = 320.0;
    const maxHeight = 680.0;
    final scale = math.min(
      maxWidth / layout.outerWidth,
      maxHeight / layout.outerHeight,
    );
    final innerWidth =
        layout.outerWidth * scale - BezelLayout.bezelPixels * scale * 2;
    final innerHeight =
        layout.outerHeight * scale - BezelLayout.bezelPixels * scale * 2;

    expect(
      innerWidth / innerHeight,
      closeTo(source.width / source.height, 1e-9),
    );
  });
}
