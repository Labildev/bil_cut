import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/timeline_clip.dart';
import '../../../data/models/timeline_track.dart';
import 'timeline_clip_widget.dart';

class TimelineTrackWidget extends StatelessWidget {
  final TimelineTrack track;
  final double pixelsPerSecond;
  final double totalWidth;
  final String? selectedClipId;
  final ValueChanged<String> onClipTap;
  final void Function(String clipId, Duration newStart) onTrimStart;
  final void Function(String clipId, Duration newEnd) onTrimEnd;
  final VoidCallback? onAddMedia;

  const TimelineTrackWidget({
    super.key,
    required this.track,
    required this.pixelsPerSecond,
    required this.totalWidth,
    required this.selectedClipId,
    required this.onClipTap,
    required this.onTrimStart,
    required this.onTrimEnd,
    this.onAddMedia,
  });

  IconData _getTrackIcon() {
    switch (track.type) {
      case ClipType.video:
        return LucideIcons.video;
      case ClipType.audio:
        return LucideIcons.music;
      case ClipType.text:
        return LucideIcons.type;
      case ClipType.overlay:
        return LucideIcons.layers;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = track.type != ClipType.video;
    final trackHeight = isCompact ? 38.0 : 60.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Track Header Badge (sticky on the left)
          Container(
            width: 32,
            height: trackHeight,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Icon(
                _getTrackIcon(),
                size: 14,
                color: track.isMuted ? AppColors.textMuted : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Scrollable Track Canvas with Positioned Clips
          SizedBox(
            width: totalWidth,
            height: trackHeight,
            child: Stack(
              children: [
                // Empty Track Lane Background
                Container(
                  width: totalWidth,
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                ),

                // Clips
                ...track.clips.map((clip) {
                  final left = (clip.timelineStart.inMilliseconds / 1000.0) * pixelsPerSecond;
                  final isSelected = clip.id == selectedClipId;

                  return Positioned(
                    left: left,
                    top: 1,
                    child: TimelineClipWidget(
                      clip: clip,
                      pixelsPerSecond: pixelsPerSecond,
                      isSelected: isSelected,
                      onTap: () => onClipTap(clip.id),
                      onTrimStart: (newStart) => onTrimStart(clip.id, newStart),
                      onTrimEnd: (newEnd) => onTrimEnd(clip.id, newEnd),
                    ),
                  );
                }),

                // Add button at the end of main video track
                if (track.isMainTrack && onAddMedia != null)
                  Positioned(
                    left: _calculateAddButtonLeft(),
                    top: 1,
                    child: GestureDetector(
                      onTap: onAddMedia,
                      child: Container(
                        width: 44,
                        height: trackHeight - 2,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.plus, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAddButtonLeft() {
    if (track.clips.isEmpty) return 0.0;
    final lastEnd = track.clips.map((c) => c.timelineEnd).reduce((a, b) => a > b ? a : b);
    return ((lastEnd.inMilliseconds / 1000.0) * pixelsPerSecond) + 8.0;
  }
}
