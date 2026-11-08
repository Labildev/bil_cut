import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bil_cut/core/services/media_picker_service.dart';
import 'package:bil_cut/data/models/timeline_clip.dart';

void main() {
  group('MediaPickerService Tests', () {
    test('createClipFromXFile generates valid TimelineClip', () {
      final service = MediaPickerService();
      final fakeFile = XFile('/storage/emulated/0/DCIM/Camera/VID_20261108.mp4');

      final clip = service.createClipFromXFile(
        file: fakeFile,
        trackId: 'track-1',
        timelineStart: const Duration(seconds: 2),
        duration: const Duration(seconds: 8),
      );

      expect(clip.name, 'VID_20261108.mp4');
      expect(clip.sourcePath, '/storage/emulated/0/DCIM/Camera/VID_20261108.mp4');
      expect(clip.type, ClipType.video);
      expect(clip.timelineStart, const Duration(seconds: 2));
      expect(clip.duration, const Duration(seconds: 8));
      expect(clip.timelineEnd, const Duration(seconds: 10));
    });

    test('createProjectFromFiles creates multi-clip project properly', () {
      final service = MediaPickerService();
      final files = [
        XFile('/path/to/clip1.mp4'),
        XFile('/path/to/clip2.mp4'),
      ];

      final project = service.createProjectFromFiles(
        files: files,
        title: 'Project Test',
        aspectRatio: '16:9',
      );

      expect(project.title, 'Project Test');
      expect(project.aspectRatio, '16:9');
      expect(project.mainVideoTrack, isNotNull);
      expect(project.mainVideoTrack!.clips.length, 2);

      final clip1 = project.mainVideoTrack!.clips[0];
      final clip2 = project.mainVideoTrack!.clips[1];

      expect(clip1.timelineStart, Duration.zero);
      expect(clip1.duration, const Duration(seconds: 5));
      expect(clip2.timelineStart, const Duration(seconds: 5));
      expect(clip2.duration, const Duration(seconds: 5));
      expect(project.totalDuration, const Duration(seconds: 10));
    });
  });
}

