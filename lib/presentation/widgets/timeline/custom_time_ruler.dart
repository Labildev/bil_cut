import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomTimeRuler extends StatelessWidget {
  final double pixelsPerSecond;
  final Duration totalDuration;
  final ValueChanged<Duration> onSeek;

  const CustomTimeRuler({
    super.key,
    required this.pixelsPerSecond,
    required this.totalDuration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = (totalDuration.inMilliseconds / 1000.0) * pixelsPerSecond;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final clickedX = details.localPosition.dx;
        final seconds = clickedX / pixelsPerSecond;
        final targetMs = (seconds * 1000).round();
        onSeek(Duration(milliseconds: targetMs));
      },
      child: SizedBox(
        height: 28,
        width: totalWidth,
        child: CustomPaint(
          size: Size(totalWidth, 28),
          painter: _TimeRulerPainter(
            pixelsPerSecond: pixelsPerSecond,
            totalDuration: totalDuration,
          ),
        ),
      ),
    );
  }
}

class _TimeRulerPainter extends CustomPainter {
  final double pixelsPerSecond;
  final Duration totalDuration;

  _TimeRulerPainter({
    required this.pixelsPerSecond,
    required this.totalDuration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final majorTickPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 1.0;

    final minorTickPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Determine interval based on zoom scale
    final double majorIntervalSeconds;
    final int subDivisions;

    if (pixelsPerSecond < 35) {
      majorIntervalSeconds = 5.0;
      subDivisions = 5;
    } else if (pixelsPerSecond < 80) {
      majorIntervalSeconds = 1.0;
      subDivisions = 2; // 0.5s ticks
    } else if (pixelsPerSecond < 160) {
      majorIntervalSeconds = 1.0;
      subDivisions = 4; // 0.25s ticks
    } else {
      majorIntervalSeconds = 1.0;
      subDivisions = 10; // 0.1s ticks
    }

    final totalSeconds = totalDuration.inMilliseconds / 1000.0;
    final maxTicks = (totalSeconds / majorIntervalSeconds).ceil();

    for (int i = 0; i <= maxTicks; i++) {
      final currentSeconds = i * majorIntervalSeconds;
      final x = currentSeconds * pixelsPerSecond;

      if (x > size.width) break;

      // Draw major tick
      canvas.drawLine(
        Offset(x, size.height - 8),
        Offset(x, size.height),
        majorTickPaint,
      );

      // Draw time label
      final minutes = (currentSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (currentSeconds % 60).floor().toString().padLeft(2, '0');
      final labelText = '$minutes:$seconds';

      textPainter.text = TextSpan(
        text: labelText,
        style: const TextStyle(
          fontSize: 9,
          fontFamily: 'monospace',
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 3, 2));

      // Draw intermediate minor ticks
      final subIntervalWidth = (majorIntervalSeconds * pixelsPerSecond) / subDivisions;
      for (int s = 1; s < subDivisions; s++) {
        final subX = x + (s * subIntervalWidth);
        if (subX > size.width) break;

        final isHalf = (subDivisions % 2 == 0) && (s == subDivisions ~/ 2);
        final tickHeight = isHalf ? 5.0 : 3.0;

        canvas.drawLine(
          Offset(subX, size.height - tickHeight),
          Offset(subX, size.height),
          minorTickPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimeRulerPainter oldDelegate) {
    return oldDelegate.pixelsPerSecond != pixelsPerSecond ||
        oldDelegate.totalDuration != totalDuration;
  }
}

