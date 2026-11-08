import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/media_picker_service.dart';
import '../../data/models/project_draft.dart';
import '../../data/models/timeline_clip.dart';
import '../../data/models/timeline_project.dart';
import '../../logic/player/video_playback_manager.dart';
import '../../logic/timeline/timeline_notifier.dart';
import '../widgets/editor/bottom_toolbar.dart';
import '../widgets/editor/editor_header.dart';
import '../widgets/editor/modals/animation_selector_sheet.dart';
import '../widgets/editor/modals/export_settings_sheet.dart';
import '../widgets/editor/modals/filter_adjustment_sheet.dart';
import '../widgets/editor/modals/format_selector_sheet.dart';
import '../widgets/editor/modals/speed_control_sheet.dart';
import '../widgets/editor/modals/text_editor_sheet.dart';
import '../widgets/editor/modals/transition_selector_sheet.dart';
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

class _EditorScreenState extends ConsumerState<EditorScreen> with WidgetsBindingObserver {
  late final VideoPlaybackManager _playbackManager;
  late final MediaPickerService _mediaPicker;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Lock to portrait orientation inside the editor screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
    WidgetsBinding.instance.removeObserver(this);
    // Reset orientations when exiting editor
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _playbackTimer?.cancel();
    _playbackManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Pause playback and release decoder activity when app is minimized or interrupted
      ref.read(timelineNotifierProvider.notifier).pause();
      _playbackManager.syncWithTimeline(
        timelinePosition: ref.read(timelineNotifierProvider).currentPosition,
        project: ref.read(timelineNotifierProvider).project,
        isPlaying: false,
      );
    }
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

  Future<void> _handlePickAudio(TimelineNotifier notifier) async {
    final file = await _mediaPicker.pickVideo();
    if (!mounted) return;

    if (file != null) {
      notifier.addAudioClip(
        name: file.name,
        path: file.path,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio "${file.name}" ditambahkan ke track musik'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      notifier.addAudioClip(
        name: 'Chill_Lofi_Beat.mp3',
        path: 'assets/audio/demo.mp3',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio BGM ditambahkan ke track musik'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _handlePickOverlay(TimelineNotifier notifier) async {
    final file = await _mediaPicker.pickVideo();
    if (!mounted) return;

    if (file != null) {
      notifier.addOverlayClip(
        name: file.name,
        path: file.path,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Overlay PIP "${file.name}" ditambahkan'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      notifier.addOverlayClip(
        name: 'PIP_Overlay_Demo.mp4',
        path: '',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Overlay PIP ditambahkan di atas video'),
          duration: Duration(seconds: 1),
        ),
      );
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
      case EditorToolType.text:
        final selectedClip = ref.read(timelineNotifierProvider).selectedClip;
        final isTextSelected = selectedClip != null && selectedClip.type == ClipType.text;

        TextEditorSheet.show(
          context: context,
          initialClip: isTextSelected ? selectedClip : null,
          onSave: ({
            required String text,
            required String font,
            required int color,
            required int? backgroundColor,
            required bool hasShadow,
          }) {
            if (isTextSelected) {
              notifier.updateTextClip(
                clipId: selectedClip.id,
                text: text,
                font: font,
                color: color,
                backgroundColor: backgroundColor,
                hasShadow: hasShadow,
              );
            } else {
              notifier.addTextClip(
                text: text,
                font: font,
                color: color,
                backgroundColor: backgroundColor,
                hasShadow: hasShadow,
              );
            }
          },
        );
        break;
      case EditorToolType.audio:
        _handlePickAudio(notifier);
        break;
      case EditorToolType.overlay:
        _handlePickOverlay(notifier);
        break;
      case EditorToolType.format:
        final currentRatio = ref.read(timelineNotifierProvider).project.aspectRatio;
        FormatSelectorSheet.show(
          context: context,
          currentRatio: currentRatio,
          onRatioSelected: (newRatio) => notifier.updateAspectRatio(newRatio),
        );
        break;
      case EditorToolType.filters:
      case EditorToolType.adjust:
        final clip = ref.read(timelineNotifierProvider).selectedClip ??
            ref.read(timelineNotifierProvider).project.mainVideoTrack?.clips.firstOrNull;
        if (clip != null) {
          FilterAdjustmentSheet.show(
            context: context,
            initialAdjustments: clip.adjustments,
            onAdjustmentsChanged: (adj) => notifier.setClipAdjustments(clip.id, adj),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pilih klip video terlebih dahulu untuk filter & warna'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
      case EditorToolType.animation:
        final clip = ref.read(timelineNotifierProvider).selectedClip;
        if (clip != null) {
          AnimationSelectorSheet.show(
            context: context,
            initialAnimation: clip.animation,
            onAnimationSelected: (anim) => notifier.setClipAnimation(clip.id, anim),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pilih klip terlebih dahulu untuk mengatur animasi'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        break;
      case EditorToolType.effects:
        final clip = ref.read(timelineNotifierProvider).selectedClip ??
            ref.read(timelineNotifierProvider).project.mainVideoTrack?.clips.firstOrNull;
        if (clip != null) {
          TransitionSelectorSheet.show(
            context: context,
            initialTransition: clip.transition,
            onSave: (trans, applyAll) =>
                notifier.setClipTransition(clip.id, trans, applyToAll: applyAll),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pilih klip terlebih dahulu untuk efek transisi'),
              duration: Duration(seconds: 1),
            ),
          );
        }
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

  Future<void> _handleBackNavigation() async {
    // Pause playback before showing exit dialog
    ref.read(timelineNotifierProvider.notifier).pause();
    _playbackManager.syncWithTimeline(
      timelinePosition: ref.read(timelineNotifierProvider).currentPosition,
      project: ref.read(timelineNotifierProvider).project,
      isPlaying: false,
    );

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Row(
          children: [
            Icon(Icons.save_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Simpan Proyek?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Perubahan timeline dan track akan disimpan otomatis ke dalam draft proyek Anda.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Keluar & Simpan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      final state = ref.read(timelineNotifierProvider);
      final updatedDraft = ProjectDraft(
        id: widget.initialDraft?.id ?? 'draft-${DateTime.now().millisecondsSinceEpoch}',
        title: widget.initialDraft?.title ?? state.project.title,
        duration: state.totalDuration,
        updatedAt: DateTime.now(),
        aspectRatio: state.project.aspectRatio,
        clipCount: state.project.tracks.fold(0, (sum, t) => sum + t.clips.length),
      );
      Navigator.of(context).pop(updatedDraft);
    }
  }

  void _handleExport() {
    final state = ref.read(timelineNotifierProvider);
    ExportSettingsSheet.show(
      context: context,
      project: state.project,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Header Bar (Back, Undo/Redo, Resolution, Export)
              EditorHeader(
                onBack: _handleBackNavigation,
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
                  final textClips = state.project.tracks
                      .where((t) => t.type == ClipType.text && !t.isMuted)
                      .expand((t) => t.clips)
                      .where((c) =>
                          state.currentPosition >= c.timelineStart &&
                          state.currentPosition <= c.timelineEnd)
                      .toList();

                  final overlayClips = state.project.tracks
                      .where((t) => t.type == ClipType.overlay && !t.isMuted)
                      .expand((t) => t.clips)
                      .where((c) =>
                          state.currentPosition >= c.timelineStart &&
                          state.currentPosition <= c.timelineEnd)
                      .toList();

                  final activeMainClip = state.project.mainVideoTrack?.clips
                      .where((c) =>
                          state.currentPosition >= c.timelineStart &&
                          state.currentPosition <= c.timelineEnd)
                      .firstOrNull;

                  return PlayerViewport(
                    aspectRatio: state.project.aspectRatio,
                    currentPosition: state.currentPosition,
                    totalDuration: state.totalDuration,
                    isPlaying: state.isPlaying,
                    videoController: controller,
                    activeAdjustments: activeMainClip?.adjustments,
                    activeTextClips: textClips,
                    activeOverlayClips: overlayClips,
                    onPlayPauseToggle: () => notifier.togglePlayPause(),
                    onFullscreenToggle: _handleFullscreenToggle,
                    onAspectRatioToggle: () {
                      FormatSelectorSheet.show(
                        context: context,
                        currentRatio: state.project.aspectRatio,
                        onRatioSelected: (newRatio) => notifier.updateAspectRatio(newRatio),
                      );
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
    ),
  );
}
}
