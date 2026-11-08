import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class CanvasBackgroundSheet extends StatefulWidget {
  final int? initialColor;
  final double initialBlur;
  final ValueChanged<int?> onColorChanged;
  final ValueChanged<double> onBlurChanged;

  const CanvasBackgroundSheet({
    super.key,
    this.initialColor,
    this.initialBlur = 0.0,
    required this.onColorChanged,
    required this.onBlurChanged,
  });

  static Future<void> show({
    required BuildContext context,
    required int? initialColor,
    required double initialBlur,
    required ValueChanged<int?> onColorChanged,
    required ValueChanged<double> onBlurChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CanvasBackgroundSheet(
        initialColor: initialColor,
        initialBlur: initialBlur,
        onColorChanged: onColorChanged,
        onBlurChanged: onBlurChanged,
      ),
    );
  }

  @override
  State<CanvasBackgroundSheet> createState() => _CanvasBackgroundSheetState();
}

class _CanvasBackgroundSheetState extends State<CanvasBackgroundSheet> {
  late int? _selectedColor;
  late double _selectedBlur;

  final List<Map<String, dynamic>> _canvasColors = [
    {'name': 'Default', 'value': null},
    {'name': 'Hitam Pekat', 'value': 0xFF000000},
    {'name': 'Abu Gelap', 'value': 0xFF1C1C1E},
    {'name': 'Putih Bersih', 'value': 0xFFFFFFFF},
    {'name': 'Merah CapCut', 'value': 0xFFFF2D55},
    {'name': 'Cyan Neon', 'value': 0xFF00F0FF},
    {'name': 'Kuning Sunset', 'value': 0xFFFFD60A},
    {'name': 'Ungu Violet', 'value': 0xFFBF5AF2},
    {'name': 'Hijau Emerald', 'value': 0xFF30D158},
    {'name': 'Biru Laut Dalam', 'value': 0xFF0A84FF},
    {'name': 'Cokelat Estetik', 'value': 0xFF795548},
  ];

  final List<Map<String, dynamic>> _blurOptions = [
    {'name': 'Tanpa Blur', 'value': 0.0},
    {'name': 'Ringan', 'value': 4.0},
    {'name': 'Sedang', 'value': 10.0},
    {'name': 'Kuat', 'value': 20.0},
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _selectedBlur = widget.initialBlur;
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
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.palette, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Latar Belakang Kanvas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.check, color: AppColors.primary, size: 22),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Terapkan',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Color Palette Selector
            const Text(
              'WARNA LATAR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _canvasColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = _canvasColors[index];
                  final colorVal = item['value'] as int?;
                  final isSelected = _selectedColor == colorVal;

                  if (colorVal == null) {
                    // Default None button
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedColor = null);
                        widget.onColorChanged(null);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2.5 : 1.0,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.ban,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                    );
                  }

                  final color = Color(colorVal);
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = colorVal);
                      widget.onColorChanged(colorVal);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.white24,
                          width: isSelected ? 2.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              LucideIcons.check,
                              size: 18,
                              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 2. Blur Intensity Options
            const Text(
              'BLUR LATAR BELAKANG',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: _blurOptions.map((opt) {
                final blurVal = opt['value'] as double;
                final isSelected = (_selectedBlur - blurVal).abs() < 0.5;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedBlur = blurVal);
                        widget.onBlurChanged(blurVal);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                        child: Text(
                          opt['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
