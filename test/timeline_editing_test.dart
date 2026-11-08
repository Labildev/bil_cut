import 'package:flutter_test/flutter_test.dart';
import 'package:bil_cut/logic/timeline/timeline_notifier.dart';

void main() {
  group('Timeline Editing & Undo/Redo Engine Tests', () {
    test('Undo and Redo stack works on split', () {
      final notifier = TimelineNotifier();
      expect(notifier.state.canUndo, false);
      expect(notifier.state.canRedo, false);

      notifier.selectClip('clip-demo-1');
      notifier.seekTo(const Duration(seconds: 2));
      notifier.splitSelectedClip();

      expect(notifier.state.canUndo, true);
      expect(notifier.state.canRedo, false);
      expect(notifier.state.project.mainVideoTrack!.clips.length, 4);

      // Undo split
      notifier.undo();
      expect(notifier.state.project.mainVideoTrack!.clips.length, 3);
      expect(notifier.state.canUndo, false);
      expect(notifier.state.canRedo, true);

      // Redo split
      notifier.redo();
      expect(notifier.state.project.mainVideoTrack!.clips.length, 4);
      expect(notifier.state.canUndo, true);
      expect(notifier.state.canRedo, false);
    });

    test('Speed adjustment recalculates duration and ripples main track', () {
      final notifier = TimelineNotifier();
      // clip-demo-1 has 5 seconds duration at 1.0x
      // Setting 2.0x speed should make its duration 2.5s (2500ms)
      final success = notifier.setClipSpeed('clip-demo-1', 2.0);
      expect(success, true);

      final track = notifier.state.project.mainVideoTrack!;
      final clip1 = track.clips[0];
      final clip2 = track.clips[1];

      expect(clip1.speed, 2.0);
      expect(clip1.duration, const Duration(milliseconds: 2500));

      // Clip 2 should be rippled backwards to 2.5s
      expect(clip2.timelineStart, const Duration(milliseconds: 2500));
    });

    test('Volume adjustment updates clip volume', () {
      final notifier = TimelineNotifier();
      final success = notifier.setClipVolume('clip-demo-1', 1.5);
      expect(success, true);

      final clip = notifier.state.project.findClipById('clip-demo-1')!;
      expect(clip.volume, 1.5);
    });

    test('Duplicate clip inserts copy and ripples subsequent clips', () {
      final notifier = TimelineNotifier();
      notifier.selectClip('clip-demo-1');

      final success = notifier.duplicateSelectedClip();
      expect(success, true);

      final track = notifier.state.project.mainVideoTrack!;
      expect(track.clips.length, 4); // was 3, now 4
      expect(track.clips[1].name, contains('(Salin)'));
      expect(track.clips[1].timelineStart, const Duration(seconds: 5));
    });

    test('Rotate clip cycles by 90 degrees', () {
      final notifier = TimelineNotifier();
      notifier.selectClip('clip-demo-1');

      notifier.rotateSelectedClip();
      var clip = notifier.state.project.findClipById('clip-demo-1')!;
      expect(clip.rotationDegrees, 90);

      notifier.rotateSelectedClip();
      clip = notifier.state.project.findClipById('clip-demo-1')!;
      expect(clip.rotationDegrees, 180);
    });
  });
}

