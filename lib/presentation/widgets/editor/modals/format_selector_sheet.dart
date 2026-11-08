import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class FormatSelectorSheet extends StatelessWidget {
  final String currentRatio;
  final ValueChanged<String> onRatioSelected;

  const FormatSelectorSheet({
    super.key,
    required this.currentRatio,
    required this.onRatioSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String currentRatio,
    required ValueChanged<String> onRatioSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FormatSelectorSheet(
        currentRatio: currentRatio,
        onRatioSelected: onRatioSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formats = [
      {
        'ratio': '9:16',
        'title': '9:16',
        'desc': 'TikTok, Reels, Shorts',
        'width': 22.0,
        'height': 36.0,
      },
      {
        'ratio': '16:9',
        'title': '16:9',
        'desc': 'YouTube, TV, Horizontal',
        'width': 36.0,
        'height': 22.0,
      },
      {
        'ratio': '1:1',
        'title': '1:1',
        'desc': 'Instagram Square',
        'width': 28.0,
        'height': 28.0,
      },
      {
        'ratio': '4:5',
        'title': '4:5',
        'desc': 'Instagram Portrait',
        'width': 24.0,
        'height': 30.0,
      },
      {
        'ratio': '2.35:1',
        'title': '2.35:1',
        'desc': 'Cinematic Widescreen',
        'width': 40.0,
        'height': 17.0,
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Format Rasio Kanvas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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

            // Format List Grid
            ...formats.map((fmt) {
              final ratio = fmt['ratio'] as String;
              final isSelected = ratio == currentRatio;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      onRatioSelected(ratio);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          // Proportional representation box
                          Container(
                            width: 44,
                            height: 40,
                            alignment: Alignment.center,
                            child: Container(
                              width: fmt['width'] as double,
                              height: fmt['height'] as double,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.white60,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Ratio description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fmt['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? AppColors.primary : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  fmt['desc'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Radio indicator
                          if (isSelected)
                            const Icon(
                              LucideIcons.checkCircle2,
                              size: 18,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

