import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/media_picker_service.dart';
import '../../data/models/project_draft.dart';
import '../../data/models/timeline_project.dart';
import '../../logic/player/video_playback_manager.dart';
import '../../logic/timeline/timeline_notifier.dart';
import '../widgets/editor/bottom_toolbar.dart';
import '../widgets/editor/editor_header.dart';
import '../widgets/editor/modals/speed_control_sheet.dart';
import '../widgets/editor/modals/volume_control_sheet.dart';
import '../widgets/editor/player_viewport.dart';
import '../widgets/timeline/interactive_timeline.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final ProjectDraft? initialDraft;
  final TimelineProject? initialProject;

  const EditorScreen({
    super.key,
    this.initialDraft,
    this.initialProject,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late final VideoPlaybackManager _playbackManager;
  late final MediaPickerService _mediaPicker;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _playbackManager = VideoPlaybackManager();
    _mediaPicker = MediaPickerService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialProject != null) {
        ref.read(timelineNotifierProvider.notifier).loadProject(widget.initialProject!);
      } else if (widget.initialDraft != null) {
        ref.read(timelineNotifierProvider.notifier).updateAspectRatio(
              widget.initialDraft!.aspectRatio,
            );
      }

      // Initial sync with player
      final state = ref.read(timelineNotifierProvider);
      _playbackManager.syncWithTimeline(
        timelinePosition: state.currentPosition,
        project: state.project,
        isPlaying: state.isPlaying,
      );
    });

    _startPlaybackTimer();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _playbackManager.dispose();
    super.dispose();
  }

  void _startPlaybackTimer() {
    const tickInterval = Duration(milliseconds: 33); // ~30 FPS
    _playbackTimer = Timer.periodic(tickInterval, (_) {
      final state = ref.read(timelineNotifierProvider);
      if (state.isPlaying && !state.isScrubbing) {
        final nextPosition = state.currentPosition + tickInterval;
        if (nextPosition >= state.totalDuration) {
          ref.read(timelineNotifierProvider.notifier).pause();
          ref.read(timelineNotifierProvider.notifier).seekTo(Duration.zero);
        } else {
          ref.read(timelineNotifierProvider.notifier).seekTo(nextPosition);
        }
      }
    });
  }

  void _syncPlayerWithState() {
    final state = ref.read(timelineNotifierProvider);
    _playbackManager.syncWithTimeline(
      timelinePosition: state.currentPosition,
      project: state.project,
      isPlaying: state.isPlaying,
    );
  }

  Future<void> _handleAddMedia() async {
    final files = await _mediaPicker.pickMultipleVideos();
    if (!mounted || files.isEmpty) return;

    final newClips = files.map((file) {
      return _mediaPicker.createClipFromXFile(
        file: file,
        trackId: 'track-main-video',
        timelineStart: Duration.zero,
      );
    }).toList();

    ref.read(timelineNotifierProvider.notifier).appendClipsToMainTrack(newClips);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newClips.length} klip video ditambahkan ke track'),
        duration: const Duration(seconds: 2),
      ),
    );
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
      case EditorToolType.speed:
        final clip = ref.read(timelineNotifierProvider).selectedClip;
        if (clip != null) {
          SpeedControlSheet.show(
            context: context,
            clip: clip,
            onSpeedChanged: (speed) => notifier.setClipSpeed(clip.id, speed),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pilih klip terlebih dahulu untuk mengatur kecepatan'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
      case EditorToolType.volume:
        final clip = ref.read(timelineNotifierProvider).selectedClip;
        if (clip != null) {
          VolumeControlSheet.show(
            context: context,
            clip: clip,
            onVolumeChanged: (volume) => notifier.setClipVolume(clip.id, volume),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pilih klip terlebih dahulu untuk mengatur volume'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
      case EditorToolType.duplicate:
        final success = notifier.duplicateSelectedClip();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Klip berhasil disalin'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
      case EditorToolType.rotate:
        final success = notifier.rotateSelectedClip();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Klip diputar 90°'),
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

    // Listen to changes to sync the video player engine
    ref.listen(
      timelineNotifierProvider,
      (prev, next) {
        if (prev?.currentPosition != next.currentPosition ||
            prev?.isPlaying != next.isPlaying ||
            prev?.project != next.project) {
          _syncPlayerWithState();
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar (Back, Undo/Redo, Resolution, Export)
            EditorHeader(
              onBack: () => Navigator.of(context).pop(),
              onUndo: state.canUndo ? () => notifier.undo() : null,
              onRedo: state.canRedo ? () => notifier.redo() : null,
              canUndo: state.canUndo,
              canRedo: state.canRedo,
              resolution: state.project.resolution,
              onResolutionChanged: (res) => notifier.updateResolution(res),
              onExport: _handleExport,
            ),

            // 2. Video Player Preview Viewport (Live Video Player)
            Expanded(
              flex: 4,
              child: ValueListenableBuilder<VideoPlayerController?>(
                valueListenable: _playbackManager.controllerNotifier,
                builder: (context, controller, child) {
                  return PlayerViewport(
                    aspectRatio: state.project.aspectRatio,
                    currentPosition: state.currentPosition,
                    totalDuration: state.totalDuration,
                    isPlaying: state.isPlaying,
                    videoController: controller,
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
                  );
                },
              ),
            ),

            // 3. Interactive Timeline Engine (Custom Ruler, Scrubbing, Pinch-Zoom, Tracks, Clips)
            Expanded(
              flex: 5,
              child: InteractiveTimeline(
                onAddMedia: _handleAddMedia,
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
