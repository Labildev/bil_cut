import 'package:flutter/foundation.dart';
import '../../data/models/timeline_clip.dart';
import '../../data/models/timeline_project.dart';

@immutable
class TimelineState {
  final TimelineProject project;
  final Duration currentPosition;
  final bool isPlaying;
  final String? selectedClipId;
  final double pixelsPerSecond;
  final bool isSnappingEnabled;
  final bool isScrubbing;
  final bool canUndo;
  final bool canRedo;

  const TimelineState({
    required this.project,
    this.currentPosition = Duration.zero,
    this.isPlaying = false,
    this.selectedClipId,
    this.pixelsPerSecond = 60.0,
    this.isSnappingEnabled = true,
    this.isScrubbing = false,
    this.canUndo = false,
    this.canRedo = false,
  });

  Duration get totalDuration => project.totalDuration;

  TimelineClip? get selectedClip {
    if (selectedClipId == null) return null;
    return project.findClipById(selectedClipId!);
  }

  /// Total width of the timeline in pixels given current zoom scale
  double get totalTimelineWidthPixels {
    return (totalDuration.inMilliseconds / 1000.0) * pixelsPerSecond;
  }

  /// Converts a timeline timestamp to pixel offset
  double timeToPixels(Duration time) {
    return (time.inMilliseconds / 1000.0) * pixelsPerSecond;
  }

  /// Converts pixel offset back to timeline timestamp
  Duration pixelsToTime(double pixels) {
    if (pixels <= 0) return Duration.zero;
    final ms = (pixels / pixelsPerSecond) * 1000.0;
    return Duration(milliseconds: ms.round());
  }

  TimelineState copyWith({
    TimelineProject? project,
    Duration? currentPosition,
    bool? isPlaying,
    String? selectedClipId,
    bool clearSelectedClip = false,
    double? pixelsPerSecond,
    bool? isSnappingEnabled,
    bool? isScrubbing,
    bool? canUndo,
    bool? canRedo,
  }) {
    return TimelineState(
      project: project ?? this.project,
      currentPosition: currentPosition ?? this.currentPosition,
      isPlaying: isPlaying ?? this.isPlaying,
      selectedClipId: clearSelectedClip ? null : (selectedClipId ?? this.selectedClipId),
      pixelsPerSecond: pixelsPerSecond ?? this.pixelsPerSecond,
      isSnappingEnabled: isSnappingEnabled ?? this.isSnappingEnabled,
      isScrubbing: isScrubbing ?? this.isScrubbing,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }
}
