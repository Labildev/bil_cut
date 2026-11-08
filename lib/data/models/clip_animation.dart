import 'package:flutter/foundation.dart';

enum AnimationPreset {
  none,
  fadeIn,
  slideUp,
  slideRight,
  zoomIn,
  pop,
}

@immutable
class ClipAnimation {
  final AnimationPreset inAnimation;
  final Duration inDuration;
  final AnimationPreset outAnimation;
  final Duration outDuration;

  const ClipAnimation({
    this.inAnimation = AnimationPreset.none,
    this.inDuration = const Duration(milliseconds: 500),
    this.outAnimation = AnimationPreset.none,
    this.outDuration = const Duration(milliseconds: 500),
  });

  bool get hasAnimation =>
      inAnimation != AnimationPreset.none || outAnimation != AnimationPreset.none;

  ClipAnimation copyWith({
    AnimationPreset? inAnimation,
    Duration? inDuration,
    AnimationPreset? outAnimation,
    Duration? outDuration,
  }) {
    return ClipAnimation(
      inAnimation: inAnimation ?? this.inAnimation,
      inDuration: inDuration ?? this.inDuration,
      outAnimation: outAnimation ?? this.outAnimation,
      outDuration: outDuration ?? this.outDuration,
    );
  }
}
