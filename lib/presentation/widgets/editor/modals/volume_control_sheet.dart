import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/timeline_clip.dart';

class VolumeControlSheet extends StatefulWidget {
  final TimelineClip clip;
  final ValueChanged<double> onVolumeChanged;

  const VolumeControlSheet({
    super.key,
    required this.clip,
    required this.onVolumeChanged,
  });

  static Future<void> show({
    required BuildContext context,
    required TimelineClip clip,
    required ValueChanged<double> onVolumeChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => VolumeControlSheet(
        clip: clip,
        onVolumeChanged: onVolumeChanged,
      ),
    );
  }

  @override
  State<VolumeControlSheet> createState() => _VolumeControlSheetState();
}

class _VolumeControlSheetState extends State<VolumeControlSheet> {
  late double _currentVolume;

  @override
  void initState() {
    super.initState();
    _currentVolume = widget.clip.volume;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_currentVolume * 100).round();
    final isMuted = _currentVolume <= 0.01;

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
                  'Volume Klip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.onVolumeChanged(_currentVolume);
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

            // Volume readout & Mute Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentVolume = isMuted ? 1.0 : 0.0;
                    });
                    widget.onVolumeChanged(_currentVolume);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMuted ? AppColors.error.withValues(alpha: 0.2) : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isMuted ? AppColors.error : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      isMuted ? LucideIcons.volumeX : LucideIcons.volume2,
                      size: 22,
                      color: isMuted ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$percentage%',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: isMuted ? AppColors.textMuted : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Volume Slider (0% - 200%)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: Colors.white,
                overlayColor: AppColors.primary.withValues(alpha: 0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _currentVolume.clamp(0.0, 2.0),
                min: 0.0,
                max: 2.0,
                onChanged: (value) {
                  setState(() {
                    _currentVolume = value;
                  });
                  widget.onVolumeChanged(value);
                },
              ),
            ),
            const SizedBox(height: 8),

            // Standard presets (0%, 100%, 200%)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickPreset('0% (Bisukan)', 0.0),
                _buildQuickPreset('100% (Normal)', 1.0),
                _buildQuickPreset('200% (Maksimal)', 2.0),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPreset(String label, double value) {
    final isSelected = (_currentVolume - value).abs() < 0.05;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentVolume = value;
        });
        widget.onVolumeChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceLight : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
