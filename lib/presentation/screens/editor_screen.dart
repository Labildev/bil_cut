import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/project_draft.dart';
import '../widgets/editor/bottom_toolbar.dart';
import '../widgets/editor/editor_header.dart';
import '../widgets/editor/player_viewport.dart';
import '../widgets/editor/timeline_shell.dart';

class EditorScreen extends StatefulWidget {
  final ProjectDraft? initialDraft;

  const EditorScreen({super.key, this.initialDraft});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late String _resolution;
  late String _aspectRatio;
  bool _isPlaying = false;
  bool _isClipSelected = false;
  Duration _currentPosition = const Duration(seconds: 4, milliseconds: 200);
  Duration _totalDuration = const Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _resolution = '1080P';
    _aspectRatio = widget.initialDraft?.aspectRatio ?? '9:16';
    if (widget.initialDraft != null) {
      _totalDuration = widget.initialDraft!.duration;
    }
  }

  void _handlePlayPauseToggle() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _handleSeek(Duration newPosition) {
    setState(() {
      _currentPosition = newPosition;
    });
  }

  void _handleAspectRatioToggle() {
    setState(() {
      if (_aspectRatio == '9:16') {
        _aspectRatio = '16:9';
      } else if (_aspectRatio == '16:9') {
        _aspectRatio = '1:1';
      } else {
        _aspectRatio = '9:16';
      }
    });
  }

  void _handleFullscreenToggle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fullscreen preview mode'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleToolSelected(EditorToolType type) {
    switch (type) {
      case EditorToolType.edit:
        setState(() {
          _isClipSelected = !_isClipSelected;
        });
        break;
      case EditorToolType.split:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Klip dibagi pada posisi playhead'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case EditorToolType.delete:
        setState(() {
          _isClipSelected = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Klip dihapus'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case EditorToolType.format:
        _handleAspectRatioToggle();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menu ${type.name} dipilih'),
            duration: const Duration(milliseconds: 800),
          ),
        );
    }
  }

  void _handleExport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Row(
            children: [
              Icon(Icons.upload, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Ekspor Video',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Video akan diekspor dengan pengaturan:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _buildExportInfoRow('Resolusi:', _resolution),
              _buildExportInfoRow('Rasio:', _aspectRatio),
              _buildExportInfoRow('Durasi:', '${_totalDuration.inSeconds} detik'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memulai render video... (Fase 7 Export Engine)'),
                    backgroundColor: AppColors.surfaceLight,
                  ),
                );
              },
              child: const Text('Mulai Ekspor'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar (Back, Undo/Redo, Resolution, Export)
            EditorHeader(
              onBack: () => Navigator.of(context).pop(),
              onUndo: () {},
              onRedo: () {},
              canUndo: true,
              canRedo: false,
              resolution: _resolution,
              onResolutionChanged: (res) {
                setState(() {
                  _resolution = res;
                });
              },
              onExport: _handleExport,
            ),

            // 2. Video Player Preview Viewport (Flexible / Aspect Ratio)
            Expanded(
              flex: 4,
              child: PlayerViewport(
                aspectRatio: _aspectRatio,
                currentPosition: _currentPosition,
                totalDuration: _totalDuration,
                isPlaying: _isPlaying,
                onPlayPauseToggle: _handlePlayPauseToggle,
                onFullscreenToggle: _handleFullscreenToggle,
                onAspectRatioToggle: _handleAspectRatioToggle,
              ),
            ),

            // 3. Timeline Shell (Ruler, Playhead, Tracks)
            Expanded(
              flex: 5,
              child: TimelineShell(
                currentPosition: _currentPosition,
                totalDuration: _totalDuration,
                isPlaying: _isPlaying,
                onPlayPauseToggle: _handlePlayPauseToggle,
                onSplit: () => _handleToolSelected(EditorToolType.split),
                onSeek: _handleSeek,
                onAddMedia: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Buka Media Picker (Fase 3 Media Import)'),
                    ),
                  );
                },
              ),
            ),

            // 4. Bottom Toolbar (CapCut Action Tools)
            BottomToolbar(
              isClipSelected: _isClipSelected,
              onToolSelected: _handleToolSelected,
            ),
          ],
        ),
      ),
    );
  }
}
