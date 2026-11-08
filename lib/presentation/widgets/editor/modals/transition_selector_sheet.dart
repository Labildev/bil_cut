import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/clip_transition.dart';

class TransitionSelectorSheet extends StatefulWidget {
  final ClipTransition? initialTransition;
  final Function(ClipTransition? transition, bool applyToAll) onSave;

  const TransitionSelectorSheet({
    super.key,
    this.initialTransition,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    ClipTransition? initialTransition,
    required Function(ClipTransition? transition, bool applyToAll) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TransitionSelectorSheet(
        initialTransition: initialTransition,
        onSave: onSave,
      ),
    );
  }

  @override
  State<TransitionSelectorSheet> createState() => _TransitionSelectorSheetState();
}

class _TransitionSelectorSheetState extends State<TransitionSelectorSheet> {
  late TransitionType _selectedType;
  late double _durationSeconds;
  bool _applyToAll = false;

  final List<Map<String, dynamic>> _transitions = [
    {'type': TransitionType.none, 'name': 'Tidak Ada', 'icon': LucideIcons.ban},
    {'type': TransitionType.dissolve, 'name': 'Dissolve', 'icon': LucideIcons.sparkles},
    {'type': TransitionType.fadeToBlack, 'name': 'Fade Hitam', 'icon': LucideIcons.moon},
    {'type': TransitionType.slideLeft, 'name': 'Geser Kiri', 'icon': LucideIcons.arrowLeft},
    {'type': TransitionType.slideRight, 'name': 'Geser Kanan', 'icon': LucideIcons.arrowRight},
    {'type': TransitionType.zoomIn, 'name': 'Zoom In', 'icon': LucideIcons.zoomIn},
    {'type': TransitionType.glitch, 'name': 'Glitch', 'icon': LucideIcons.zap},
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialTransition?.type ?? TransitionType.dissolve;
    _durationSeconds = (widget.initialTransition?.duration.inMilliseconds ?? 500) / 1000.0;
  }

  void _handleSave() {
    if (_selectedType == TransitionType.none) {
      widget.onSave(null, _applyToAll);
    } else {
      final transition = ClipTransition(
        type: _selectedType,
        duration: Duration(milliseconds: (_durationSeconds * 1000).round()),
      );
      widget.onSave(transition, _applyToAll);
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
                  'Transisi Klip',
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

            // Grid of Transitions
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _transitions.length,
                itemBuilder: (context, index) {
                  final t = _transitions[index];
                  final type = t['type'] as TransitionType;
                  final isSelected = type == _selectedType;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = type;
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
                            t['icon'] as IconData,
                            size: 26,
                            color: isSelected ? AppColors.primary : Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t['name'] as String,
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
            if (_selectedType != TransitionType.none) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Durasi Transisi:',
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
                  overlayColor: AppColors.primary.withValues(alpha: 0.2),
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
              const SizedBox(height: 8),
            ],

            // Apply to all clips toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Terapkan ke Semua Transisi',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
                Switch(
                  value: _applyToAll,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _applyToAll = val;
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
