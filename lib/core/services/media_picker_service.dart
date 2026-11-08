import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../../data/models/timeline_clip.dart';
import '../../data/models/timeline_project.dart';
import '../../data/models/timeline_track.dart';

class MediaPickerService {
  final ImagePicker _picker;

  MediaPickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Picks a single video from device gallery
  Future<XFile?> pickVideo() async {
    try {
      final file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 60),
      );
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Records a video directly from device camera
  Future<XFile?> captureVideoWithCamera() async {
    try {
      final file = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 60),
      );
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Picks a single image from gallery (e.g. for photo overlay / sticker)
  Future<XFile?> pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Picks multiple videos/media from device gallery
  Future<List<XFile>> pickMultipleVideos() async {
    try {
      final files = await _picker.pickMultipleMedia();
      final videoFiles = files.where((f) {
        final ext = p.extension(f.path).toLowerCase();
        return ext == '.mp4' || ext == '.mov' || ext == '.mkv' || ext == '.webm' || ext == '.3gp';
      }).toList();

      // If user selected non-video files or picker returned all media, return valid items or all
      return videoFiles.isNotEmpty ? videoFiles : files;
    } catch (e) {
      return [];
    }
  }

  /// Converts an [XFile] to a [TimelineClip] with a default duration (e.g. 5 seconds if not yet probed)
  TimelineClip createClipFromXFile({
    required XFile file,
    required String trackId,
    required Duration timelineStart,
    Duration duration = const Duration(seconds: 5),
  }) {
    final fileName = p.basename(file.path);
    final clipId = 'clip-${DateTime.now().microsecondsSinceEpoch}';

    return TimelineClip(
      id: clipId,
      trackId: trackId,
      type: ClipType.video,
      name: fileName,
      sourcePath: file.path,
      timelineStart: timelineStart,
      duration: duration,
      sourceIn: Duration.zero,
      sourceOut: duration,
    );
  }

  /// Creates a new [TimelineProject] from a list of picked files
  TimelineProject createProjectFromFiles({
    required List<XFile> files,
    String title = 'Proyek Baru',
    String aspectRatio = '9:16',
  }) {
    final projectId = 'proj-${DateTime.now().millisecondsSinceEpoch}';
    final mainTrackId = 'track-main-video';

    var currentTimelineStart = Duration.zero;
    final clips = <TimelineClip>[];

    for (final file in files) {
      const defaultClipDuration = Duration(seconds: 5);
      final clip = createClipFromXFile(
        file: file,
        trackId: mainTrackId,
        timelineStart: currentTimelineStart,
        duration: defaultClipDuration,
      );
      clips.add(clip);
      currentTimelineStart += defaultClipDuration;
    }

    final mainVideoTrack = TimelineTrack(
      id: mainTrackId,
      type: ClipType.video,
      name: 'Video Utama',
      isMainTrack: true,
      clips: clips,
    );

    final audioTrack = TimelineTrack(
      id: 'track-audio-bgm',
      type: ClipType.audio,
      name: 'Audio BGM',
      clips: const [],
    );

    final textTrack = TimelineTrack(
      id: 'track-text-overlay',
      type: ClipType.text,
      name: 'Teks',
      clips: const [],
    );

    return TimelineProject(
      id: projectId,
      title: title,
      aspectRatio: aspectRatio,
      tracks: [mainVideoTrack, audioTrack, textTrack],
      updatedAt: DateTime.now(),
    );
  }
}
