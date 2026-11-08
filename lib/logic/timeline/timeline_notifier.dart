import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/timeline_clip.dart';
import '../../data/models/timeline_project.dart';
import 'timeline_state.dart';

class TimelineNotifier extends StateNotifier<TimelineState> {
  TimelineNotifier([TimelineProject? initialProject])
      : super(
          TimelineState(
            project: initialProject ?? TimelineProject.sample(),
          ),
        );

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
    // If at end, loop to beginning
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
      // Toggle off selection if clicked again
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

    final (leftClip, rightClip) = splitResult;

    // Find the track containing this clip
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
          selectedClipId: rightClip.id, // Select the newly created right split clip
        );
        return true;
      }
    }
    return false;
  }

  /// Trims start boundary of a clip
  void trimClipStart(String clipId, Duration newStart) {
    for (final track in state.project.tracks) {
      final clip = track.clips.where((c) => c.id == clipId).firstOrNull;
      if (clip != null) {
        final trimmed = clip.trimStart(newStart);
        final updatedTrack = track.withUpdatedClip(trimmed);
        state = state.copyWith(project: state.project.withUpdatedTrack(updatedTrack));
        return;
      }
    }
  }

  /// Trims end boundary of a clip
  void trimClipEnd(String clipId, Duration newEnd) {
    for (final track in state.project.tracks) {
      final clip = track.clips.where((c) => c.id == clipId).firstOrNull;
      if (clip != null) {
        final trimmed = clip.trimEnd(newEnd);
        final updatedTrack = track.withUpdatedClip(trimmed);
        state = state.copyWith(project: state.project.withUpdatedTrack(updatedTrack));
        return;
      }
    }
  }

  /// Deletes the currently selected clip
  bool deleteSelectedClip() {
    final clipId = state.selectedClipId;
    if (clipId == null) return false;

    for (final track in state.project.tracks) {
      if (track.clips.any((c) => c.id == clipId)) {
        final updatedTrack = track.withRemovedClip(clipId);
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

  void updateAspectRatio(String ratio) {
    state = state.copyWith(
      project: state.project.copyWith(aspectRatio: ratio),
    );
  }

  void updateResolution(String resolution) {
    state = state.copyWith(
      project: state.project.copyWith(resolution: resolution),
    );
  }

  void toggleTrackMute(String trackId) {
    final track = state.project.tracks.where((t) => t.id == trackId).firstOrNull;
    if (track != null) {
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

