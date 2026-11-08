import 'package:flutter_test/flutter_test.dart';
import 'package:bil_cut/logic/timeline/timeline_notifier.dart';

void main() {
  group('TimelineNotifier Tests', () {
    test('Initial state loads sample project with correct duration', () {
      final notifier = TimelineNotifier();
      expect(notifier.state.project.tracks.length, 3);
      expect(notifier.state.currentPosition, Duration.zero);
      expect(notifier.state.isPlaying, false);
      expect(notifier.state.selectedClipId, isNull);
    });

    test('Seeking updates currentPosition', () {
      final notifier = TimelineNotifier();
      notifier.seekTo(const Duration(seconds: 3));
      expect(notifier.state.currentPosition, const Duration(seconds: 3));
    });

    test('Zoom scale clamps between 20.0 and 250.0', () {
      final notifier = TimelineNotifier();
      notifier.setZoomScale(500.0);
      expect(notifier.state.pixelsPerSecond, 250.0);

      notifier.setZoomScale(5.0);
      expect(notifier.state.pixelsPerSecond, 20.0);
    });

    test('Select clip and split at playhead', () {
      final notifier = TimelineNotifier();
      // Select first clip: 0s - 5s
      notifier.selectClip('clip-demo-1');
      expect(notifier.state.selectedClipId, 'clip-demo-1');

      // Seek to 2.5s
      notifier.seekTo(const Duration(milliseconds: 2500));

      // Perform split
      final success = notifier.splitSelectedClip();
      expect(success, true);

      final mainTrack = notifier.state.project.mainVideoTrack!;
      expect(mainTrack.clips.length, 4); // was 3, now 4
      expect(mainTrack.clips[0].duration, const Duration(milliseconds: 2500));
    });

    test('Delete selected clip', () {
      final notifier = TimelineNotifier();
      notifier.selectClip('clip-demo-3');
      final success = notifier.deleteSelectedClip();
      expect(success, true);
      expect(notifier.state.selectedClipId, isNull);
      expect(notifier.state.project.findClipById('clip-demo-3'), isNull);
    });
  });
}
