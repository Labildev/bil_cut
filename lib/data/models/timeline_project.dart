import 'package:flutter/foundation.dart';
import 'timeline_clip.dart';
import 'timeline_track.dart';

@immutable
class TimelineProject {
  final String id;
  final String title;
  final String aspectRatio; // '9:16', '16:9', '1:1', '4:5'
  final int fps; // 24, 30, 60
  final String resolution; // '720P', '1080P', '2K/4K'
  final List<TimelineTrack> tracks;
  final DateTime updatedAt;

  const TimelineProject({
    required this.id,
    required this.title,
    this.aspectRatio = '9:16',
    this.fps = 30,
    this.resolution = '1080P',
    required this.tracks,
    required this.updatedAt,
  });

  Duration get totalDuration {
    if (tracks.isEmpty) return const Duration(seconds: 15);
    final maxTrackDuration = tracks.map((t) => t.trackDuration).fold(
          Duration.zero,
          (prev, curr) => curr > prev ? curr : prev,
        );
    return maxTrackDuration == Duration.zero ? const Duration(seconds: 15) : maxTrackDuration;
  }

  TimelineTrack? get mainVideoTrack {
    try {
      return tracks.firstWhere((t) => t.isMainTrack && t.type == ClipType.video);
    } catch (_) {
      return tracks.isNotEmpty ? tracks.first : null;
    }
  }

  TimelineClip? findClipById(String clipId) {
    for (final track in tracks) {
      for (final clip in track.clips) {
        if (clip.id == clipId) return clip;
      }
    }
    return null;
  }

  TimelineProject copyWith({
    String? id,
    String? title,
    String? aspectRatio,
    int? fps,
    String? resolution,
    List<TimelineTrack>? tracks,
    DateTime? updatedAt,
  }) {
    return TimelineProject(
      id: id ?? this.id,
      title: title ?? this.title,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      fps: fps ?? this.fps,
      resolution: resolution ?? this.resolution,
      tracks: tracks ?? this.tracks,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  TimelineProject withUpdatedTrack(TimelineTrack updatedTrack) {
    final newTracks = tracks.map((t) => t.id == updatedTrack.id ? updatedTrack : t).toList();
    return copyWith(tracks: newTracks, updatedAt: DateTime.now());
  }

  /// Create a sample initial project with demo clips for immediate testing & editing
  factory TimelineProject.sample() {
    final mainClips = [
      const TimelineClip(
        id: 'clip-demo-1',
        trackId: 'track-main-video',
        type: ClipType.video,
        name: 'Pantai_Sunset_01.mp4',
        timelineStart: Duration.zero,
        duration: Duration(seconds: 5),
        sourceIn: Duration.zero,
        sourceOut: Duration(seconds: 5),
      ),
      const TimelineClip(
        id: 'clip-demo-2',
        trackId: 'track-main-video',
        type: ClipType.video,
        name: 'Cafe_Aesthetic_02.mp4',
        timelineStart: Duration(seconds: 5),
        duration: Duration(seconds: 6),
        sourceIn: Duration.zero,
        sourceOut: Duration(seconds: 6),
      ),
      const TimelineClip(
        id: 'clip-demo-3',
        trackId: 'track-main-video',
        type: ClipType.video,
        name: 'City_Night_Walk_03.mp4',
        timelineStart: Duration(seconds: 11),
        duration: Duration(seconds: 4),
        sourceIn: Duration.zero,
        sourceOut: Duration(seconds: 4),
      ),
    ];

    final audioClips = [
      const TimelineClip(
        id: 'clip-audio-1',
        trackId: 'track-audio-bgm',
        type: ClipType.audio,
        name: 'Chill_Lofi_Beat.mp3',
        timelineStart: Duration(seconds: 1),
        duration: Duration(seconds: 14),
        sourceIn: Duration.zero,
        sourceOut: Duration(seconds: 14),
        volume: 0.8,
      ),
    ];

    final textClips = [
      const TimelineClip(
        id: 'clip-text-1',
        trackId: 'track-text-overlay',
        type: ClipType.text,
        name: 'Golden Hour ✨',
        textContent: 'Golden Hour ✨',
        timelineStart: Duration(seconds: 2),
        duration: Duration(seconds: 4),
        sourceIn: Duration.zero,
        sourceOut: Duration(seconds: 4),
      ),
    ];

    return TimelineProject(
      id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Proyek Baru',
      aspectRatio: '9:16',
      updatedAt: DateTime.now(),
      tracks: [
        TimelineTrack(
          id: 'track-main-video',
          type: ClipType.video,
          name: 'Video Utama',
          isMainTrack: true,
          clips: mainClips,
        ),
        TimelineTrack(
          id: 'track-audio-bgm',
          type: ClipType.audio,
          name: 'Audio BGM',
          clips: audioClips,
        ),
        TimelineTrack(
          id: 'track-text-overlay',
          type: ClipType.text,
          name: 'Teks',
          clips: textClips,
        ),
      ],
    );
  }
}
