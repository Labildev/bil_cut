import 'package:flutter/foundation.dart';

enum ClipType { video, audio, text, overlay }

@immutable
class TimelineClip {
  final String id;
  final String trackId;
  final ClipType type;
  final String name;
  final String? sourcePath;
  
  /// Position where the clip begins on the overall project timeline
  final Duration timelineStart;
  
  /// Active visible duration of the clip on the timeline
  final Duration duration;
  
  /// In-point relative to the source media (for trimmed head)
  final Duration sourceIn;
  
  /// Out-point relative to the source media (for trimmed tail)
  final Duration sourceOut;
  
  /// Speed multiplier (1.0 = normal, 2.0 = 2x fast, 0.5 = slow mo)
  final double speed;
  
  /// Volume (0.0 = muted, 1.0 = 100%, 2.0 = 200% boost)
  final double volume;
  
  /// Visual properties (for text or overlay)
  final String? textContent;
  final Map<String, dynamic>? extraProperties;

  const TimelineClip({
    required this.id,
    required this.trackId,
    required this.type,
    required this.name,
    this.sourcePath,
    required this.timelineStart,
    required this.duration,
    this.sourceIn = Duration.zero,
    required this.sourceOut,
    this.speed = 1.0,
    this.volume = 1.0,
    this.textContent,
    this.extraProperties,
  });

  Duration get timelineEnd => timelineStart + duration;

  TimelineClip copyWith({
    String? id,
    String? trackId,
    ClipType? type,
    String? name,
    String? sourcePath,
    Duration? timelineStart,
    Duration? duration,
    Duration? sourceIn,
    Duration? sourceOut,
    double? speed,
    double? volume,
    String? textContent,
    Map<String, dynamic>? extraProperties,
  }) {
    return TimelineClip(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      type: type ?? this.type,
      name: name ?? this.name,
      sourcePath: sourcePath ?? this.sourcePath,
      timelineStart: timelineStart ?? this.timelineStart,
      duration: duration ?? this.duration,
      sourceIn: sourceIn ?? this.sourceIn,
      sourceOut: sourceOut ?? this.sourceOut,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      textContent: textContent ?? this.textContent,
      extraProperties: extraProperties ?? this.extraProperties,
    );
  }

  /// Splits this clip into two clips at [splitPointOnTimeline].
  /// Returns a pair of (leftClip, rightClip) or null if split point is outside bounds.
  (TimelineClip, TimelineClip)? splitAt(Duration splitPointOnTimeline) {
    if (splitPointOnTimeline <= timelineStart || splitPointOnTimeline >= timelineEnd) {
      return null;
    }

    final leftDuration = splitPointOnTimeline - timelineStart;
    final rightDuration = duration - leftDuration;

    final leftSourceDuration = Duration(
      milliseconds: (leftDuration.inMilliseconds * speed).round(),
    );
    final splitSourcePoint = sourceIn + leftSourceDuration;

    final leftClip = copyWith(
      duration: leftDuration,
      sourceOut: splitSourcePoint,
    );

    final rightClip = copyWith(
      id: '${id}_split_${DateTime.now().microsecondsSinceEpoch}',
      timelineStart: splitPointOnTimeline,
      duration: rightDuration,
      sourceIn: splitSourcePoint,
    );

    return (leftClip, rightClip);
  }

  /// Trims the start (head) of the clip
  TimelineClip trimStart(Duration newTimelineStart) {
    if (newTimelineStart >= timelineEnd) return this;
    final delta = newTimelineStart - timelineStart;
    final sourceDelta = Duration(milliseconds: (delta.inMilliseconds * speed).round());
    return copyWith(
      timelineStart: newTimelineStart,
      duration: duration - delta,
      sourceIn: sourceIn + sourceDelta,
    );
  }

  /// Trims the end (tail) of the clip
  TimelineClip trimEnd(Duration newTimelineEnd) {
    if (newTimelineEnd <= timelineStart) return this;
    final newDuration = newTimelineEnd - timelineStart;
    final sourceDuration = Duration(
      milliseconds: (newDuration.inMilliseconds * speed).round(),
    );
    return copyWith(
      duration: newDuration,
      sourceOut: sourceIn + sourceDuration,
    );
  }
}
