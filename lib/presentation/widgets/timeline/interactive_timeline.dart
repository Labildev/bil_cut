import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/timeline/timeline_notifier.dart';
import '../../../logic/timeline/timeline_state.dart';
import 'custom_time_ruler.dart';
import 'timeline_track_widget.dart';

class InteractiveTimeline extends ConsumerStatefulWidget {
  final VoidCallback onAddMedia;

  const InteractiveTimeline({
    super.key,
    required this.onAddMedia,
  });

  @override
  ConsumerState<InteractiveTimeline> createState() => _InteractiveTimelineState();
}

class _InteractiveTimelineState extends ConsumerState<InteractiveTimeline> {
  late final ScrollController _scrollController;
  bool _isUserScrolling = false;
  double _basePixelsPerSecond = 60.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScrollChanged);

    // Initial scroll position alignment after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScrollToPosition();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    if (!_isUserScrolling) return;

    final state = ref.read(timelineNotifierProvider);
    final offset = _scrollController.offset - 40.0;
    final time = state.pixelsToTime(offset.clamp(0.0, double.infinity));
    ref.read(timelineNotifierProvider.notifier).seekTo(time);
  }

  void _syncScrollToPosition() {
    if (!_scrollController.hasClients || _isUserScrolling) return;

    final state = ref.read(timelineNotifierProvider);
    final targetOffset = state.timeToPixels(state.currentPosition) + 40.0;
    if ((_scrollController.offset - targetOffset).abs() > 1.0) {
      _scrollController.jumpTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
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
    final state = ref.watch(timelineNotifierProvider);
    final notifier = ref.read(timelineNotifierProvider.notifier);

    // Sync scroll when position changes externally
    ref.listen(
      timelineNotifierProvider.select((s) => s.currentPosition),
      (prev, next) {
        if (!_isUserScrolling) {
          _syncScrollToPosition();
        }
      },
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.timelineBackground,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          // 1. Mini Action Bar
          _buildMiniActionBar(state, notifier),

          // 2. Timeline Canvas with Pinch to Zoom and Synchronized Scroll
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final centerPadding = constraints.maxWidth / 2.0;
                final totalWidth = state.totalTimelineWidthPixels;

                return GestureDetector(
                  onScaleStart: (details) {
                    _basePixelsPerSecond = state.pixelsPerSecond;
                  },
                  onScaleUpdate: (details) {
                    if (details.pointerCount >= 2) {
                      final newScale = _basePixelsPerSecond * details.scale;
                      notifier.setZoomScale(newScale);
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // NotificationListener to detect user drag
                      NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollStartNotification) {
                            _isUserScrolling = true;
                            notifier.setScrubbing(true);
                          } else if (notification is ScrollEndNotification) {
                            _isUserScrolling = false;
                            notifier.setScrubbing(false);
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: centerPadding),
                          child: SizedBox(
                            width: totalWidth + 40.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Time Ruler aligned with tracks
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: CustomTimeRuler(
                                    pixelsPerSecond: state.pixelsPerSecond,
                                    totalDuration: state.totalDuration,
                                    onSeek: (target) {
                                      notifier.seekTo(target);
                                      _syncScrollToPosition();
                                    },
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Multi-Tracks List
                                ...state.project.tracks.map((track) {
                                  return TimelineTrackWidget(
                                    track: track,
                                    pixelsPerSecond: state.pixelsPerSecond,
                                    totalWidth: totalWidth,
                                    selectedClipId: state.selectedClipId,
                                    onClipTap: (clipId) => notifier.selectClip(clipId),
                                    onTrimStart: (clipId, newStart) =>
                                        notifier.trimClipStart(clipId, newStart),
                                    onTrimEnd: (clipId, newEnd) =>
                                        notifier.trimClipEnd(clipId, newEnd),
                                    onAddMedia: track.isMainTrack ? widget.onAddMedia : null,
                                  );
                                }),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Fixed Centered Red Playhead Indicator
                      Positioned(
                        top: 0,
                        bottom: 0,
                        child: _buildPlayhead(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniActionBar(TimelineState state, TimelineNotifier notifier) {
    final hasSelectedClip = state.selectedClipId != null;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // Play / Pause Toggle
          GestureDetector(
            onTap: () => notifier.togglePlayPause(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isPlaying ? LucideIcons.pause : LucideIcons.play,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Timecode Readout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${_formatDuration(state.currentPosition)} / ${_formatDuration(state.totalDuration)}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Split button shortcut
          GestureDetector(
            onTap: () {
              if (hasSelectedClip) {
                final success = notifier.splitSelectedClip();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Klip berhasil dibagi pada playhead'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih klip terlebih dahulu untuk membagi'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: hasSelectedClip ? AppColors.primary : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.split,
                    size: 13,
                    color: hasSelectedClip ? Colors.black : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Bagi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasSelectedClip ? Colors.black : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Zoom Controls (- / +)
          IconButton(
            icon: const Icon(LucideIcons.minus, size: 16),
            onPressed: () => notifier.adjustZoomBy(0.8),
            tooltip: 'Zoom Out',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 16),
            onPressed: () => notifier.adjustZoomBy(1.25),
            tooltip: 'Zoom In',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          const SizedBox(width: 8),

          // Snapping Magnet Indicator
          GestureDetector(
            onTap: () {
              // Snapping is active by default
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: state.isSnappingEnabled
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: state.isSnappingEnabled ? AppColors.primary : AppColors.border,
                  width: 0.8,
                ),
              ),
              child: Icon(
                LucideIcons.magnet,
                size: 14,
                color: state.isSnappingEnabled ? AppColors.primary : AppColors.textMuted,
              ),
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
