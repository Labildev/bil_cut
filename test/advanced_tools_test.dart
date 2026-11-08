import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bil_cut/data/models/timeline_clip.dart';
import 'package:bil_cut/data/models/timeline_project.dart';
import 'package:bil_cut/data/models/timeline_track.dart';
import 'package:bil_cut/logic/timeline/timeline_notifier.dart';
import 'package:bil_cut/presentation/widgets/editor/modals/canvas_background_sheet.dart';
import 'package:bil_cut/presentation/widgets/editor/modals/voiceover_recorder_sheet.dart';

void main() {
  group('Advanced Video Tools & Customization Tests', () {
    test('extractAudioFromClip mutes original video and adds audio track clip', () {
      final videoClip = const TimelineClip(
        id: 'clip-vid-1',
        trackId: 'track-main-video',
        type: ClipType.video,
        name: 'Vlog.mp4',
        timelineStart: Duration(seconds: 2),
        duration: Duration(seconds: 8),
        sourceOut: Duration(seconds: 8),
      );

      final project = TimelineProject(
        id: 'p1',
        title: 'Extract Test',
        tracks: [
          TimelineTrack(
            id: 'track-main-video',
            type: ClipType.video,
            name: 'Video Utama',
            isMainTrack: true,
            clips: [videoClip],
          ),
          const TimelineTrack(
            id: 'track-audio-bgm',
            type: ClipType.audio,
            name: 'Audio BGM',
            clips: [],
          ),
        ],
        updatedAt: DateTime.now(),
      );

      final notifier = TimelineNotifier(project);
      final success = notifier.extractAudioFromClip('clip-vid-1');

      expect(success, isTrue);

      final updatedVid = notifier.state.project.findClipById('clip-vid-1');
      expect(updatedVid!.volume, 0.0);

      final audioTrack = notifier.state.project.tracks.firstWhere((t) => t.type == ClipType.audio);
      expect(audioTrack.clips.length, 1);
      final extractedAudio = audioTrack.clips.first;
      expect(extractedAudio.timelineStart, const Duration(seconds: 2));
      expect(extractedAudio.duration, const Duration(seconds: 8));
      expect(extractedAudio.name, contains('Vlog.mp4'));
    });

    test('replaceClipSource updates source path and clip name', () {
      final notifier = TimelineNotifier();
      final clip = notifier.state.project.mainVideoTrack!.clips.first;

      final success = notifier.replaceClipSource(
        clip.id,
        newPath: '/storage/emulated/0/DCIM/NewFootage.mp4',
        newName: 'NewFootage.mp4',
      );

      expect(success, isTrue);
      final updated = notifier.state.project.findClipById(clip.id);
      expect(updated!.sourcePath, '/storage/emulated/0/DCIM/NewFootage.mp4');
      expect(updated.name, 'NewFootage.mp4');
    });

    test('toggleClipReverse toggles reverse playback flag', () {
      final notifier = TimelineNotifier();
      final clip = notifier.state.project.mainVideoTrack!.clips.first;
      expect(clip.isReversed, isFalse);

      notifier.toggleClipReverse(clip.id);
      expect(notifier.state.project.findClipById(clip.id)!.isReversed, isTrue);

      notifier.toggleClipReverse(clip.id);
      expect(notifier.state.project.findClipById(clip.id)!.isReversed, isFalse);
    });

    test('updateCanvasBackground updates project canvas color and blur', () {
      final notifier = TimelineNotifier();
      notifier.updateCanvasBackground(color: 0xFFFF2D55, blur: 12.0);

      expect(notifier.state.project.canvasColor, 0xFFFF2D55);
      expect(notifier.state.project.canvasBlur, 12.0);
    });

    testWidgets('CanvasBackgroundSheet allows color and blur selection', (tester) async {
      int? changedColor;
      double? changedBlur;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CanvasBackgroundSheet.show(
                    context: context,
                    initialColor: null,
                    initialBlur: 0.0,
                    onColorChanged: (c) => changedColor = c,
                    onBlurChanged: (b) => changedBlur = b,
                  );
                },
                child: const Text('Open Canvas'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Canvas'));
      await tester.pumpAndSettle();

      expect(find.text('Latar Belakang Kanvas'), findsOneWidget);
      expect(find.text('WARNA LATAR'), findsOneWidget);
      expect(find.text('BLUR LATAR BELAKANG'), findsOneWidget);

      // Select Sedang blur
      await tester.tap(find.text('Sedang'));
      await tester.pumpAndSettle();
      expect(changedBlur, 10.0);
      expect(changedColor, isNull);
    });

    testWidgets('VoiceoverRecorderSheet renders mic and start position', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  VoiceoverRecorderSheet.show(
                    context: context,
                    startPosition: const Duration(seconds: 4),
                    onSaveVoiceover: (t, d) {},
                  );
                },
                child: const Text('Record Voice'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Record Voice'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Rekam Suara (Voiceover)'), findsOneWidget);
      expect(find.textContaining('00:04.0'), findsOneWidget);
      expect(find.text('Ketuk mikrofon untuk mulai merekam'), findsOneWidget);
    });
  });
}
