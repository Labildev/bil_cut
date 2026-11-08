import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/timeline_clip.dart';
import '../../data/models/timeline_project.dart';

class VideoPlaybackManager {
  VideoPlayerController? _activeController;
  String? _currentLoadedPath;
  TimelineClip? _currentActiveClip;

  final ValueNotifier<VideoPlayerController?> controllerNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isBufferingNotifier = ValueNotifier(false);

  VideoPlayerController? get activeController => _activeController;
  TimelineClip? get currentActiveClip => _currentActiveClip;

  /// Given the current timeline position, finds the active clip and synchronizes playback
  Future<void> syncWithTimeline({
    required Duration timelinePosition,
    required TimelineProject project,
    required bool isPlaying,
  }) async {
    final mainTrack = project.mainVideoTrack;
    if (mainTrack == null || mainTrack.clips.isEmpty) {
      _stopAndClear();
      return;
    }

    // Find the clip at the current playhead position
    TimelineClip? activeClip;
    for (final clip in mainTrack.clips) {
      if (timelinePosition >= clip.timelineStart && timelinePosition < clip.timelineEnd) {
        activeClip = clip;
        break;
      }
    }

    // If at the exact end of timeline, point to the last clip
    activeClip ??= mainTrack.clips.last;

    final sourcePath = activeClip.sourcePath;

    if (sourcePath == null || !File(sourcePath).existsSync()) {
      // Demo / simulated clip or file doesn't exist on disk yet
      _stopAndClear();
      _currentActiveClip = activeClip;
      return;
    }

    // Need to switch controller if path changed
    if (_currentLoadedPath != sourcePath) {
      await _loadNewVideo(sourcePath);
    }

    _currentActiveClip = activeClip;

    // Calculate source seek offset: (timelinePosition - clip.timelineStart) + clip.sourceIn
    final clipRelativeMs = (timelinePosition - activeClip.timelineStart).inMilliseconds;
    final targetSourceMs = activeClip.sourceIn.inMilliseconds + (clipRelativeMs * activeClip.speed).round();
    final targetSourceDuration = Duration(
      milliseconds: targetSourceMs.clamp(0, activeClip.sourceOut.inMilliseconds),
    );

    if (_activeController != null && _activeController!.value.isInitialized) {
      // Avoid excessive seek calls if within 80ms
      final currentPos = _activeController!.value.position;
      if ((currentPos - targetSourceDuration).inMilliseconds.abs() > 80) {
        await _activeController!.seekTo(targetSourceDuration);
      }

      if (isPlaying && !_activeController!.value.isPlaying) {
        await _activeController!.play();
      } else if (!isPlaying && _activeController!.value.isPlaying) {
        await _activeController!.pause();
      }
    }
  }

  Future<void> _loadNewVideo(String path) async {
    isBufferingNotifier.value = true;
    try {
      await _activeController?.dispose();
      _activeController = null;
      controllerNotifier.value = null;

      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      await controller.setLooping(false);

      _activeController = controller;
      _currentLoadedPath = path;
      controllerNotifier.value = controller;
    } catch (e) {
      _stopAndClear();
    } finally {
      isBufferingNotifier.value = false;
    }
  }

  void _stopAndClear() {
    _activeController?.pause();
    _currentLoadedPath = null;
    _currentActiveClip = null;
    // Don't dispose activeController immediately to prevent flickering, just pause
  }

  Future<void> play() async {
    if (_activeController != null && _activeController!.value.isInitialized) {
      await _activeController!.play();
    }
  }

  Future<void> pause() async {
    if (_activeController != null && _activeController!.value.isInitialized) {
      await _activeController!.pause();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_activeController != null && _activeController!.value.isInitialized) {
      await _activeController!.seekTo(position);
    }
  }

  void dispose() {
    _activeController?.dispose();
    _activeController = null;
    controllerNotifier.dispose();
    isBufferingNotifier.dispose();
  }
}
