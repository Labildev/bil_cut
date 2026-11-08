import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/color_adjustments.dart';

class FilterAdjustmentSheet extends StatefulWidget {
  final ColorAdjustments initialAdjustments;
  final ValueChanged<ColorAdjustments> onAdjustmentsChanged;

  const FilterAdjustmentSheet({
    super.key,
    required this.initialAdjustments,
    required this.onAdjustmentsChanged,
  });

  static Future<void> show({
    required BuildContext context,
    required ColorAdjustments initialAdjustments,
    required ValueChanged<ColorAdjustments> onAdjustmentsChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterAdjustmentSheet(
        initialAdjustments: initialAdjustments,
        onAdjustmentsChanged: onAdjustmentsChanged,
      ),
    );
  }

  @override
  State<FilterAdjustmentSheet> createState() => _FilterAdjustmentSheetState();
}

class _FilterAdjustmentSheetState extends State<FilterAdjustmentSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ColorAdjustments _current;

  final List<Map<String, dynamic>> _presets = [
    {'preset': FilterPreset.original, 'name': 'Asli', 'color': Colors.grey},
    {'preset': FilterPreset.cyberpunk, 'name': 'Cyberpunk', 'color': const Color(0xFF00F0FF)},
    {'preset': FilterPreset.vintage, 'name': 'Vintage', 'color': const Color(0xFFD4A373)},
    {'preset': FilterPreset.warmGold, 'name': 'Warm Gold', 'color': const Color(0xFFFFB703)},
    {'preset': FilterPreset.coldBlue, 'name': 'Cold Blue', 'color': const Color(0xFF219EBC)},
    {'preset': FilterPreset.noir, 'name': 'Noir B&W', 'color': Colors.white},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _current = widget.initialAdjustments;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _update(ColorAdjustments updated) {
    setState(() {
      _current = updated;
    });
    widget.onAdjustmentsChanged(_current);
  }

  void _reset() {
    _update(const ColorAdjustments());
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
                  'Filter & Penyesuaian Warna',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _reset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
              ],
            ),
            const SizedBox(height: 12),

            // Tab Bar (Filter Preset vs Sesuaikan Manual)
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Filter Presets'),
                Tab(text: 'Sesuaikan (HSL)'),
              ],
            ),
            const SizedBox(height: 16),

            // Tab View
            SizedBox(
              height: 160,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Presets List
                  _buildPresetsView(),
                  // 2. Adjustments Sliders
                  _buildSlidersView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsView() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _presets.length,
      itemBuilder: (context, index) {
        final item = _presets[index];
        final preset = item['preset'] as FilterPreset;
        final isSelected = _current.preset == preset;

        return GestureDetector(
          onTap: () {
            _update(_current.copyWith(preset: preset));
          },
          child: Container(
            width: 76,
            margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (item['color'] as Color).withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(LucideIcons.check, size: 18, color: Colors.black)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  item['name'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlidersView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildSliderRow(
            label: 'Kecerahan',
            value: _current.brightness,
            min: -0.8,
            max: 0.8,
            onChanged: (val) => _update(_current.copyWith(brightness: val)),
          ),
          _buildSliderRow(
            label: 'Kontras',
            value: _current.contrast,
            min: 0.5,
            max: 1.5,
            onChanged: (val) => _update(_current.copyWith(contrast: val)),
          ),
          _buildSliderRow(
            label: 'Saturasi',
            value: _current.saturation,
            min: 0.0,
            max: 2.0,
            onChanged: (val) => _update(_current.copyWith(saturation: val)),
          ),
          _buildSliderRow(
            label: 'Suhu Warna (Warmth)',
            value: _current.warmth,
            min: -1.0,
            max: 1.0,
            onChanged: (val) => _update(_current.copyWith(warmth: val)),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: Colors.white,
                trackHeight: 3,
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              value.toStringAsFixed(1),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: Colors.white,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

