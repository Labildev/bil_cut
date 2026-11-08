import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';

class PlayerViewport extends StatelessWidget {
  final String aspectRatio; // '9:16', '16:9', '1:1', '4:5'
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final VideoPlayerController? videoController;
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Live VideoPlayer if initialized, otherwise sleek placeholder
                    if (hasActiveVideo)
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: videoController!.value.size.width,
                            height: videoController!.value.size.height,
                            child: VideoPlayer(videoController!),
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

                    // Tap to play/pause hit area
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
}
