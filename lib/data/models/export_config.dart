import 'package:flutter/foundation.dart';

enum ExportResolution {
  res720p,
  res1080p,
  res4k,
}

enum ExportFrameRate {
  fps24,
  fps30,
  fps60,
}

enum ExportStatus {
  idle,
  preparing,
  renderingVideo,
  mixingAudio,
  finalizing,
  completed,
  failed,
  cancelled,
}

@immutable
class ExportConfig {
  final ExportResolution resolution;
  final ExportFrameRate frameRate;
  final int qualityQualityBitrate; // in kbps
  final String format; // 'mp4'

  const ExportConfig({
    this.resolution = ExportResolution.res1080p,
    this.frameRate = ExportFrameRate.fps30,
    this.qualityQualityBitrate = 8000,
    this.format = 'mp4',
  });

  String get resolutionLabel {
    switch (resolution) {
      case ExportResolution.res720p:
        return '720P';
      case ExportResolution.res1080p:
        return '1080P';
      case ExportResolution.res4k:
        return '2K/4K';
    }
  }

  int get width {
    switch (resolution) {
      case ExportResolution.res720p:
        return 720;
      case ExportResolution.res1080p:
        return 1080;
      case ExportResolution.res4k:
        return 2160;
    }
  }

  int get height {
    switch (resolution) {
      case ExportResolution.res720p:
        return 1280;
      case ExportResolution.res1080p:
        return 1920;
      case ExportResolution.res4k:
        return 3840;
    }
  }

  int get fps {
    switch (frameRate) {
      case ExportFrameRate.fps24:
        return 24;
      case ExportFrameRate.fps30:
        return 30;
      case ExportFrameRate.fps60:
        return 60;
    }
  }

  /// Estimates output file size in Megabytes based on bitrate, duration, and audio
  double estimateFileSizeMb(Duration duration) {
    final seconds = duration.inMilliseconds / 1000.0;
    // Base video bitrate per resolution
    double videoBitrateMbps;
    switch (resolution) {
      case ExportResolution.res720p:
        videoBitrateMbps = 4.0;
        break;
      case ExportResolution.res1080p:
        videoBitrateMbps = 8.0;
        break;
      case ExportResolution.res4k:
        videoBitrateMbps = 24.0;
        break;
    }

    if (frameRate == ExportFrameRate.fps60) {
      videoBitrateMbps *= 1.4;
    }

    const audioBitrateMbps = 0.192; // 192 kbps AAC audio
    final totalBitrateMbps = videoBitrateMbps + audioBitrateMbps;
    final totalMegabits = totalBitrateMbps * seconds;
    return (totalMegabits / 8.0).clamp(0.5, 9999.0);
  }

  ExportConfig copyWith({
    ExportResolution? resolution,
    ExportFrameRate? frameRate,
    int? qualityQualityBitrate,
    String? format,
  }) {
    return ExportConfig(
      resolution: resolution ?? this.resolution,
      frameRate: frameRate ?? this.frameRate,
      qualityQualityBitrate: qualityQualityBitrate ?? this.qualityQualityBitrate,
      format: format ?? this.format,
    );
  }
}

@immutable
class ExportProgress {
  final ExportStatus status;
  final double percentage; // 0.0 to 1.0
  final String stageDescription;
  final String? outputPath;
  final String? errorMessage;

  const ExportProgress({
    required this.status,
    this.percentage = 0.0,
    required this.stageDescription,
    this.outputPath,
    this.errorMessage,
  });

  bool get isCompleted => status == ExportStatus.completed;
  bool get isFailed => status == ExportStatus.failed;
  bool get isCancelled => status == ExportStatus.cancelled;

  ExportProgress copyWith({
    ExportStatus? status,
    double? percentage,
    String? stageDescription,
    String? outputPath,
    String? errorMessage,
  }) {
    return ExportProgress(
      status: status ?? this.status,
      percentage: percentage ?? this.percentage,
      stageDescription: stageDescription ?? this.stageDescription,
      outputPath: outputPath ?? this.outputPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
