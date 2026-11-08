import 'package:flutter_test/flutter_test.dart';
import 'package:bil_cut/data/models/clip_animation.dart';
import 'package:bil_cut/data/models/clip_transition.dart';
import 'package:bil_cut/data/models/color_adjustments.dart';
import 'package:bil_cut/logic/timeline/timeline_notifier.dart';

void main() {
  group('Timeline Effects, Filters & Transitions Tests', () {
    test('Set clip transition with applyToAll updates clips', () {
      final notifier = TimelineNotifier();

      const transition = ClipTransition(
        type: TransitionType.dissolve,
        duration: Duration(milliseconds: 600),
      );

      notifier.setClipTransition('clip-demo-1', transition, applyToAll: true);

      final mainTrack = notifier.state.project.mainVideoTrack!;
      for (final clip in mainTrack.clips) {
        expect(clip.transition, isNotNull);
        expect(clip.transition!.type, TransitionType.dissolve);
        expect(clip.transition!.duration, const Duration(milliseconds: 600));
      }
    });

    test('ColorAdjustments matrix calculation generates valid 20-element 4x5 matrix', () {
      const adjustments = ColorAdjustments(
        preset: FilterPreset.cyberpunk,
        brightness: 0.2,
        contrast: 1.2,
        saturation: 1.5,
        warmth: 0.3,
      );

      final matrix = adjustments.toColorFilterMatrix();
      expect(matrix.length, 20);
      expect(adjustments.isDefault, false);
    });

    test('Set clip color adjustments updates clip', () {
      final notifier = TimelineNotifier();

      const adjustments = ColorAdjustments(
        preset: FilterPreset.noir,
        brightness: -0.1,
        contrast: 1.3,
      );

      notifier.setClipAdjustments('clip-demo-1', adjustments);

      final clip = notifier.state.project.findClipById('clip-demo-1')!;
      expect(clip.adjustments.preset, FilterPreset.noir);
      expect(clip.adjustments.brightness, -0.1);
      expect(clip.adjustments.contrast, 1.3);
    });

    test('Set clip in/out animation updates clip', () {
      final notifier = TimelineNotifier();

      const animation = ClipAnimation(
        inAnimation: AnimationPreset.zoomIn,
        inDuration: Duration(milliseconds: 700),
      );

      notifier.setClipAnimation('clip-demo-1', animation);

      final clip = notifier.state.project.findClipById('clip-demo-1')!;
      expect(clip.animation, isNotNull);
      expect(clip.animation!.inAnimation, AnimationPreset.zoomIn);
      expect(clip.animation!.inDuration, const Duration(milliseconds: 700));
      expect(clip.animation!.hasAnimation, true);
    });
  });
}

