import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/video_export_service.dart';
import '../../../../data/models/export_config.dart';
import '../../../../data/models/timeline_project.dart';
import 'export_success_dialog.dart';

class ExportSettingsSheet extends StatefulWidget {
  final TimelineProject project;

  const ExportSettingsSheet({
    super.key,
    required this.project,
  });

  static Future<void> show({
    required BuildContext context,
    required TimelineProject project,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ExportSettingsSheet(project: project),
    );
  }

  @override
  State<ExportSettingsSheet> createState() => _ExportSettingsSheetState();
}

class _ExportSettingsSheetState extends State<ExportSettingsSheet> {
  late ExportResolution _resolution;
  late ExportFrameRate _frameRate;
  late final VideoExportService _exportService;

  bool _isExporting = false;
  double _currentProgress = 0.0;
  String _currentStage = '';
  StreamSubscription<ExportProgress>? _exportSubscription;

  @override
  void initState() {
    super.initState();
    _resolution = ExportResolution.res1080p;
    _frameRate = ExportFrameRate.fps30;
    _exportService = VideoExportService();
  }

  @override
  void dispose() {
    _exportSubscription?.cancel();
    super.dispose();
  }

  ExportConfig _getConfig() {
    return ExportConfig(
      resolution: _resolution,
      frameRate: _frameRate,
    );
  }

  void _startExport() {
    final config = _getConfig();
    setState(() {
      _isExporting = true;
      _currentProgress = 0.0;
      _currentStage = 'Mempersiapkan ekspor...';
    });

    _exportSubscription = _exportService
        .exportProject(project: widget.project, config: config)
        .listen(
      (progress) {
        if (!mounted) return;

        setState(() {
          _currentProgress = progress.percentage;
          _currentStage = progress.stageDescription;
        });

        if (progress.isCompleted) {
          Navigator.pop(context); // Close sheet
          ExportSuccessDialog.show(
            context: context,
            outputPath: progress.outputPath ?? '',
            config: config,
            duration: widget.project.totalDuration,
          );
        } else if (progress.isCancelled) {
          setState(() {
            _isExporting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ekspor dibatalkan')),
          );
        }
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isExporting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ekspor gagal: $err')),
        );
      },
    );
  }

  void _cancelExport() {
    _exportService.cancelExport();
    _exportSubscription?.cancel();
    setState(() {
      _isExporting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isExporting) {
      return _buildExportingProgressView();
    }
    return _buildSettingsView();
  }

  Widget _buildSettingsView() {
    final config = _getConfig();
    final estimatedSizeMb = config.estimateFileSizeMb(widget.project.totalDuration);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pengaturan Ekspor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Resolution Section
            const Text(
              'Resolusi Video',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildResolutionOption('720P', ExportResolution.res720p),
                const SizedBox(width: 8),
                _buildResolutionOption('1080P', ExportResolution.res1080p),
                const SizedBox(width: 8),
                _buildResolutionOption('2K/4K', ExportResolution.res4k),
              ],
            ),
            const SizedBox(height: 18),

            // Frame Rate Section
            const Text(
              'Kecepatan Bingkai (Frame Rate)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildFpsOption('24 fps', ExportFrameRate.fps24),
                const SizedBox(width: 8),
                _buildFpsOption('30 fps', ExportFrameRate.fps30),
                const SizedBox(width: 8),
                _buildFpsOption('60 fps', ExportFrameRate.fps60),
              ],
            ),
            const SizedBox(height: 18),

            // Video Summary Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimasi Ukuran:',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${estimatedSizeMb.toStringAsFixed(1)} MB',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Durasi Video:',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.project.totalDuration.inSeconds} detik',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Start Export Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(LucideIcons.upload, size: 18, color: Colors.black),
                label: const Text('Mulai Ekspor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                onPressed: _startExport,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionOption(String label, ExportResolution res) {
    final isSelected = _resolution == res;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _resolution = res;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFpsOption(String label, ExportFrameRate fps) {
    final isSelected = _frameRate == fps;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _frameRate = fps;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportingProgressView() {
    final percentage = (_currentProgress * 100).round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Progress with Percentage in Center
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _currentProgress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  Text(
                    '$percentage%',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stage Description
            Text(
              _currentStage,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Mohon jangan keluar dari aplikasi selama proses render berlangsung.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Cancel Button
            TextButton.icon(
              icon: const Icon(LucideIcons.x, size: 16, color: AppColors.error),
              label: const Text('Batalkan Ekspor', style: TextStyle(color: AppColors.error)),
              onPressed: _cancelExport,
            ),
          ],
        ),
      ),
    );
  }
}

