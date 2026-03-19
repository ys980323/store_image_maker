import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../image_exporter.dart';
import '../models/store_image_models.dart';
import '../services/preset_repository.dart';
import '../widgets/admob_bottom_banner.dart';
import '../widgets/admob_interstitial.dart';

enum _AppMenuAction { privacyPolicy, termsOfService, review }

class StoreImageMakerPage extends StatefulWidget {
  const StoreImageMakerPage({super.key});

  @override
  State<StoreImageMakerPage> createState() => _StoreImageMakerPageState();
}

class _StoreImageMakerPageState extends State<StoreImageMakerPage> {
  final TextEditingController _titleController = TextEditingController(
    text: 'あなたのアプリを、もっと魅力的に',
  );
  final TextEditingController _subtitleController = TextEditingController();
  final GlobalKey _captureKey = GlobalKey();

  Uint8List? _screenshotBytes;
  Uint8List? _generatedBytes;
  Size? _screenshotPixelSize;

  BackgroundMode _backgroundMode = BackgroundMode.gradient;
  TitlePosition _titlePosition = TitlePosition.top;
  TitleAlignment _titleAlignment = TitleAlignment.center;

  Color _solidColor = const Color(0xFF0EA5E9);
  Color _gradientStartColor = const Color(0xFF1E3A8A);
  Color _gradientEndColor = const Color(0xFF0EA5E9);
  Color _titleColor = Colors.white;
  Color _subtitleColor = Colors.white;

  double _titleFontSize = 46;
  double _subtitleFontSize = 20;
  double _titleLineHeight = 1.2;
  double _titleLetterSpacing = 0;
  double _subtitleLineHeight = 1.4;
  double _subtitleLetterSpacing = 0;
  double _phoneScale = 0.66;
  bool _showDynamicIsland = false;
  double _dynamicIslandScale = 1.0;

  bool _isExporting = false;

  final AdMobInterstitial _interstitialAd = AdMobInterstitial();
  final PresetRepository _presetRepository = PresetRepository();
  List<Preset> _presets = [];

  @override
  void initState() {
    super.initState();
    _interstitialAd.loadAd();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await _presetRepository.loadAll();
    if (mounted) {
      setState(() {
        _presets = presets;
      });
    }
  }

  Preset _createPresetFromCurrentState(String name) {
    return Preset(
      name: name,
      backgroundMode: _backgroundMode,
      titlePosition: _titlePosition,
      titleAlignment: _titleAlignment,
      solidColor: _solidColor,
      gradientStartColor: _gradientStartColor,
      gradientEndColor: _gradientEndColor,
      titleColor: _titleColor,
      titleFontSize: _titleFontSize,
      phoneScale: _phoneScale,
      showDynamicIsland: _showDynamicIsland,
      dynamicIslandScale: _dynamicIslandScale,
      titleText: _titleController.text,
      subtitleText: _subtitleController.text,
      subtitleFontSize: _subtitleFontSize,
      subtitleColor: _subtitleColor,
      titleLineHeight: _titleLineHeight,
      titleLetterSpacing: _titleLetterSpacing,
      subtitleLineHeight: _subtitleLineHeight,
      subtitleLetterSpacing: _subtitleLetterSpacing,
    );
  }

  void _applyPreset(Preset preset) {
    setState(() {
      _backgroundMode = preset.backgroundMode;
      _titlePosition = preset.titlePosition;
      _titleAlignment = preset.titleAlignment;
      _solidColor = preset.solidColor;
      _gradientStartColor = preset.gradientStartColor;
      _gradientEndColor = preset.gradientEndColor;
      _titleColor = preset.titleColor;
      _titleFontSize = preset.titleFontSize;
      _phoneScale = preset.phoneScale;
      _showDynamicIsland = preset.showDynamicIsland;
      _dynamicIslandScale = preset.dynamicIslandScale;
      _titleController.text = preset.titleText;
      _subtitleController.text = preset.subtitleText;
      _subtitleFontSize = preset.subtitleFontSize;
      _subtitleColor = preset.subtitleColor;
      _titleLineHeight = preset.titleLineHeight;
      _titleLetterSpacing = preset.titleLetterSpacing;
      _subtitleLineHeight = preset.subtitleLineHeight;
      _subtitleLetterSpacing = preset.subtitleLetterSpacing;
      _generatedBytes = null;
    });
  }

  Future<void> _savePreset() async {
    final name = await _showPresetNameDialog();
    if (name == null || name.trim().isEmpty) return;

    final preset = _createPresetFromCurrentState(name.trim());
    await _presetRepository.add(preset);
    await _loadPresets();
    if (mounted) {
      _showSnackBar('プリセット「$name」を保存しました');
    }
  }

  Future<void> _deletePreset(int index) async {
    final name = _presets[index].name;
    await _presetRepository.deleteAt(index);
    await _loadPresets();
    if (mounted) {
      _showSnackBar('プリセット「$name」を削除しました');
    }
  }

  Future<String?> _showPresetNameDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('プリセット名'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'プリセット名を入力'),
            onSubmitted: (value) =>
                Navigator.of(dialogContext).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  @override
  void dispose() {
    _interstitialAd.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
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
        _interstitialAd.onImageSaved();
        _requestReviewIfNeeded();
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

  Future<Uint8List> _capturePreviewBytes() async {
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

    return _normalizeOutputResolution(byteData.buffer.asUint8List());
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onMenuAction(_AppMenuAction action) async {
    if (action == _AppMenuAction.review) {
      await _openAppReview();
      return;
    }
    final uri = switch (action) {
      _AppMenuAction.privacyPolicy => Uri.parse(
        'https://homepage-5021a.web.app/privacy-policy.html',
      ),
      _AppMenuAction.termsOfService => Uri.parse(
        'https://homepage-5021a.web.app/terms-of-service.html',
      ),
      _AppMenuAction.review => throw StateError('unreachable'),
    };
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showSnackBar('ページを開けませんでした。');
    }
  }

  Future<void> _openAppReview() async {
    final launched = await launchUrl(
      Uri.parse(
        'https://apps.apple.com/jp/app/id6759444148?action=write-review',
      ),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      _showSnackBar('ページを開けませんでした。');
    }
  }

  Future<void> _requestReviewIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final saveCount = (prefs.getInt('review_save_count') ?? 0) + 1;
    await prefs.setInt('review_save_count', saveCount);

    // 5回保存ごとにレビューを促す（ただし最大3回まで）
    final reviewCount = prefs.getInt('review_prompt_count') ?? 0;
    if (saveCount % 5 == 0 && reviewCount < 3) {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        await prefs.setInt('review_prompt_count', reviewCount + 1);
      }
    }
  }

  BezelLayout get _bezelLayout =>
      BezelLayout.forScreenshotSize(_screenshotPixelSize);

  TextAlign get _titleTextAlign {
    switch (_titleAlignment) {
      case TitleAlignment.left:
        return TextAlign.left;
      case TitleAlignment.center:
        return TextAlign.center;
      case TitleAlignment.right:
        return TextAlign.right;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ストアイメージ作成'),
        actions: [
          PopupMenuButton<_AppMenuAction>(
            icon: const Icon(Icons.menu),
            onSelected: _onMenuAction,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _AppMenuAction.privacyPolicy,
                child: Text('プライバシーポリシー'),
              ),
              PopupMenuItem(
                value: _AppMenuAction.termsOfService,
                child: Text('利用規約'),
              ),
              PopupMenuItem(
                value: _AppMenuAction.review,
                child: Text('アプリを評価する'),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AdMobBottomBanner(),
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
                  _buildPresetCard(),
                  const SizedBox(height: 12),
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

  Widget _buildPresetCard() {
    return _buildPanel(
      icon: Icons.bookmarks_rounded,
      title: 'プリセット',
      subtitle: '設定を保存・読み込みできます',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.tonalIcon(
            onPressed: _savePreset,
            icon: const Icon(Icons.save_rounded),
            label: const Text('現在の設定をプリセットとして保存'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          if (_presets.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              '保存済みプリセット',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...List.generate(_presets.length, (index) {
              final preset = _presets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant,
                      ),
                    ),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: preset.backgroundMode ==
                                BackgroundMode.gradient
                            ? LinearGradient(
                                colors: [
                                  preset.gradientStartColor,
                                  preset.gradientEndColor,
                                ],
                              )
                            : null,
                        color: preset.backgroundMode ==
                                BackgroundMode.solid
                            ? preset.solidColor
                            : null,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    title: Text(
                      preset.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: '削除',
                      onPressed: () => _deletePreset(index),
                    ),
                    onTap: () {
                      _applyPreset(preset);
                      _showSnackBar(
                        'プリセット「${preset.name}」を適用しました',
                      );
                    },
                  ),
                ),
              );
            }),
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
                    '出力解像度は 1242 x 2688 px に固定されています',
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
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackgroundLayer(),
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
    );
  }

  Widget _buildBackgroundLayer() {
    switch (_backgroundMode) {
      case BackgroundMode.solid:
        return ColoredBox(color: _solidColor);
      case BackgroundMode.gradient:
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_gradientStartColor, _gradientEndColor],
            ),
          ),
        );
    }
  }

  Widget _buildTitleText() {
    final hasSubtitle = _subtitleController.text.trim().isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: switch (_titleAlignment) {
          TitleAlignment.left => CrossAxisAlignment.start,
          TitleAlignment.center => CrossAxisAlignment.center,
          TitleAlignment.right => CrossAxisAlignment.end,
        },
        children: [
          Text(
            _titleController.text.trim().isEmpty
                ? 'キャッチコピーを入力してください'
                : _titleController.text,
            textAlign: _titleTextAlign,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _titleColor,
              fontWeight: FontWeight.w800,
              fontSize: _titleFontSize,
              height: _titleLineHeight,
              letterSpacing: _titleLetterSpacing,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          if (hasSubtitle) ...[
            const SizedBox(height: 8),
            Text(
              _subtitleController.text,
              textAlign: _titleTextAlign,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _subtitleColor,
                fontWeight: FontWeight.w500,
                fontSize: _subtitleFontSize,
                height: _subtitleLineHeight,
                letterSpacing: _subtitleLetterSpacing,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhonePreview() {
    final bezel = _bezelLayout;

    return AspectRatio(
      aspectRatio: bezel.withButtonsOuterAspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            constraints.maxWidth / bezel.withButtonsOuterWidth,
            constraints.maxHeight / bezel.withButtonsOuterHeight,
          );
          final highlightFrameWidth =
              BezelLayout.highlightOuterFramePixels * scale;
          final sideButtonGap = BezelLayout.sideButtonGapPixels * scale;
          final volumeButtonWidth = BezelLayout.volumeButtonWidthPixels * scale;
          final powerButtonWidth = BezelLayout.powerButtonWidthPixels * scale;
          final sideButtonOutset = BezelLayout.sideButtonOutsetPixels * scale;
          final frameWidth = BezelLayout.outerFramePixels * scale;
          final frameLeft = volumeButtonWidth + sideButtonGap;
          final frameTop = sideButtonOutset;
          final withButtonsOuterWidth = bezel.withButtonsOuterWidth * scale;
          final highlightedFramedOuterWidth =
              bezel.highlightedFramedOuterWidth * scale;
          final highlightedFramedOuterHeight =
              bezel.highlightedFramedOuterHeight * scale;
          final withButtonsOuterHeight = bezel.withButtonsOuterHeight * scale;
          final framedOuterWidth = bezel.framedOuterWidth * scale;
          final framedOuterHeight = bezel.framedOuterHeight * scale;
          final outerWidth = bezel.outerWidth * scale;
          final outerHeight = bezel.outerHeight * scale;
          final bezelWidth = BezelLayout.bezelPixels * scale;
          final outerCorner = bezel.outerCornerPixels * scale;
          final framedOuterCorner = outerCorner + frameWidth;
          final highlightedFramedOuterCorner =
              framedOuterCorner + highlightFrameWidth;
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
              width: withButtonsOuterWidth,
              height: withButtonsOuterHeight,
              child: Stack(
                children: [
                  Positioned(
                    left: frameLeft,
                    top: frameTop,
                    child: SizedBox(
                      width: highlightedFramedOuterWidth,
                      height: highlightedFramedOuterHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const ui.Color.fromARGB(255, 188, 191, 196),
                          borderRadius: BorderRadius.circular(
                            highlightedFramedOuterCorner,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(highlightFrameWidth),
                          child: SizedBox(
                            width: framedOuterWidth,
                            height: framedOuterHeight,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const ui.Color.fromARGB(255, 59, 60, 62),
                                borderRadius: BorderRadius.circular(
                                  framedOuterCorner,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(frameWidth),
                                child: SizedBox(
                                  width: outerWidth,
                                  height: outerHeight,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF09090B),
                                      borderRadius: BorderRadius.circular(
                                        outerCorner,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(bezelWidth),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          screenCorner,
                                        ),
                                        child: _buildScreenLayer(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildSideButton(
                    left: frameLeft - sideButtonGap - volumeButtonWidth,
                    top: withButtonsOuterHeight * 0.26,
                    width: volumeButtonWidth,
                    height: withButtonsOuterHeight * 0.08,
                  ),
                  _buildSideButton(
                    left: frameLeft - sideButtonGap - volumeButtonWidth,
                    top: withButtonsOuterHeight * 0.36,
                    width: volumeButtonWidth,
                    height: withButtonsOuterHeight * 0.08,
                  ),
                  _buildSideButton(
                    left:
                        frameLeft + highlightedFramedOuterWidth + sideButtonGap,
                    top: withButtonsOuterHeight * 0.33,
                    width: powerButtonWidth,
                    height: withButtonsOuterHeight * 0.12,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSideButton({
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: math.max(2.0, width),
          height: math.max(8.0, height),
          decoration: BoxDecoration(
            color: const ui.Color.fromARGB(255, 52, 54, 57),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
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

  Widget _buildScreenLayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseIslandWidth = math.min(
          constraints.maxWidth * 0.6,
          math.max(56.0, constraints.maxWidth * 0.28),
        );
        final baseIslandHeight = math.min(
          28.0,
          math.max(18.0, constraints.maxHeight * 0.03),
        );
        final islandWidth = baseIslandWidth * _dynamicIslandScale;
        final islandHeight = baseIslandHeight * _dynamicIslandScale;
        final islandTopOffset = math.min(
          8.0,
          math.max(6.0, constraints.maxHeight * 0.01),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            _buildScreenshotLayer(),
            if (_showDynamicIsland)
              Positioned(
                top: islandTopOffset,
                left: (constraints.maxWidth - islandWidth) / 2,
                child: IgnorePointer(
                  child: Container(
                    width: islandWidth,
                    height: islandHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF050506),
                      borderRadius: BorderRadius.circular(islandHeight / 2),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              '仮想ノッチ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('スクショ上に仮想ノッチを重ねて表示'),
            value: _showDynamicIsland,
            onChanged: (value) {
              setState(() {
                _showDynamicIsland = value;
                _generatedBytes = null;
              });
            },
          ),
          const SizedBox(height: 4),
          Text('仮想ノッチサイズ: ${(_dynamicIslandScale * 100).round()}%'),
          Slider(
            value: _dynamicIslandScale,
            min: 0.7,
            max: 1.4,
            divisions: 28,
            label: '${(_dynamicIslandScale * 100).round()}%',
            onChanged: _showDynamicIsland
                ? (value) {
                    setState(() {
                      _dynamicIslandScale = value;
                      _generatedBytes = null;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 4),
          Text('端末画像サイズ: $scalePercent%'),
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
          ] else if (_backgroundMode == BackgroundMode.gradient) ...[
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
          const SizedBox(height: 10),
          _buildPreviewPopupButton(),
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
          const Text('タイトル', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(hintText: 'タイトルを入力'),
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
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
          Text('行間: ${_titleLineHeight.toStringAsFixed(1)}'),
          Slider(
            value: _titleLineHeight,
            min: 0.8,
            max: 3.0,
            divisions: 22,
            label: _titleLineHeight.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _titleLineHeight = value;
                _generatedBytes = null;
              });
            },
          ),
          Text('文字間隔: ${_titleLetterSpacing.toStringAsFixed(1)}'),
          Slider(
            value: _titleLetterSpacing,
            min: -2,
            max: 20,
            divisions: 22,
            label: _titleLetterSpacing.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _titleLetterSpacing = value;
                _generatedBytes = null;
              });
            },
          ),
          const Divider(height: 24),
          const Text('サブテキスト',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _subtitleController,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            decoration:
                const InputDecoration(hintText: 'サブテキストを入力（任意）'),
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onChanged: (_) {
              setState(() {
                _generatedBytes = null;
              });
            },
          ),
          const SizedBox(height: 12),
          const Text('サブテキスト文字色',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _buildPalette(
            selectedColor: _subtitleColor,
            onSelected: (value) {
              setState(() {
                _subtitleColor = value;
                _generatedBytes = null;
              });
            },
          ),
          const SizedBox(height: 12),
          Text('フォントサイズ: ${_subtitleFontSize.toStringAsFixed(0)}'),
          Slider(
            value: _subtitleFontSize,
            min: 12,
            max: 48,
            divisions: 36,
            label: _subtitleFontSize.toStringAsFixed(0),
            onChanged: (value) {
              setState(() {
                _subtitleFontSize = value;
                _generatedBytes = null;
              });
            },
          ),
          Text('行間: ${_subtitleLineHeight.toStringAsFixed(1)}'),
          Slider(
            value: _subtitleLineHeight,
            min: 0.8,
            max: 3.0,
            divisions: 22,
            label: _subtitleLineHeight.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _subtitleLineHeight = value;
                _generatedBytes = null;
              });
            },
          ),
          Text('文字間隔: ${_subtitleLetterSpacing.toStringAsFixed(1)}'),
          Slider(
            value: _subtitleLetterSpacing,
            min: -2,
            max: 20,
            divisions: 22,
            label: _subtitleLetterSpacing.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _subtitleLetterSpacing = value;
                _generatedBytes = null;
              });
            },
          ),
          const Divider(height: 24),
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
          const SizedBox(height: 10),
          SegmentedButton<TitleAlignment>(
            segments: const [
              ButtonSegment(
                value: TitleAlignment.left,
                label: Text('左寄せ'),
                icon: Icon(Icons.format_align_left),
              ),
              ButtonSegment(
                value: TitleAlignment.center,
                label: Text('中央'),
                icon: Icon(Icons.format_align_center),
              ),
              ButtonSegment(
                value: TitleAlignment.right,
                label: Text('右寄せ'),
                icon: Icon(Icons.format_align_right),
              ),
            ],
            selected: {_titleAlignment},
            onSelectionChanged: (selection) {
              setState(() {
                _titleAlignment = selection.first;
                _generatedBytes = null;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildPreviewPopupButton(),
        ],
      ),
    );
  }

  Widget _buildPreviewPopupButton() {
    return OutlinedButton.icon(
      onPressed: _showPreviewDialog,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.preview_rounded),
      label: const Text('プレビュー表示'),
    );
  }

  Future<void> _showPreviewDialog() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final previewFuture = _capturePreviewBytes();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final maxPreviewHeight = math.min(
          MediaQuery.sizeOf(dialogContext).height * 0.68,
          680.0,
        );

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'プレビュー',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: '閉じる',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: maxPreviewHeight,
                  child: FutureBuilder<Uint8List>(
                    future: previewFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(
                          child: Text(
                            'プレビューの生成に失敗しました',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      return Center(
                        child: AspectRatio(
                          aspectRatio: kStoreImageOutputAspectRatio,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPalette({
    required Color selectedColor,
    required ValueChanged<Color> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCustomColor = !kPaletteColors.any(
      (item) => selectedColor.toARGB32() == item.color.toARGB32(),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...kPaletteColors.map(
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
        ),
        ChoiceChip(
          selected: isCustomColor,
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
                  color: selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.14),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text('カスタム'),
            ],
          ),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          onSelected: (_) {
            _pickCustomColor(
              initialColor: selectedColor,
              onSelected: onSelected,
            );
          },
        ),
      ],
    );
  }

  Future<void> _pickCustomColor({
    required Color initialColor,
    required ValueChanged<Color> onSelected,
  }) async {
    final color = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        final argb = initialColor.toARGB32();
        double red = ((argb >> 16) & 0xFF).toDouble();
        double green = ((argb >> 8) & 0xFF).toDouble();
        double blue = (argb & 0xFF).toDouble();

        Color currentColor() =>
            Color.fromARGB(255, red.round(), green.round(), blue.round());

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final previewColor = currentColor();

            return AlertDialog(
              title: const Text('カスタムカラー'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: previewColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        _toHexRgb(previewColor),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildRgbSlider(
                      label: 'R',
                      value: red,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setDialogState(() {
                          red = value;
                        });
                      },
                    ),
                    _buildRgbSlider(
                      label: 'G',
                      value: green,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setDialogState(() {
                          green = value;
                        });
                      },
                    ),
                    _buildRgbSlider(
                      label: 'B',
                      value: blue,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setDialogState(() {
                          blue = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('キャンセル'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(currentColor());
                  },
                  child: const Text('適用'),
                ),
              ],
            );
          },
        );
      },
    );

    if (color == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    onSelected(color);
  }

  Widget _buildRgbSlider({
    required String label,
    required double value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            divisions: 255,
            activeColor: activeColor,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            value.round().toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFeatures: [ui.FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  String _toHexRgb(Color color) {
    final hex = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${hex.substring(2).toUpperCase()}';
  }
}
