import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';

enum EditorToolType {
  // Main tools
  edit,
  audio,
  text,
  overlay,
  effects,
  filters,
  format,
  canvas,
  adjust,

  // Clip sub-tools
  split,
  speed,
  volume,
  animation,
  delete,
  extractAudio,
  replace,
  duplicate,
  rotate,
  reverse,
}

class BottomToolbar extends StatelessWidget {
  final bool isClipSelected;
  final Function(EditorToolType) onToolSelected;

  const BottomToolbar({
    super.key,
    required this.isClipSelected,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: isClipSelected ? _buildClipSelectedTools() : _buildMainTools(),
    );
  }

  Widget _buildMainTools() {
    final tools = [
      {'type': EditorToolType.edit, 'label': 'Edit', 'icon': LucideIcons.scissors},
      {'type': EditorToolType.audio, 'label': 'Audio', 'icon': LucideIcons.music},
      {'type': EditorToolType.text, 'label': 'Teks', 'icon': LucideIcons.type},
      {'type': EditorToolType.overlay, 'label': 'Overlay', 'icon': LucideIcons.layers},
      {'type': EditorToolType.effects, 'label': 'Efek', 'icon': LucideIcons.sparkles},
      {'type': EditorToolType.filters, 'label': 'Filter', 'icon': LucideIcons.sliders},
      {'type': EditorToolType.format, 'label': 'Format', 'icon': Icons.aspect_ratio},
      {'type': EditorToolType.canvas, 'label': 'Kanvas', 'icon': LucideIcons.palette},
      {'type': EditorToolType.adjust, 'label': 'Sesuaikan', 'icon': LucideIcons.sunMedium},
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return _buildToolItem(
          icon: tool['icon'] as IconData,
          label: tool['label'] as String,
          onTap: () => onToolSelected(tool['type'] as EditorToolType),
        );
      },
    );
  }

  Widget _buildClipSelectedTools() {
    final tools = [
      {'type': EditorToolType.split, 'label': 'Bagi', 'icon': LucideIcons.split, 'highlight': true},
      {'type': EditorToolType.speed, 'label': 'Kecepatan', 'icon': LucideIcons.gauge},
      {'type': EditorToolType.volume, 'label': 'Volume', 'icon': LucideIcons.volume2},
      {'type': EditorToolType.animation, 'label': 'Animasi', 'icon': LucideIcons.wand2},
      {'type': EditorToolType.delete, 'label': 'Hapus', 'icon': LucideIcons.trash2, 'isDestructive': true},
      {'type': EditorToolType.extractAudio, 'label': 'Ekstrak Audio', 'icon': LucideIcons.disc},
      {'type': EditorToolType.replace, 'label': 'Ganti', 'icon': LucideIcons.refreshCw},
      {'type': EditorToolType.duplicate, 'label': 'Salin', 'icon': LucideIcons.copy},
      {'type': EditorToolType.rotate, 'label': 'Putar', 'icon': LucideIcons.rotateCw},
      {'type': EditorToolType.reverse, 'label': 'Balik', 'icon': LucideIcons.rewind},
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        final isDestructive = tool['isDestructive'] == true;
        final highlight = tool['highlight'] == true;

        return _buildToolItem(
          icon: tool['icon'] as IconData,
          label: tool['label'] as String,
          color: isDestructive
              ? AppColors.error
              : highlight
                  ? AppColors.primary
                  : Colors.white,
          onTap: () => onToolSelected(tool['type'] as EditorToolType),
        );
      },
    );
  }

  Widget _buildToolItem({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 62,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color == AppColors.error ? AppColors.error : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
