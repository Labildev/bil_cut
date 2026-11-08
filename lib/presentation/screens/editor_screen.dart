import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/project_draft.dart';
import '../../logic/timeline/timeline_notifier.dart';
import '../widgets/editor/bottom_toolbar.dart';
import '../widgets/editor/editor_header.dart';
import '../widgets/editor/player_viewport.dart';
import '../widgets/timeline/interactive_timeline.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final ProjectDraft? initialDraft;

  const EditorScreen({super.key, this.initialDraft});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialDraft != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(timelineNotifierProvider.notifier).updateAspectRatio(
              widget.initialDraft!.aspectRatio,
            );
      });
    }
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
    final notifier = ref.read(timelineNotifierProvider.notifier);

    switch (type) {
      case EditorToolType.edit:
        // Toggle selection on first video clip if none is selected
        final currentSelection = ref.read(timelineNotifierProvider).selectedClipId;
        if (currentSelection == null) {
          final mainTrack = ref.read(timelineNotifierProvider).project.mainVideoTrack;
          if (mainTrack != null && mainTrack.clips.isNotEmpty) {
            notifier.selectClip(mainTrack.clips.first.id);
          }
        } else {
          notifier.deselectClip();
        }
        break;
      case EditorToolType.split:
        final success = notifier.splitSelectedClip();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Klip dibagi pada posisi playhead'),
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pilih klip terlebih dahulu di timeline'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
      case EditorToolType.delete:
        final success = notifier.deleteSelectedClip();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Klip dihapus dari timeline'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
      case EditorToolType.format:
        final currentRatio = ref.read(timelineNotifierProvider).project.aspectRatio;
        final nextRatio = currentRatio == '9:16'
            ? '16:9'
            : currentRatio == '16:9'
                ? '1:1'
                : '9:16';
        notifier.updateAspectRatio(nextRatio);
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
    final state = ref.read(timelineNotifierProvider);

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
              const Text(
                'Video akan diekspor dengan pengaturan:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _buildExportInfoRow('Resolusi:', state.project.resolution),
              _buildExportInfoRow('Rasio:', state.project.aspectRatio),
              _buildExportInfoRow('Durasi:', '${state.totalDuration.inSeconds} detik'),
              _buildExportInfoRow('FPS:', '${state.project.fps} fps'),
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
    final state = ref.watch(timelineNotifierProvider);
    final notifier = ref.read(timelineNotifierProvider.notifier);
    final isClipSelected = state.selectedClipId != null;

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
              resolution: state.project.resolution,
              onResolutionChanged: (res) => notifier.updateResolution(res),
              onExport: _handleExport,
            ),

            // 2. Video Player Preview Viewport (Flexible / Aspect Ratio)
            Expanded(
              flex: 4,
              child: PlayerViewport(
                aspectRatio: state.project.aspectRatio,
                currentPosition: state.currentPosition,
                totalDuration: state.totalDuration,
                isPlaying: state.isPlaying,
                onPlayPauseToggle: () => notifier.togglePlayPause(),
                onFullscreenToggle: _handleFullscreenToggle,
                onAspectRatioToggle: () {
                  final nextRatio = state.project.aspectRatio == '9:16'
                      ? '16:9'
                      : state.project.aspectRatio == '16:9'
                          ? '1:1'
                          : '9:16';
                  notifier.updateAspectRatio(nextRatio);
                },
              ),
            ),

            // 3. Interactive Timeline Engine (Custom Ruler, Scrubbing, Pinch-Zoom, Tracks, Clips)
            Expanded(
              flex: 5,
              child: InteractiveTimeline(
                onAddMedia: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Buka Media Picker (Fase 3 Media Import)'),
                    ),
                  );
                },
              ),
            ),

            // 4. Bottom Toolbar (Transforms based on clip selection)
            BottomToolbar(
              isClipSelected: isClipSelected,
              onToolSelected: _handleToolSelected,
            ),
          ],
        ),
      ),
    );
  }
}
