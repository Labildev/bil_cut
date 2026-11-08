import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/timeline_clip.dart';

class SpeedControlSheet extends StatefulWidget {
  final TimelineClip clip;
  final ValueChanged<double> onSpeedChanged;

  const SpeedControlSheet({
    super.key,
    required this.clip,
    required this.onSpeedChanged,
  });

  static Future<void> show({
    required BuildContext context,
    required TimelineClip clip,
    required ValueChanged<double> onSpeedChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SpeedControlSheet(
        clip: clip,
        onSpeedChanged: onSpeedChanged,
      ),
    );
  }

  @override
  State<SpeedControlSheet> createState() => _SpeedControlSheetState();
}

class _SpeedControlSheetState extends State<SpeedControlSheet> {
  late double _currentSpeed;
  bool _pitchChange = true;

  final List<double> _presets = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0];

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.clip.speed;
  }

  Duration _calculateNewDuration(double speed) {
    final sourceSpan = widget.clip.sourceOut - widget.clip.sourceIn;
    final ms = (sourceSpan.inMilliseconds / speed).round();
    return Duration(milliseconds: ms);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final tenths = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$minutes:$seconds.$tenths';
  }

  @override
  Widget build(BuildContext context) {
    final originalDuration = widget.clip.duration;
    final newDuration = _calculateNewDuration(_currentSpeed);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kecepatan Normal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.onSpeedChanged(_currentSpeed);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.check, size: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Speed multiplier readout
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _currentSpeed.toStringAsFixed(1),
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'x',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Presets row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presets.map((preset) {
                final isSelected = (_currentSpeed - preset).abs() < 0.05;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentSpeed = preset;
                    });
                    widget.onSpeedChanged(_currentSpeed);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '${preset}x',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Continuous Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: Colors.white,
                overlayColor: AppColors.primary.withValues(alpha: 0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _currentSpeed.clamp(0.1, 10.0),
                min: 0.1,
                max: 10.0,
                onChanged: (value) {
                  setState(() {
                    _currentSpeed = value;
                  });
                  widget.onSpeedChanged(value);
                },
              ),
            ),

            // Duration Comparison Preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Durasi Hasil:',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${_formatDuration(originalDuration)}  ➔  ${_formatDuration(newDuration)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Pitch Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ubah Nada Audio (Pitch)',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
                Switch(
                  value: _pitchChange,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _pitchChange = val;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
