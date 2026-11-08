import 'package:flutter_test/flutter_test.dart';
import 'package:bil_cut/data/models/timeline_clip.dart';
import 'package:bil_cut/logic/timeline/timeline_notifier.dart';

void main() {
  group('Multi-Track Overlay & Text Engine Tests', () {
    test('Add and update text overlay clip with styling', () {
      final notifier = TimelineNotifier();

      notifier.seekTo(const Duration(seconds: 3));
      notifier.addTextClip(
        text: 'Halo Dunia!',
        font: 'Poppins',
        color: 0xFF00F0FF,
        hasShadow: true,
        duration: const Duration(seconds: 4),
      );

      final textTrack = notifier.state.project.tracks.firstWhere(
        (t) => t.type == ClipType.text,
      );

      final addedClip = textTrack.clips.firstWhere((c) => c.textContent == 'Halo Dunia!');
      expect(addedClip.fontFamily, 'Poppins');
      expect(addedClip.textColorValue, 0xFF00F0FF);
      expect(addedClip.timelineStart, const Duration(seconds: 3));
      expect(addedClip.duration, const Duration(seconds: 4));

      // Update text
      notifier.updateTextClip(
        clipId: addedClip.id,
        text: 'Teks Baru Diupdate',
        font: 'Roboto',
        color: 0xFFFF2D55,
        backgroundColor: 0xFF000000,
        hasShadow: false,
      );

      final updatedTrack = notifier.state.project.tracks.firstWhere(
        (t) => t.type == ClipType.text,
      );
      final updatedClip = updatedTrack.clips.firstWhere((c) => c.id == addedClip.id);

      expect(updatedClip.textContent, 'Teks Baru Diupdate');
      expect(updatedClip.fontFamily, 'Roboto');
      expect(updatedClip.textColorValue, 0xFFFF2D55);
      expect(updatedClip.textBackgroundColorValue, 0xFF000000);
      expect(updatedClip.hasTextShadow, false);
    });

    test('Add BGM audio track clip', () {
      final notifier = TimelineNotifier();
      notifier.seekTo(const Duration(seconds: 1));

      notifier.addAudioClip(
        name: 'Podcast_Intro.mp3',
        path: '/storage/audio/intro.mp3',
        duration: const Duration(seconds: 8),
      );

      final audioTrack = notifier.state.project.tracks.firstWhere(
        (t) => t.type == ClipType.audio,
      );
      final addedClip = audioTrack.clips.firstWhere((c) => c.name == 'Podcast_Intro.mp3');

      expect(addedClip.sourcePath, '/storage/audio/intro.mp3');
      expect(addedClip.timelineStart, const Duration(seconds: 1));
      expect(addedClip.duration, const Duration(seconds: 8));
      expect(addedClip.volume, 0.8);
    });

    test('Add PIP overlay clip with custom coordinates and scale', () {
      final notifier = TimelineNotifier();
      notifier.seekTo(const Duration(seconds: 2));

      notifier.addOverlayClip(
        name: 'Sticker_Reaction.mp4',
        path: '/storage/media/reaction.mp4',
        duration: const Duration(seconds: 5),
      );

      final overlayTrack = notifier.state.project.tracks.firstWhere(
        (t) => t.type == ClipType.overlay,
      );
      final addedClip = overlayTrack.clips.firstWhere((c) => c.name == 'Sticker_Reaction.mp4');

      expect(addedClip.type, ClipType.overlay);
      expect(addedClip.scale, 0.8);
      expect(addedClip.positionX, 0.5);
      expect(addedClip.positionY, 0.5);
      expect(addedClip.timelineStart, const Duration(seconds: 2));
    });

    test('Update canvas aspect ratio updates project correctly', () {
      final notifier = TimelineNotifier();
      expect(notifier.state.project.aspectRatio, '9:16');

      notifier.updateAspectRatio('16:9');
      expect(notifier.state.project.aspectRatio, '16:9');

      notifier.updateAspectRatio('1:1');
      expect(notifier.state.project.aspectRatio, '1:1');
    });
  });
}

