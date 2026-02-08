import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../image_exporter.dart';
import '../models/store_image_models.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ストアイメージ作成'),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLowest,
              const Color(0xFFE9F2FB),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideLayout = constraints.maxWidth >= 1080;

              final controls = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputCard(),
                  const SizedBox(height: 12),
                  _buildBackgroundCard(),
                  const SizedBox(height: 12),
                  _buildTitleCard(),
                  const SizedBox(height: 12),
                  _buildExportCard(),
                ],
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: isWideLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: _buildPreviewPanel()),
                          const SizedBox(width: 16),
                          Expanded(flex: 5, child: controls),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPreviewPanel(),
                          const SizedBox(height: 12),
                          controls,
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return _buildPanel(
      icon: Icons.auto_awesome_rounded,
      title: 'ライブプレビュー',
      subtitle: '設定変更はリアルタイム反映されます',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: RepaintBoundary(
                key: _captureKey,
                child: AspectRatio(
                  aspectRatio: kStoreImageOutputAspectRatio,
                  child: _buildComposedPreview(),
                ),
              ),
            ),
          ),
          if (_generatedBytes != null) ...[
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '生成結果',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(_generatedBytes!),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportCard() {
    return _buildPanel(
      icon: Icons.download_rounded,
      title: '書き出し',
      subtitle: 'PNGを生成し、端末へ保存します',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.55),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '出力解像度は 1290 x 2796 px に固定されています',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _isExporting ? null : _generateAndSaveImage,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isExporting ? '生成中...' : 'PNGを生成して保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surface.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
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

    return DecoratedBox(
      decoration: decoration,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Column(
              children: [
                if (_titlePosition == TitlePosition.top) _buildTitleText(),
                if (_titlePosition == TitlePosition.top)
                  const SizedBox(height: 24),
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
        ],
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
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
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
      final colorScheme = Theme.of(context).colorScheme;

      return DecoratedBox(
        decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 36,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Text(
                  'スクリーンショットを選択',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
    final hasScreenshot = _screenshotBytes != null;

    return _buildPanel(
      icon: Icons.image_search_rounded,
      title: '素材画像',
      subtitle: 'アプリのスクリーンショットを取り込みます',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.tonalIcon(
            onPressed: _pickScreenshot,
            icon: const Icon(Icons.phone_iphone),
            label: Text(hasScreenshot ? 'スクリーンショット変更' : 'スクリーンショット選択'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  hasScreenshot
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: hasScreenshot
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasScreenshot ? '素材読み込み済み' : 'まず素材画像を選択してください',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
    );
  }

  Widget _buildBackgroundCard() {
    return _buildPanel(
      icon: Icons.palette_outlined,
      title: '背景',
      subtitle: 'ストアイメージの背景をカスタマイズします',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 12),
          if (_backgroundMode == BackgroundMode.solid) ...[
            const Text('背景色', style: TextStyle(fontWeight: FontWeight.w600)),
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
            const Text('開始色', style: TextStyle(fontWeight: FontWeight.w600)),
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
            const SizedBox(height: 10),
            const Text('終了色', style: TextStyle(fontWeight: FontWeight.w600)),
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
    );
  }

  Widget _buildTitleCard() {
    return _buildPanel(
      icon: Icons.text_fields_rounded,
      title: '文字',
      subtitle: 'キャッチコピーの見た目を調整します',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: '任意のキャッチコピーを入力'),
            onChanged: (_) {
              setState(() {
                _generatedBytes = null;
              });
            },
          ),
          const SizedBox(height: 12),
          const Text('文字色', style: TextStyle(fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 10),
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
    );
  }

  Widget _buildPalette({
    required Color selectedColor,
    required ValueChanged<Color> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kPaletteColors
          .map(
            (item) => ChoiceChip(
              selected: selectedColor.toARGB32() == item.color.toARGB32(),
              showCheckmark: false,
              side: BorderSide(color: colorScheme.outlineVariant),
              selectedColor: colorScheme.secondaryContainer,
              backgroundColor: colorScheme.surfaceContainerLowest,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(item.name),
                ],
              ),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              onSelected: (_) => onSelected(item.color),
            ),
          )
          .toList(growable: false),
    );
  }
}
