import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/export_config.dart';

class ExportSuccessDialog extends StatelessWidget {
  final String outputPath;
  final ExportConfig config;
  final Duration duration;

  const ExportSuccessDialog({
    super.key,
    required this.outputPath,
    required this.config,
    required this.duration,
  });

  static Future<void> show({
    required BuildContext context,
    required String outputPath,
    required ExportConfig config,
    required Duration duration,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportSuccessDialog(
        outputPath: outputPath,
        config: config,
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(outputPath);
    final sizeMb = config.estimateFileSizeMb(duration);

    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Checkmark Badge
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.check,
                size: 32,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Video Berhasil Diekspor!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Video Anda telah siap dan tersimpan di galeri perangkat.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Video Specs Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildSpecRow('File:', fileName),
                  const SizedBox(height: 6),
                  _buildSpecRow('Resolusi:', '${config.resolutionLabel} (${config.width}x${config.height})'),
                  const SizedBox(height: 6),
                  _buildSpecRow('Kecepatan:', '${config.fps} FPS'),
                  const SizedBox(height: 6),
                  _buildSpecRow('Ukuran File:', '${sizeMb.toStringAsFixed(1)} MB'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.share2, size: 16),
                    label: const Text('Bagikan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Membuka menu bagikan media...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                    },
                    child: const Text('Selesai'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
