import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/timeline_clip.dart';

class TextEditorSheet extends StatefulWidget {
  final TimelineClip? initialClip;
  final Function({
    required String text,
    required String font,
    required int color,
    required int? backgroundColor,
    required bool hasShadow,
  }) onSave;

  const TextEditorSheet({
    super.key,
    this.initialClip,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    TimelineClip? initialClip,
    required Function({
      required String text,
      required String font,
      required int color,
      required int? backgroundColor,
      required bool hasShadow,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TextEditorSheet(
          initialClip: initialClip,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  State<TextEditorSheet> createState() => _TextEditorSheetState();
}

class _TextEditorSheetState extends State<TextEditorSheet> {
  late final TextEditingController _textController;
  late String _selectedFont;
  late int _selectedColor;
  int? _selectedBgColor;
  late bool _hasShadow;

  final List<String> _fonts = [
    'Inter',
    'Poppins',
    'Roboto',
    'Bebas Neue',
    'Montserrat',
    'Oswald',
  ];

  final List<int> _colors = [
    0xFFFFFFFF, // White
    0xFFFFEB3B, // Yellow
    0xFF00F0FF, // Cyan
    0xFFFF2D55, // Pink / Red
    0xFF30D158, // Green
    0xFFFF9500, // Orange
    0xFFBF5AF2, // Purple
    0xFF000000, // Black
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.initialClip?.textContent ?? '',
    );
    _selectedFont = widget.initialClip?.fontFamily ?? 'Inter';
    _selectedColor = widget.initialClip?.textColorValue ?? 0xFFFFFFFF;
    _selectedBgColor = widget.initialClip?.textBackgroundColorValue;
    _hasShadow = widget.initialClip?.hasTextShadow ?? true;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    widget.onSave(
      text: text,
      font: _selectedFont,
      color: _selectedColor,
      backgroundColor: _selectedBgColor,
      hasShadow: _hasShadow,
    );
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Teks',
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

            // Text Input Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _textController,
                autofocus: true,
                style: GoogleFonts.getFont(
                  _selectedFont,
                  color: Color(_selectedColor),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ketik teks di sini...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 16),

            // Font Selector
            const Text(
              'Font',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _fonts.length,
                itemBuilder: (context, index) {
                  final font = _fonts[index];
                  final isSelected = font == _selectedFont;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        font,
                        style: GoogleFonts.getFont(
                          font,
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFont = font;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Color Palette
            const Text(
              'Warna Teks',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _colors.map((colorValue) {
                final isSelected = colorValue == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorValue;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.white24,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            LucideIcons.check,
                            size: 14,
                            color: colorValue == 0xFFFFFFFF ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Styling Toggles (Background Highlight & Shadow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Highlight Box toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBgColor = _selectedBgColor == null ? 0xCC000000 : null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedBgColor != null ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.boxSelect,
                          size: 14,
                          color: _selectedBgColor != null ? Colors.black : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Background Box',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectedBgColor != null ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Shadow toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasShadow = !_hasShadow;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _hasShadow ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.sun,
                          size: 14,
                          color: _hasShadow ? Colors.black : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Bayangan Teks',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _hasShadow ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
