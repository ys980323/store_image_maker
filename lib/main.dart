import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'src/image_exporter.dart';

void main() {
  runApp(const StoreImageMakerApp());
}

class StoreImageMakerApp extends StatelessWidget {
  const StoreImageMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ストアイメージ作成',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0EA5E9)),
      ),
      home: const StoreImageMakerPage(),
    );
  }
}

enum BackgroundMode { solid, gradient }

enum TitlePosition { top, bottom }

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
  static const double bezelPixels = 18.0;

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
  double get outerAspectRatio => outerWidth / outerHeight;
  double get sourceAspectRatio => sourceWidth / sourceHeight;

  static const BezelLayout fallback = BezelLayout(
    sourceWidth: 393,
    sourceHeight: 852,
    outerCornerPixels: 34,
    screenCornerPixels: 24,
  );

  factory BezelLayout.forScreenshotSize(Size? screenshotSize) {
    if (screenshotSize == null ||
        screenshotSize.width <= 0 ||
        screenshotSize.height <= 0) {
      return fallback;
    }

    final width = screenshotSize.width;
    final height = screenshotSize.height;
    final outerWidth = width + bezelPixels * 2;
    final outerHeight = height + bezelPixels * 2;
    final maxScreenCorner = (math.min(width, height) / 2) - 1;
    final screenCornerPx = (screenshotSize.shortestSide * 0.1).clamp(
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

class StoreImageMakerPage extends StatefulWidget {
  const StoreImageMakerPage({super.key});

  @override
  State<StoreImageMakerPage> createState() => _StoreImageMakerPageState();
}

class _StoreImageMakerPageState extends State<StoreImageMakerPage> {
  final TextEditingController _titleController = TextEditingController(
    text: 'あなたのアプリを、もっと魅力的に',
  );
  final GlobalKey _captureKey = GlobalKey();

  Uint8List? _screenshotBytes;
  Uint8List? _generatedBytes;
  Size? _screenshotPixelSize;

  BackgroundMode _backgroundMode = BackgroundMode.gradient;
  TitlePosition _titlePosition = TitlePosition.top;

  Color _solidColor = const Color(0xFF0EA5E9);
  Color _gradientStartColor = const Color(0xFF1E3A8A);
  Color _gradientEndColor = const Color(0xFF0EA5E9);
  Color _titleColor = Colors.white;

  double _titleFontSize = 46;
  double _phoneScale = 0.66;

  bool _isExporting = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final bytes = await _pickImageBytes();
    if (bytes == null) {
      return;
    }
    final screenshotSize = await _decodeImagePixelSize(bytes);
    if (screenshotSize == null) {
      _showSnackBar('画像サイズを取得できませんでした。PNG/JPGのスクリーンショットを選択してください。');
      return;
    }
    setState(() {
      _screenshotBytes = bytes;
      _screenshotPixelSize = screenshotSize;
      _generatedBytes = null;
    });
  }

  Future<Size?> _decodeImagePixelSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      codec.dispose();
      return size;
    } catch (_) {
      try {
        final completer = Completer<Size?>();
        ui.decodeImageFromList(bytes, (image) {
          final size = Size(image.width.toDouble(), image.height.toDouble());
          image.dispose();
          if (!completer.isCompleted) {
            completer.complete(size);
          }
        });

        return completer.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        );
      } catch (_) {
        return null;
      }
    }
  }

  Future<Uint8List?> _pickImageBytes() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return null;
      }

      final bytes = result.files.single.bytes;
      if (bytes == null) {
        _showSnackBar('画像データを読み込めませんでした。');
        return null;
      }
      return bytes;
    } catch (error) {
      _showSnackBar('画像選択に失敗しました: $error');
      return null;
    }
  }

  Future<void> _generateAndSaveImage() async {
    if (_screenshotBytes == null) {
      _showSnackBar('先にスクリーンショット画像を選択してください。');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('プレビュー領域を取得できませんでした。');
      }

      final capturePixelRatio = kStoreImageOutputWidth / boundary.size.width;
      final image = await boundary.toImage(pixelRatio: capturePixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        throw StateError('PNGデータの生成に失敗しました。');
      }

      final bytes = await _normalizeOutputResolution(
        byteData.buffer.asUint8List(),
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _generatedBytes = bytes;
      });

      try {
        final path = await savePngBytes(bytes);
        if (!mounted) {
          return;
        }
        _showSnackBar('画像を保存しました: $path');
      } on UnsupportedError catch (_) {
        _showSnackBar('PNGは生成しました。現在のプラットフォームは保存非対応です。');
      } catch (error) {
        _showSnackBar('PNGは生成しましたが、保存に失敗しました: $error');
      }
    } catch (error) {
      _showSnackBar('画像生成に失敗しました: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<Uint8List> _normalizeOutputResolution(Uint8List source) async {
    final codec = await ui.instantiateImageCodec(
      source,
      targetWidth: kStoreImageOutputWidth,
      targetHeight: kStoreImageOutputHeight,
    );
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('出力解像度の正規化に失敗しました。');
      }
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
      codec.dispose();
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  BezelLayout get _bezelLayout =>
      BezelLayout.forScreenshotSize(_screenshotPixelSize);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ストアイメージ作成')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: RepaintBoundary(
                  key: _captureKey,
                  child: AspectRatio(
                    aspectRatio: kStoreImageOutputAspectRatio,
                    child: _buildComposedPreview(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildInputCard(),
            const SizedBox(height: 12),
            _buildBackgroundCard(),
            const SizedBox(height: 12),
            _buildTitleCard(),
            const SizedBox(height: 12),
            const Text(
              '出力解像度: 1290 x 2796 px',
              style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _isExporting ? null : _generateAndSaveImage,
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? '生成中...' : 'PNGを生成して保存'),
            ),
            if (_generatedBytes != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '生成結果プレビュー',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(_generatedBytes!),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComposedPreview() {
    final decoration = _backgroundMode == BackgroundMode.solid
        ? BoxDecoration(color: _solidColor)
        : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_gradientStartColor, _gradientEndColor],
            ),
          );

    return Container(
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          children: [
            if (_titlePosition == TitlePosition.top) _buildTitleText(),
            if (_titlePosition == TitlePosition.top) const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: _phoneScale,
                  child: _buildPhonePreview(),
                ),
              ),
            ),
            if (_titlePosition == TitlePosition.bottom)
              const SizedBox(height: 24),
            if (_titlePosition == TitlePosition.bottom) _buildTitleText(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleText() {
    return Text(
      _titleController.text.trim().isEmpty
          ? 'キャッチコピーを入力してください'
          : _titleController.text,
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: _titleColor,
        fontWeight: FontWeight.w800,
        fontSize: _titleFontSize,
        height: 1.2,
      ),
    );
  }

  Widget _buildPhonePreview() {
    final bezel = _bezelLayout;

    return AspectRatio(
      aspectRatio: bezel.outerAspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            constraints.maxWidth / bezel.outerWidth,
            constraints.maxHeight / bezel.outerHeight,
          );
          final outerWidth = bezel.outerWidth * scale;
          final outerHeight = bezel.outerHeight * scale;
          final bezelWidth = BezelLayout.bezelPixels * scale;
          final outerCorner = bezel.outerCornerPixels * scale;
          final screenCorner = bezel.screenCornerPixels * scale;

          assert(() {
            final innerWidth = outerWidth - bezelWidth * 2;
            final innerHeight = outerHeight - bezelWidth * 2;
            final diff = (innerWidth / innerHeight - bezel.sourceAspectRatio)
                .abs();
            return diff < 0.001;
          }());

          return Center(
            child: SizedBox(
              width: outerWidth,
              height: outerHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF09090B),
                  borderRadius: BorderRadius.circular(outerCorner),
                ),
                child: Padding(
                  padding: EdgeInsets.all(bezelWidth),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenCorner),
                    child: _buildScreenshotLayer(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreenshotLayer() {
    if (_screenshotBytes == null) {
      return Container(
        color: const Color(0xFFE5E7EB),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'スクリーンショットを選択',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Image.memory(
      _screenshotBytes!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );
  }

  Widget _buildInputCard() {
    final scalePercent = (_phoneScale * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('素材画像', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _pickScreenshot,
                  icon: const Icon(Icons.phone_iphone),
                  label: Text(
                    _screenshotBytes == null ? 'スクリーンショット選択' : 'スクリーンショット変更',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('端末風画像サイズ: $scalePercent%'),
            Slider(
              value: _phoneScale,
              min: 0.45,
              max: 0.9,
              divisions: 45,
              label: '$scalePercent%',
              onChanged: (value) {
                setState(() {
                  _phoneScale = value;
                  _generatedBytes = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('背景', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SegmentedButton<BackgroundMode>(
              segments: const [
                ButtonSegment(
                  value: BackgroundMode.solid,
                  label: Text('単色'),
                  icon: Icon(Icons.crop_square),
                ),
                ButtonSegment(
                  value: BackgroundMode.gradient,
                  label: Text('グラデーション'),
                  icon: Icon(Icons.gradient),
                ),
              ],
              selected: {_backgroundMode},
              onSelectionChanged: (selection) {
                setState(() {
                  _backgroundMode = selection.first;
                  _generatedBytes = null;
                });
              },
            ),
            const SizedBox(height: 10),
            if (_backgroundMode == BackgroundMode.solid) ...[
              const Text('背景色'),
              const SizedBox(height: 6),
              _buildPalette(
                selectedColor: _solidColor,
                onSelected: (value) {
                  setState(() {
                    _solidColor = value;
                    _generatedBytes = null;
                  });
                },
              ),
            ] else ...[
              const Text('開始色'),
              const SizedBox(height: 6),
              _buildPalette(
                selectedColor: _gradientStartColor,
                onSelected: (value) {
                  setState(() {
                    _gradientStartColor = value;
                    _generatedBytes = null;
                  });
                },
              ),
              const SizedBox(height: 8),
              const Text('終了色'),
              const SizedBox(height: 6),
              _buildPalette(
                selectedColor: _gradientEndColor,
                onSelected: (value) {
                  setState(() {
                    _gradientEndColor = value;
                    _generatedBytes = null;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('文字', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '任意のキャッチコピーを入力',
              ),
              onChanged: (_) {
                setState(() {
                  _generatedBytes = null;
                });
              },
            ),
            const SizedBox(height: 10),
            const Text('文字色'),
            const SizedBox(height: 6),
            _buildPalette(
              selectedColor: _titleColor,
              onSelected: (value) {
                setState(() {
                  _titleColor = value;
                  _generatedBytes = null;
                });
              },
            ),
            const SizedBox(height: 10),
            Text('フォントサイズ: ${_titleFontSize.toStringAsFixed(0)}'),
            Slider(
              value: _titleFontSize,
              min: 20,
              max: 64,
              divisions: 44,
              label: _titleFontSize.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _titleFontSize = value;
                  _generatedBytes = null;
                });
              },
            ),
            const SizedBox(height: 8),
            SegmentedButton<TitlePosition>(
              segments: const [
                ButtonSegment(
                  value: TitlePosition.top,
                  label: Text('上部'),
                  icon: Icon(Icons.vertical_align_top),
                ),
                ButtonSegment(
                  value: TitlePosition.bottom,
                  label: Text('下部'),
                  icon: Icon(Icons.vertical_align_bottom),
                ),
              ],
              selected: {_titlePosition},
              onSelectionChanged: (selection) {
                setState(() {
                  _titlePosition = selection.first;
                  _generatedBytes = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPalette({
    required Color selectedColor,
    required ValueChanged<Color> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kPaletteColors
          .map(
            (item) => ChoiceChip(
              selected: selectedColor.toARGB32() == item.color.toARGB32(),
              label: Text(item.name),
              avatar: CircleAvatar(backgroundColor: item.color),
              onSelected: (_) => onSelected(item.color),
            ),
          )
          .toList(growable: false),
    );
  }
}
