import 'package:flutter_test/flutter_test.dart';
import 'package:bil_cut/data/models/timeline_clip.dart';
import 'package:bil_cut/data/models/timeline_project.dart';

void main() {
  group('Timeline Data Models Tests', () {
    test('TimelineClip splitAt splits properly into two clips', () {
      const clip = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        type: ClipType.video,
        name: 'Video 1',
        timelineStart: Duration.zero,
        duration: Duration(seconds: 10),
        sourceIn: Duration.zero,
        sourceOut: Duration(seconds: 10),
      );

      final result = clip.splitAt(const Duration(seconds: 4));
      expect(result, isNotNull);
      final (left, right) = result!;

      expect(left.timelineStart, Duration.zero);
      expect(left.duration, const Duration(seconds: 4));
      expect(left.sourceOut, const Duration(seconds: 4));

      expect(right.timelineStart, const Duration(seconds: 4));
      expect(right.duration, const Duration(seconds: 6));
      expect(right.sourceIn, const Duration(seconds: 4));
    });

    test('TimelineClip trimStart & trimEnd modify durations correctly', () {
      const clip = TimelineClip(
        id: 'clip-1',
        trackId: 'track-1',
        type: ClipType.video,
        name: 'Video 1',
        timelineStart: Duration(seconds: 2),
        duration: Duration(seconds: 8),
        sourceIn: Duration.zero,
        sourceOut: Duration(seconds: 8),
      );

      final trimmedStart = clip.trimStart(const Duration(seconds: 4));
      expect(trimmedStart.timelineStart, const Duration(seconds: 4));
      expect(trimmedStart.duration, const Duration(seconds: 6));

      final trimmedEnd = clip.trimEnd(const Duration(seconds: 8));
      expect(trimmedEnd.timelineStart, const Duration(seconds: 2));
      expect(trimmedEnd.duration, const Duration(seconds: 6));
    });

    test('TimelineProject calculates total duration across tracks', () {
      final project = TimelineProject.sample();
      expect(project.totalDuration, const Duration(seconds: 15));
      expect(project.tracks.length, 3);
      expect(project.mainVideoTrack, isNotNull);
    });
  });
}
