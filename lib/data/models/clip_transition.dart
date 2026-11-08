import 'package:flutter/foundation.dart';

enum TransitionType {
  none,
  dissolve,
  fadeToBlack,
  slideLeft,
  slideRight,
  zoomIn,
  glitch,
}

@immutable
class ClipTransition {
  final TransitionType type;
  final Duration duration;

  const ClipTransition({
    this.type = TransitionType.dissolve,
    this.duration = const Duration(milliseconds: 500),
  });

  String get displayName {
    switch (type) {
      case TransitionType.none:
        return 'Tidak Ada';
      case TransitionType.dissolve:
        return 'Dissolve';
      case TransitionType.fadeToBlack:
        return 'Fade to Black';
      case TransitionType.slideLeft:
        return 'Slide Kiri';
      case TransitionType.slideRight:
        return 'Slide Kanan';
      case TransitionType.zoomIn:
        return 'Zoom In';
      case TransitionType.glitch:
        return 'Glitch';
    }
  }

  ClipTransition copyWith({
    TransitionType? type,
    Duration? duration,
  }) {
    return ClipTransition(
      type: type ?? this.type,
      duration: duration ?? this.duration,
    );
  }
}
