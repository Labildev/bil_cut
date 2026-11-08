import 'package:flutter/foundation.dart';
import 'timeline_clip.dart';

@immutable
class TimelineTrack {
  final String id;
  final ClipType type;
  final String name;
  final bool isMuted;
  final bool isLocked;
  final bool isMainTrack;
  final List<TimelineClip> clips;

  const TimelineTrack({
    required this.id,
    required this.type,
    required this.name,
    this.isMuted = false,
    this.isLocked = false,
    this.isMainTrack = false,
    required this.clips,
  });

  Duration get trackDuration {
    if (clips.isEmpty) return Duration.zero;
    return clips.map((c) => c.timelineEnd).reduce((a, b) => a > b ? a : b);
  }

  TimelineTrack copyWith({
    String? id,
    ClipType? type,
    String? name,
    bool? isMuted,
    bool? isLocked,
    bool? isMainTrack,
    List<TimelineClip>? clips,
  }) {
    return TimelineTrack(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      isMuted: isMuted ?? this.isMuted,
      isLocked: isLocked ?? this.isLocked,
      isMainTrack: isMainTrack ?? this.isMainTrack,
      clips: clips ?? this.clips,
    );
  }

  TimelineTrack withUpdatedClip(TimelineClip updatedClip) {
    final newClips = clips.map((c) => c.id == updatedClip.id ? updatedClip : c).toList();
    return copyWith(clips: newClips);
  }

  TimelineTrack withRemovedClip(String clipId) {
    final newClips = clips.where((c) => c.id != clipId).toList();
    return copyWith(clips: newClips);
  }

  TimelineTrack withInsertedClips(int index, List<TimelineClip> inserted) {
    final newClips = List<TimelineClip>.from(clips);
    newClips.insertAll(index, inserted);
    return copyWith(clips: newClips);
  }
}
