import 'package:flutter_test/flutter_test.dart';
import 'package:bil_cut/data/models/export_config.dart';
import 'package:bil_cut/data/models/timeline_project.dart';
import 'package:bil_cut/core/services/video_export_service.dart';

void main() {
  group('Video Export Engine Tests', () {
    test('ExportConfig calculates dimensions and file size correctly', () {
      const config1080p = ExportConfig(
        resolution: ExportResolution.res1080p,
        frameRate: ExportFrameRate.fps30,
      );

      expect(config1080p.width, 1080);
      expect(config1080p.height, 1920);
      expect(config1080p.fps, 30);
      expect(config1080p.resolutionLabel, '1080P');

      // 15 seconds at 1080p 30fps (~8.192 Mbps) = ~15.36 MB
      final sizeMb = config1080p.estimateFileSizeMb(const Duration(seconds: 15));
      expect(sizeMb, greaterThan(10.0));
      expect(sizeMb, lessThan(20.0));

      const config4k = ExportConfig(
        resolution: ExportResolution.res4k,
        frameRate: ExportFrameRate.fps60,
      );
      expect(config4k.width, 2160);
      expect(config4k.fps, 60);
      final size4kMb = config4k.estimateFileSizeMb(const Duration(seconds: 15));
      expect(size4kMb, greaterThan(sizeMb));
    });

    test('VideoExportService runs through export pipeline to completion', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final service = VideoExportService();
      final project = TimelineProject.sample();
      const config = ExportConfig(resolution: ExportResolution.res720p);

      final progressEvents = <ExportProgress>[];

      await for (final progress in service.exportProject(project: project, config: config)) {
        progressEvents.add(progress);
      }

      expect(progressEvents.isNotEmpty, true);
      expect(progressEvents.first.status, ExportStatus.preparing);
      expect(progressEvents.last.status, ExportStatus.completed);
      expect(progressEvents.last.percentage, 1.0);
      expect(progressEvents.last.outputPath, isNotNull);
    });

    test('VideoExportService supports cancellation', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final service = VideoExportService();
      final project = TimelineProject.sample();
      const config = ExportConfig();

      final progressEvents = <ExportProgress>[];

      final subscription = service.exportProject(project: project, config: config).listen((p) {
        progressEvents.add(p);
        if (progressEvents.length == 2) {
          service.cancelExport();
        }
      });

      await Future.delayed(const Duration(milliseconds: 900));
      await subscription.cancel();

      expect(progressEvents.any((p) => p.status == ExportStatus.cancelled), true);
    });
  });
}
