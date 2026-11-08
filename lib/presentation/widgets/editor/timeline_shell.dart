import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';

class TimelineShell extends StatelessWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final VoidCallback onPlayPauseToggle;
  final VoidCallback onSplit;
  final VoidCallback onAddMedia;
  final ValueChanged<Duration>? onSeek;

  const TimelineShell({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
    required this.onPlayPauseToggle,
    required this.onSplit,
    required this.onAddMedia,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.timelineBackground,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        children: [
          // 1. Mini Control Bar (Play, Split, Durations)
          _buildMiniControlBar(),

          // 2. Timeline Canvas (Ruler + Tracks + Playhead)
          Expanded(
            child: Stack(
              children: [
                // Scrollable Tracks Area
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 160),
                  child: SizedBox(
                    width: 1200, // Placeholder timeline width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Ruler
                        _buildTimeRuler(),

                        const SizedBox(height: 6),

                        // Main Video Track
                        _buildVideoTrack(),

                        const SizedBox(height: 10),

                        // Audio Track ("+ Tambahkan audio")
                        _buildAudioTrack(),

                        const SizedBox(height: 8),

                        // Text Track ("+ Tambahkan teks")
                        _buildTextTrack(),
                      ],
                    ),
                  ),
                ),

                // Fixed Centered Red Playhead Indicator
                Center(
                  child: _buildPlayhead(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniControlBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // Play / Pause button
          GestureDetector(
            onTap: onPlayPauseToggle,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? LucideIcons.pause : LucideIcons.play,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Split button shortcut
          GestureDetector(
            onTap: onSplit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.split, size: 13, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Bagi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Mute main track button
          IconButton(
            icon: const Icon(LucideIcons.volume2, size: 18, color: AppColors.textSecondary),
            onPressed: () {},
            tooltip: 'Bisukan audio klip',
          ),

          // Cover / Sampul video
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.image, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Sampul',
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRuler() {
    return Container(
      height: 24,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: List.generate(24, (index) {
          final seconds = index;
          return SizedBox(
            width: 50,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 2,
                  child: Text(
                    '00:${seconds.toString().padLeft(2, '0')}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 1,
                    height: 6,
                    color: AppColors.textMuted,
                  ),
                ),
                // Intermediate tick marks
                Positioned(
                  left: 25,
                  bottom: 0,
                  child: Container(
                    width: 1,
                    height: 3,
                    color: AppColors.divider,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVideoTrack() {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          // Sample Clip 1
          _buildClipCard(
            title: 'Klip 01.mp4',
            width: 220,
            color: AppColors.clipVideo,
            borderColor: AppColors.primary,
            hasTrimHandles: true,
          ),
          const SizedBox(width: 4),
          // Sample Clip 2
          _buildClipCard(
            title: 'Klip 02.mp4',
            width: 180,
            color: AppColors.clipVideo,
            borderColor: AppColors.borderLight,
            hasTrimHandles: false,
          ),
          const SizedBox(width: 8),
          // Add clip button
          GestureDetector(
            onTap: onAddMedia,
            child: Container(
              width: 50,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipCard({
    required String title,
    required double width,
    required Color color,
    required Color borderColor,
    required bool hasTrimHandles,
  }) {
    return Container(
      width: width,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: hasTrimHandles ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Thumbnails strip representation
          Row(
            children: List.generate((width ~/ 40), (i) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          // Clip Title Overlay
          Positioned(
            left: 12,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Trim Handles (Left & Right)
          if (hasTrimHandles) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 14,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
                ),
                child: const Center(
                  child: Icon(Icons.drag_indicator, size: 10, color: Colors.black),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 14,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                ),
                child: const Center(
                  child: Icon(Icons.drag_indicator, size: 10, color: Colors.black),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioTrack() {
    return Container(
      height: 38,
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.music, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Text(
            '+ Tambahkan audio',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTrack() {
    return Container(
      height: 38,
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.type, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Text(
            '+ Tambahkan teks',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayhead() {
    return IgnorePointer(
      child: Column(
        children: [
          // Needle head triangle
          CustomPaint(
            size: const Size(12, 10),
            painter: _PlayheadHeadPainter(color: AppColors.playhead),
          ),
          // Vertical needle line
          Expanded(
            child: Container(
              width: 2,
              color: AppColors.playhead,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayheadHeadPainter extends CustomPainter {
  final Color color;

  _PlayheadHeadPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
