import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/timeline_clip.dart';

class TimelineClipWidget extends StatelessWidget {
  final TimelineClip clip;
  final double pixelsPerSecond;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<Duration> onTrimStart;
  final ValueChanged<Duration> onTrimEnd;

  const TimelineClipWidget({
    super.key,
    required this.clip,
    required this.pixelsPerSecond,
    required this.isSelected,
    required this.onTap,
    required this.onTrimStart,
    required this.onTrimEnd,
  });

  Color _getClipBackgroundColor() {
    switch (clip.type) {
      case ClipType.video:
        return AppColors.clipVideo;
      case ClipType.audio:
        return AppColors.clipAudio;
      case ClipType.text:
        return AppColors.clipText;
      case ClipType.overlay:
        return AppColors.clipEffect;
    }
  }

  Color _getClipBorderColor() {
    if (isSelected) return AppColors.primary;
    switch (clip.type) {
      case ClipType.video:
        return AppColors.clipVideoBorder;
      case ClipType.audio:
        return AppColors.clipAudioBorder;
      case ClipType.text:
        return AppColors.clipTextBorder;
      case ClipType.overlay:
        return AppColors.clipEffectBorder;
    }
  }

  double get clipWidth {
    final w = (clip.duration.inMilliseconds / 1000.0) * pixelsPerSecond;
    return w.clamp(32.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final width = clipWidth;
    final isCompact = clip.type != ClipType.video;
    final height = isCompact ? 36.0 : 58.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _getClipBackgroundColor(),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _getClipBorderColor(),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              // Visual Body (Thumbnails for video / Waveform for audio / Text preview)
              Positioned.fill(
                child: _buildClipBody(isCompact),
              ),

              // Title Badge
              Positioned(
                left: isSelected ? 16 : 6,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    clip.textContent ?? clip.name,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Visual badge indicators (Transition / Filter / Animation)
              if (clip.transition != null ||
                  !clip.adjustments.isDefault ||
                  clip.animation != null)
                Positioned(
                  left: isSelected ? 16 : 6,
                  bottom: 4,
                  child: Row(
                    children: [
                      if (clip.transition != null)
                        Container(
                          margin: const EdgeInsets.only(right: 3),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            '⧓',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (!clip.adjustments.isDefault)
                        Container(
                          margin: const EdgeInsets.only(right: 3),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'FX',
                            style: TextStyle(
                              fontSize: 7,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (clip.animation != null)
                        Container(
                          margin: const EdgeInsets.only(right: 3),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBF5AF2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'ANIM',
                            style: TextStyle(
                              fontSize: 7,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (clip.isReversed)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'REV',
                            style: TextStyle(
                              fontSize: 7,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Left Trim Handle (Head)
              if (isSelected)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      final deltaSeconds = details.delta.dx / pixelsPerSecond;
                      final deltaMs = (deltaSeconds * 1000).round();
                      final newStart = clip.timelineStart + Duration(milliseconds: deltaMs);
                      onTrimStart(newStart);
                    },
                    child: Container(
                      width: 14,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
                      ),
                      child: const Center(
                        child: Icon(Icons.drag_indicator, size: 10, color: Colors.black),
                      ),
                    ),
                  ),
                ),

              // Right Trim Handle (Tail)
              if (isSelected)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      final deltaSeconds = details.delta.dx / pixelsPerSecond;
                      final deltaMs = (deltaSeconds * 1000).round();
                      final newEnd = clip.timelineEnd + Duration(milliseconds: deltaMs);
                      onTrimEnd(newEnd);
                    },
                    child: Container(
                      width: 14,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
                      ),
                      child: const Center(
                        child: Icon(Icons.drag_indicator, size: 10, color: Colors.black),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClipBody(bool isCompact) {
    if (clip.type == ClipType.audio) {
      // Audio Waveform representation
      return CustomPaint(
        painter: _AudioWaveformPainter(color: Colors.white.withValues(alpha: 0.2)),
      );
    } else if (clip.type == ClipType.text) {
      return Center(
        child: Text(
          clip.textContent ?? 'Teks',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      );
    } else {
      // Video Thumbnails representation
      return Row(
        children: List.generate((clipWidth / 42).ceil(), (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          );
        }),
      );
    }
  }
}

class _AudioWaveformPainter extends CustomPainter {
  final Color color;

  _AudioWaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barSpacing = 4.0;
    final barCount = (size.width / barSpacing).floor();

    for (int i = 0; i < barCount; i++) {
      final x = i * barSpacing;
      // Procedural pseudo-waveform pattern
      final factor = ((i * 7) % 10) / 10.0;
      final barHeight = 6.0 + factor * (size.height - 12.0);
      final yStart = (size.height - barHeight) / 2.0;

      canvas.drawLine(
        Offset(x, yStart),
        Offset(x, yStart + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

