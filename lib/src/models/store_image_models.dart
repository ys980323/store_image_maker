import 'dart:math' as math;

import 'package:flutter/material.dart';

enum BackgroundMode { solid, gradient, image }

enum TitlePosition { top, bottom }

enum TitleAlignment { left, center, right }

class PaletteColor {
  const PaletteColor(this.name, this.color);

  final String name;
  final Color color;
}

const int kStoreImageOutputWidth = 1290;
const int kStoreImageOutputHeight = 2796;
const double kStoreImageOutputAspectRatio =
    kStoreImageOutputWidth / kStoreImageOutputHeight;

class BezelLayout {
  static const double bezelPixels = 16.0;
  static const double outerFramePixels = 8.0;
  static const double highlightOuterFramePixels = 1.5;
  static const double screenCornerRatio = 0.13;
  static const Size virtualScreenshotSize = Size(1179, 2556);

  const BezelLayout({
    required this.sourceWidth,
    required this.sourceHeight,
    required this.outerCornerPixels,
    required this.screenCornerPixels,
  });

  final double sourceWidth;
  final double sourceHeight;
  final double outerCornerPixels;
  final double screenCornerPixels;

  double get outerWidth => sourceWidth + bezelPixels * 2;
  double get outerHeight => sourceHeight + bezelPixels * 2;
  double get framedOuterWidth => outerWidth + outerFramePixels * 2;
  double get framedOuterHeight => outerHeight + outerFramePixels * 2;
  double get highlightedFramedOuterWidth =>
      framedOuterWidth + highlightOuterFramePixels * 2;
  double get highlightedFramedOuterHeight =>
      framedOuterHeight + highlightOuterFramePixels * 2;
  double get outerAspectRatio => outerWidth / outerHeight;
  double get framedOuterAspectRatio => framedOuterWidth / framedOuterHeight;
  double get highlightedFramedOuterAspectRatio =>
      highlightedFramedOuterWidth / highlightedFramedOuterHeight;
  double get sourceAspectRatio => sourceWidth / sourceHeight;

  factory BezelLayout.forScreenshotSize(Size? screenshotSize) {
    final sourceSize =
        screenshotSize == null ||
            screenshotSize.width <= 0 ||
            screenshotSize.height <= 0
        ? virtualScreenshotSize
        : screenshotSize;
    final width = sourceSize.width;
    final height = sourceSize.height;
    final outerWidth = width + bezelPixels * 2;
    final outerHeight = height + bezelPixels * 2;
    final maxScreenCorner = (math.min(width, height) / 2) - 1;
    final screenCornerPx = (sourceSize.shortestSide * screenCornerRatio).clamp(
      8.0,
      maxScreenCorner,
    );
    final maxOuterCorner = (math.min(outerWidth, outerHeight) / 2) - 1;
    final outerCornerPx = (screenCornerPx + bezelPixels).clamp(
      screenCornerPx,
      maxOuterCorner,
    );

    return BezelLayout(
      sourceWidth: width,
      sourceHeight: height,
      outerCornerPixels: outerCornerPx,
      screenCornerPixels: screenCornerPx,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BezelLayout &&
        other.sourceWidth == sourceWidth &&
        other.sourceHeight == sourceHeight &&
        other.outerCornerPixels == outerCornerPixels &&
        other.screenCornerPixels == screenCornerPixels;
  }

  @override
  int get hashCode => Object.hash(
    sourceWidth,
    sourceHeight,
    outerCornerPixels,
    screenCornerPixels,
  );
}

const List<PaletteColor> kPaletteColors = [
  PaletteColor('White', Colors.white),
  PaletteColor('Black', Colors.black),
  PaletteColor('Sky', Color(0xFF0EA5E9)),
  PaletteColor('Navy', Color(0xFF1E3A8A)),
  PaletteColor('Teal', Color(0xFF0F766E)),
  PaletteColor('Green', Color(0xFF16A34A)),
  PaletteColor('Amber', Color(0xFFF59E0B)),
  PaletteColor('Rose', Color(0xFFE11D48)),
  PaletteColor('Purple', Color(0xFF7C3AED)),
  PaletteColor('Orange', Color(0xFFEA580C)),
];
