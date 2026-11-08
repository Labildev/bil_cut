import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/timeline_clip.dart';
import '../../data/models/timeline_project.dart';
import '../../data/models/timeline_track.dart';
import 'timeline_state.dart';

class TimelineNotifier extends StateNotifier<TimelineState> {
  final List<TimelineProject> _undoStack = [];
  final List<TimelineProject> _redoStack = [];
  static const int _maxHistoryDepth = 50;

  TimelineNotifier([TimelineProject? initialProject])
      : super(
          TimelineState(
            project: initialProject ?? TimelineProject.sample(),
          ),
        );

  void _recordSnapshot() {
    _undoStack.add(state.project);
    if (_undoStack.length > _maxHistoryDepth) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    state = state.copyWith(canUndo: true, canRedo: false);
  }

  void undo() {
    if (_undoStack.isEmpty) return;

    _redoStack.add(state.project);
    final previousProject = _undoStack.removeLast();

    state = state.copyWith(
      project: previousProject,
      canUndo: _undoStack.isNotEmpty,
      canRedo: true,
      clearSelectedClip: true,
    );
  }

  void redo() {
    if (_redoStack.isEmpty) return;

    _undoStack.add(state.project);
    final nextProject = _redoStack.removeLast();

    state = state.copyWith(
      project: nextProject,
      canUndo: true,
      canRedo: _redoStack.isNotEmpty,
      clearSelectedClip: true,
    );
  }

  void seekTo(Duration position) {
    var targetPosition = position;
    if (targetPosition < Duration.zero) {
      targetPosition = Duration.zero;
    } else if (targetPosition > state.totalDuration) {
      targetPosition = state.totalDuration;
    }

    // Apply snapping to nearest clip boundary if enabled
    if (state.isSnappingEnabled) {
      targetPosition = _applySnapping(targetPosition);
    }

    state = state.copyWith(currentPosition: targetPosition);
  }

  Duration _applySnapping(Duration target, {int snapToleranceMs = 120}) {
    for (final track in state.project.tracks) {
      for (final clip in track.clips) {
        if ((clip.timelineStart - target).inMilliseconds.abs() < snapToleranceMs) {
          return clip.timelineStart;
        }
        if ((clip.timelineEnd - target).inMilliseconds.abs() < snapToleranceMs) {
          return clip.timelineEnd;
        }
      }
    }
    return target;
  }

  void setScrubbing(bool isScrubbing) {
    state = state.copyWith(isScrubbing: isScrubbing);
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    if (state.currentPosition >= state.totalDuration) {
      state = state.copyWith(currentPosition: Duration.zero, isPlaying: true);
    } else {
      state = state.copyWith(isPlaying: true);
    }
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void selectClip(String? clipId) {
    if (state.selectedClipId == clipId) {
      state = state.copyWith(clearSelectedClip: true);
    } else {
      state = state.copyWith(selectedClipId: clipId);
    }
  }

  void deselectClip() {
    state = state.copyWith(clearSelectedClip: true);
  }

  void setZoomScale(double newPixelsPerSecond) {
    final clamped = newPixelsPerSecond.clamp(20.0, 250.0);
    state = state.copyWith(pixelsPerSecond: clamped);
  }

  void adjustZoomBy(double factor) {
    setZoomScale(state.pixelsPerSecond * factor);
  }

  /// Split selected clip at current playhead position
  bool splitSelectedClip() {
    final selectedClip = state.selectedClip;
    if (selectedClip == null) return false;

    final splitPoint = state.currentPosition;
    final splitResult = selectedClip.splitAt(splitPoint);
    if (splitResult == null) return false;

    _recordSnapshot();

    final (leftClip, rightClip) = splitResult;

    for (final track in state.project.tracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == selectedClip.id);
      if (clipIndex != -1) {
        final newClips = List<TimelineClip>.from(track.clips);
        newClips.removeAt(clipIndex);
        newClips.insert(clipIndex, leftClip);
        newClips.insert(clipIndex + 1, rightClip);

        final updatedTrack = track.copyWith(clips: newClips);
        final updatedProject = state.project.withUpdatedTrack(updatedTrack);

        state = state.copyWith(
          project: updatedProject,
          selectedClipId: rightClip.id,
        );
        return true;
      }
    }
    return false;
  }

  /// Trims start boundary of a clip
  void trimClipStart(String clipId, Duration newStart) {
    for (final track in state.project.tracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex != -1) {
        final clip = track.clips[clipIndex];
        final trimmed = clip.trimStart(newStart);

        final newClips = List<TimelineClip>.from(track.clips);
        newClips[clipIndex] = trimmed;

        final updatedTrack = track.copyWith(clips: newClips);
        state = state.copyWith(project: state.project.withUpdatedTrack(updatedTrack));
        return;
      }
    }
  }

  /// Trims end boundary of a clip
  void trimClipEnd(String clipId, Duration newEnd) {
    for (final track in state.project.tracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex != -1) {
        final clip = track.clips[clipIndex];
        final trimmed = clip.trimEnd(newEnd);

        final newClips = List<TimelineClip>.from(track.clips);
        newClips[clipIndex] = trimmed;

        final updatedTrack = track.copyWith(clips: newClips);
        state = state.copyWith(project: state.project.withUpdatedTrack(updatedTrack));
        return;
      }
    }
  }

  /// Sets clip playback speed and ripples subsequent clips on the track
  bool setClipSpeed(String clipId, double newSpeed) {
    if (newSpeed <= 0) return false;

    for (final track in state.project.tracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex != -1) {
        _recordSnapshot();

        final clip = track.clips[clipIndex];
        final updatedClip = clip.withSpeed(newSpeed);

        final newClips = List<TimelineClip>.from(track.clips);
        newClips[clipIndex] = updatedClip;

        // Ripple adjust subsequent clips on main track
        if (track.isMainTrack) {
          _rippleRealignClips(newClips);
        }

        final updatedTrack = track.copyWith(clips: newClips);
        state = state.copyWith(project: state.project.withUpdatedTrack(updatedTrack));
        return true;
      }
    }
    return false;
  }

  /// Sets clip volume (0.0 to 2.0)
  bool setClipVolume(String clipId, double volume) {
    final clampedVolume = volume.clamp(0.0, 2.0);

    for (final track in state.project.tracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex != -1) {
        _recordSnapshot();

        final clip = track.clips[clipIndex];
        final updatedClip = clip.copyWith(volume: clampedVolume);

        final newClips = List<TimelineClip>.from(track.clips);
        newClips[clipIndex] = updatedClip;

        final updatedTrack = track.copyWith(clips: newClips);
        state = state.copyWith(project: state.project.withUpdatedTrack(updatedTrack));
        return true;
      }
    }
    return false;
  }

  /// Duplicates the selected clip and inserts it immediately after
  bool duplicateSelectedClip() {
    final clipId = state.selectedClipId;
    if (clipId == null) return false;

    for (final track in state.project.tracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex != -1) {
        _recordSnapshot();

        final original = track.clips[clipIndex];
        final duplicate = original.copyWith(
          id: '${original.id}_dup_${DateTime.now().microsecondsSinceEpoch}',
          name: '${original.name} (Salin)',
          timelineStart: original.timelineEnd,
        );

        final newClips = List<TimelineClip>.from(track.clips);
        newClips.insert(clipIndex + 1, duplicate);

        if (track.isMainTrack) {
          _rippleRealignClips(newClips);
        }

        final updatedTrack = track.copyWith(clips: newClips);
        final updatedProject = state.project.withUpdatedTrack(updatedTrack);

        state = state.copyWith(
          project: updatedProject,
          selectedClipId: duplicate.id,
        );
        return true;
      }
    }
    return false;
  }

  /// Rotates the selected clip 90 degrees clockwise
  bool rotateSelectedClip() {
    final clipId = state.selectedClipId;
    if (clipId == null) return false;

    for (final track in state.project.tracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex != -1) {
        _recordSnapshot();

        final clip = track.clips[clipIndex];
        final rotated = clip.rotateClockwise();

        final newClips = List<TimelineClip>.from(track.clips);
        newClips[clipIndex] = rotated;

        final updatedTrack = track.copyWith(clips: newClips);
        state = state.copyWith(project: state.project.withUpdatedTrack(updatedTrack));
        return true;
      }
    }
    return false;
  }

  /// Deletes the currently selected clip with ripple realignment on the main track
  bool deleteSelectedClip() {
    final clipId = state.selectedClipId;
    if (clipId == null) return false;

    for (final track in state.project.tracks) {
      final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIndex != -1) {
        _recordSnapshot();

        final newClips = List<TimelineClip>.from(track.clips)..removeAt(clipIndex);

        if (track.isMainTrack) {
          _rippleRealignClips(newClips);
        }

        final updatedTrack = track.copyWith(clips: newClips);
        final updatedProject = state.project.withUpdatedTrack(updatedTrack);

        state = state.copyWith(
          project: updatedProject,
          clearSelectedClip: true,
        );
        return true;
      }
    }
    return false;
  }

  /// Re-aligns consecutive clips on the main track so there are no empty gaps
  void _rippleRealignClips(List<TimelineClip> clips) {
    var cursor = Duration.zero;
    for (int i = 0; i < clips.length; i++) {
      clips[i] = clips[i].copyWith(timelineStart: cursor);
      cursor += clips[i].duration;
    }
  }

  void addTextClip({
    required String text,
    String font = 'Inter',
    int color = 0xFFFFFFFF,
    int? backgroundColor,
    bool hasShadow = true,
    Duration duration = const Duration(seconds: 4),
  }) {
    _recordSnapshot();

    final textTrackIndex = state.project.tracks.indexWhere((t) => t.type == ClipType.text);
    final clipId = 'text-${DateTime.now().microsecondsSinceEpoch}';
    final startTime = state.currentPosition;

    final newClip = TimelineClip(
      id: clipId,
      trackId: textTrackIndex != -1 ? state.project.tracks[textTrackIndex].id : 'track-text-overlay',
      type: ClipType.text,
      name: text,
      textContent: text,
      fontFamily: font,
      textColorValue: color,
      textBackgroundColorValue: backgroundColor,
      hasTextShadow: hasShadow,
      timelineStart: startTime,
      duration: duration,
      sourceOut: duration,
    );

    if (textTrackIndex != -1) {
      final track = state.project.tracks[textTrackIndex];
      final newClips = List<TimelineClip>.from(track.clips)..add(newClip);
      final updatedTrack = track.copyWith(clips: newClips);
      state = state.copyWith(
        project: state.project.withUpdatedTrack(updatedTrack),
        selectedClipId: newClip.id,
      );
    } else {
      final newTrack = TimelineTrack(
        id: 'track-text-overlay',
        type: ClipType.text,
        name: 'Teks',
        clips: [newClip],
      );
      final newTracks = List<TimelineTrack>.from(state.project.tracks)..add(newTrack);
      state = state.copyWith(
        project: state.project.copyWith(tracks: newTracks),
        selectedClipId: newClip.id,
      );
    }
  }

  void updateTextClip({
    required String clipId,
    required String text,
    required String font,
    required int color,
    required int? backgroundColor,
    required bool hasShadow,
  }) {
    for (final track in state.project.tracks) {
      final index = track.clips.indexWhere((c) => c.id == clipId);
      if (index != -1) {
        _recordSnapshot();
        final clip = track.clips[index];
        final updated = clip.copyWith(
          name: text,
          textContent: text,
          fontFamily: font,
          textColorValue: color,
          textBackgroundColorValue: backgroundColor,
          hasTextShadow: hasShadow,
        );
        final newClips = List<TimelineClip>.from(track.clips);
        newClips[index] = updated;
        final updatedTrack = track.copyWith(clips: newClips);
        state = state.copyWith(project: state.project.withUpdatedTrack(updatedTrack));
        return;
      }
    }
  }

  void addAudioClip({
    required String name,
    required String path,
    Duration duration = const Duration(seconds: 15),
  }) {
    _recordSnapshot();

    final audioTrackIndex = state.project.tracks.indexWhere((t) => t.type == ClipType.audio);
    final clipId = 'audio-${DateTime.now().microsecondsSinceEpoch}';
    final startTime = state.currentPosition;

    final newClip = TimelineClip(
      id: clipId,
      trackId: audioTrackIndex != -1 ? state.project.tracks[audioTrackIndex].id : 'track-audio-bgm',
      type: ClipType.audio,
      name: name,
      sourcePath: path,
      timelineStart: startTime,
      duration: duration,
      sourceOut: duration,
      volume: 0.8,
    );

    if (audioTrackIndex != -1) {
      final track = state.project.tracks[audioTrackIndex];
      final newClips = List<TimelineClip>.from(track.clips)..add(newClip);
      final updatedTrack = track.copyWith(clips: newClips);
      state = state.copyWith(
        project: state.project.withUpdatedTrack(updatedTrack),
        selectedClipId: newClip.id,
      );
    } else {
      final newTrack = TimelineTrack(
        id: 'track-audio-bgm',
        type: ClipType.audio,
        name: 'Audio BGM',
        clips: [newClip],
      );
      final newTracks = List<TimelineTrack>.from(state.project.tracks)..add(newTrack);
      state = state.copyWith(
        project: state.project.copyWith(tracks: newTracks),
        selectedClipId: newClip.id,
      );
    }
  }

  void addOverlayClip({
    required String name,
    required String path,
    Duration duration = const Duration(seconds: 5),
  }) {
    _recordSnapshot();

    final overlayTrackIndex = state.project.tracks.indexWhere((t) => t.type == ClipType.overlay);
    final clipId = 'overlay-${DateTime.now().microsecondsSinceEpoch}';
    final startTime = state.currentPosition;

    final newClip = TimelineClip(
      id: clipId,
      trackId: overlayTrackIndex != -1 ? state.project.tracks[overlayTrackIndex].id : 'track-pip-overlay',
      type: ClipType.overlay,
      name: name,
      sourcePath: path,
      timelineStart: startTime,
      duration: duration,
      sourceOut: duration,
      scale: 0.8,
      positionX: 0.5,
      positionY: 0.5,
    );

    if (overlayTrackIndex != -1) {
      final track = state.project.tracks[overlayTrackIndex];
      final newClips = List<TimelineClip>.from(track.clips)..add(newClip);
      final updatedTrack = track.copyWith(clips: newClips);
      state = state.copyWith(
        project: state.project.withUpdatedTrack(updatedTrack),
        selectedClipId: newClip.id,
      );
    } else {
      final newTrack = TimelineTrack(
        id: 'track-pip-overlay',
        type: ClipType.overlay,
        name: 'Overlay PIP',
        clips: [newClip],
      );
      final newTracks = List<TimelineTrack>.from(state.project.tracks)..add(newTrack);
      state = state.copyWith(
        project: state.project.copyWith(tracks: newTracks),
        selectedClipId: newClip.id,
      );
    }
  }

  void loadProject(TimelineProject project) {
    _undoStack.clear();
    _redoStack.clear();
    state = state.copyWith(
      project: project,
      currentPosition: Duration.zero,
      isPlaying: false,
      clearSelectedClip: true,
      canUndo: false,
      canRedo: false,
    );
  }

  void appendClipsToMainTrack(List<TimelineClip> newClips) {
    if (newClips.isEmpty) return;

    final mainTrack = state.project.mainVideoTrack;
    if (mainTrack == null) return;

    _recordSnapshot();

    var currentEnd = mainTrack.trackDuration;
    final positionedClips = <TimelineClip>[];

    for (final clip in newClips) {
      final positioned = clip.copyWith(
        trackId: mainTrack.id,
        timelineStart: currentEnd,
      );
      positionedClips.add(positioned);
      currentEnd += positioned.duration;
    }

    final updatedClips = List<TimelineClip>.from(mainTrack.clips)..addAll(positionedClips);
    final updatedTrack = mainTrack.copyWith(clips: updatedClips);
    final updatedProject = state.project.withUpdatedTrack(updatedTrack);

    state = state.copyWith(project: updatedProject);
  }

  void updateAspectRatio(String ratio) {
    _recordSnapshot();
    state = state.copyWith(
      project: state.project.copyWith(aspectRatio: ratio),
    );
  }

  void updateResolution(String resolution) {
    _recordSnapshot();
    state = state.copyWith(
      project: state.project.copyWith(resolution: resolution),
    );
  }

  void toggleTrackMute(String trackId) {
    final track = state.project.tracks.where((t) => t.id == trackId).firstOrNull;
    if (track != null) {
      _recordSnapshot();
      final updatedTrack = track.copyWith(isMuted: !track.isMuted);
      state = state.copyWith(
        project: state.project.withUpdatedTrack(updatedTrack),
      );
    }
  }
}

final timelineNotifierProvider =
    StateNotifierProvider.autoDispose<TimelineNotifier, TimelineState>((ref) {
  return TimelineNotifier();
});
