import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';

class EditorHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback onExport;
  final String resolution;
  final ValueChanged<String>? onResolutionChanged;
  final bool canUndo;
  final bool canRedo;

  const EditorHeader({
    super.key,
    required this.onBack,
    this.onUndo,
    this.onRedo,
    required this.onExport,
    this.resolution = '1080P',
    this.onResolutionChanged,
    this.canUndo = false,
    this.canRedo = false,
  });

  void _showResolutionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resolusi & Kecepatan Bingkai',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Resolusi Ekspor',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['720P', '1080P', '2K/4K'].map((res) {
                    final isSelected = res == resolution;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(res),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            onResolutionChanged?.call(res);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // Close / Back button
          IconButton(
            icon: const Icon(LucideIcons.x, size: 22, color: Colors.white),
            onPressed: onBack,
            tooltip: 'Tutup',
          ),
          const SizedBox(width: 4),

          // Undo button
          IconButton(
            icon: Icon(
              LucideIcons.undo2,
              size: 20,
              color: canUndo ? Colors.white : AppColors.textMuted,
            ),
            onPressed: canUndo ? onUndo : null,
            tooltip: 'Undo',
          ),

          // Redo button
          IconButton(
            icon: Icon(
              LucideIcons.redo2,
              size: 20,
              color: canRedo ? Colors.white : AppColors.textMuted,
            ),
            onPressed: canRedo ? onRedo : null,
            tooltip: 'Redo',
          ),

          const Spacer(),

          // Resolution Pill
          GestureDetector(
            onTap: () => _showResolutionDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Text(
                    resolution,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.chevronDown,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Export Button
          GestureDetector(
            onTap: onExport,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.upload,
                    size: 14,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ekspor',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
