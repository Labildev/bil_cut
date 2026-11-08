import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/color_adjustments.dart';
import '../../../data/models/timeline_clip.dart';

class PlayerViewport extends StatelessWidget {
  final String aspectRatio; // '9:16', '16:9', '1:1', '4:5'
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final VideoPlayerController? videoController;
  final ColorAdjustments? activeAdjustments;
  final List<TimelineClip> activeTextClips;
  final List<TimelineClip> activeOverlayClips;
  final VoidCallback onPlayPauseToggle;
  final VoidCallback onFullscreenToggle;
  final VoidCallback onAspectRatioToggle;

  const PlayerViewport({
    super.key,
    this.aspectRatio = '9:16',
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
    this.videoController,
    this.activeAdjustments,
    this.activeTextClips = const [],
    this.activeOverlayClips = const [],
    required this.onPlayPauseToggle,
    required this.onFullscreenToggle,
    required this.onAspectRatioToggle,
  });

  double _getAspectRatioValue() {
    switch (aspectRatio) {
      case '16:9':
        return 16 / 9;
      case '1:1':
        return 1.0;
      case '4:5':
        return 4 / 5;
      case '2.35:1':
        return 2.35;
      case '9:16':
      default:
        return 9 / 16;
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$minutes:$seconds.$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    final ratioValue = _getAspectRatioValue();
    final hasActiveVideo =
        videoController != null && videoController!.value.isInitialized;

    return Container(
      color: AppColors.viewportBackground,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video Frame Canvas
          Center(
            child: AspectRatio(
              aspectRatio: ratioValue,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF18181A),
                  border: Border.all(
                    color: AppColors.borderLight.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: ClipRect(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. Live VideoPlayer if initialized, otherwise sleek placeholder
                      if (hasActiveVideo)
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: videoController!.value.size.width,
                              height: videoController!.value.size.height,
                              child: activeAdjustments != null &&
                                      !activeAdjustments!.isDefault
                                  ? ColorFiltered(
                                      colorFilter: ColorFilter.matrix(
                                        activeAdjustments!.toColorFilterMatrix(),
                                      ),
                                      child: VideoPlayer(videoController!),
                                    )
                                  : VideoPlayer(videoController!),
                            ),
                          ),
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.clapperboard,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Preview Video',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                      // 2. Picture-in-Picture (PIP / Overlay) layer
                      ...activeOverlayClips.map((overlayClip) {
                        return _buildOverlayWidget(overlayClip);
                      }),

                      // 3. Text Overlays layer
                      ...activeTextClips.map((textClip) {
                        return _buildTextOverlayWidget(textClip);
                      }),

                      // 4. Tap to play/pause hit area
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onPlayPauseToggle,
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: isPlaying ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    LucideIcons.play,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Bar Overlays (Timecodes, Aspect ratio, Fullscreen)
          Positioned(
            left: 12,
            right: 12,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timestamp Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_formatDuration(currentPosition)} / ${_formatDuration(totalDuration)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Controls: Ratio & Fullscreen
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAspectRatioToggle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.aspect_ratio, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              aspectRatio,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onFullscreenToggle,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          LucideIcons.maximize2,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayWidget(TimelineClip clip) {
    final hasSource = clip.sourcePath != null && File(clip.sourcePath!).existsSync();

    return Align(
      alignment: Alignment(clip.positionX, clip.positionY),
      child: Transform.scale(
        scale: clip.scale,
        child: Opacity(
          opacity: clip.opacity.clamp(0.0, 1.0),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: hasSource
                  ? Image.file(File(clip.sourcePath!), fit: BoxFit.cover)
                  : const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.layers, size: 28, color: AppColors.primary),
                          SizedBox(height: 4),
                          Text(
                            'PIP Overlay',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextOverlayWidget(TimelineClip clip) {
    TextStyle style;
    try {
      style = GoogleFonts.getFont(
        clip.fontFamily,
        fontSize: clip.fontSize,
        color: Color(clip.textColorValue),
        fontWeight: FontWeight.w700,
        shadows: clip.hasTextShadow
            ? [
                const Shadow(
                  color: Colors.black,
                  offset: Offset(1.5, 1.5),
                  blurRadius: 4,
                ),
              ]
            : null,
      );
    } catch (_) {
      style = TextStyle(
        fontSize: clip.fontSize,
        color: Color(clip.textColorValue),
        fontWeight: FontWeight.w700,
      );
    }

    return Align(
      alignment: Alignment(clip.positionX, clip.positionY),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: clip.textBackgroundColorValue != null
            ? BoxDecoration(
                color: Color(clip.textBackgroundColorValue!),
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        child: Text(
          clip.textContent ?? clip.name,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
