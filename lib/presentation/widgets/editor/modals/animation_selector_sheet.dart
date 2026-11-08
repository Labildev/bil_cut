import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/clip_animation.dart';

class AnimationSelectorSheet extends StatefulWidget {
  final ClipAnimation? initialAnimation;
  final ValueChanged<ClipAnimation?> onAnimationSelected;

  const AnimationSelectorSheet({
    super.key,
    this.initialAnimation,
    required this.onAnimationSelected,
  });

  static Future<void> show({
    required BuildContext context,
    ClipAnimation? initialAnimation,
    required ValueChanged<ClipAnimation?> onAnimationSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AnimationSelectorSheet(
        initialAnimation: initialAnimation,
        onAnimationSelected: onAnimationSelected,
      ),
    );
  }

  @override
  State<AnimationSelectorSheet> createState() => _AnimationSelectorSheetState();
}

class _AnimationSelectorSheetState extends State<AnimationSelectorSheet> {
  late AnimationPreset _selectedIn;
  late double _durationSeconds;

  final List<Map<String, dynamic>> _presets = [
    {'preset': AnimationPreset.none, 'name': 'Tidak Ada', 'icon': LucideIcons.ban},
    {'preset': AnimationPreset.fadeIn, 'name': 'Pudar Masuk', 'icon': LucideIcons.eye},
    {'preset': AnimationPreset.slideUp, 'name': 'Geser Naik', 'icon': LucideIcons.arrowUp},
    {'preset': AnimationPreset.slideRight, 'name': 'Geser Kanan', 'icon': LucideIcons.arrowRight},
    {'preset': AnimationPreset.zoomIn, 'name': 'Perbesar', 'icon': LucideIcons.zoomIn},
    {'preset': AnimationPreset.pop, 'name': 'Pop Up', 'icon': LucideIcons.sparkles},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIn = widget.initialAnimation?.inAnimation ?? AnimationPreset.fadeIn;
    _durationSeconds =
        (widget.initialAnimation?.inDuration.inMilliseconds ?? 500) / 1000.0;
  }

  void _handleSave() {
    if (_selectedIn == AnimationPreset.none) {
      widget.onAnimationSelected(null);
    } else {
      widget.onAnimationSelected(
        ClipAnimation(
          inAnimation: _selectedIn,
          inDuration: Duration(milliseconds: (_durationSeconds * 1000).round()),
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                  'Animasi Klip (In Animation)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _handleSave,
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
            const SizedBox(height: 16),

            // Animation Presets
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                itemBuilder: (context, index) {
                  final item = _presets[index];
                  final preset = item['preset'] as AnimationPreset;
                  final isSelected = preset == _selectedIn;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIn = preset;
                      });
                    },
                    child: Container(
                      width: 76,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 24,
                            color: isSelected ? AppColors.primary : Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Duration Slider
            if (_selectedIn != AnimationPreset.none) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Durasi Animasi:',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${_durationSeconds.toStringAsFixed(1)}s',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surfaceLight,
                  thumbColor: Colors.white,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _durationSeconds.clamp(0.2, 2.0),
                  min: 0.2,
                  max: 2.0,
                  onChanged: (val) {
                    setState(() {
                      _durationSeconds = val;
                    });
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
