class ProjectDraft {
  final String id;
  final String title;
  final String? thumbnailPath;
  final Duration duration;
  final DateTime updatedAt;
  final String aspectRatio;
  final int clipCount;

  const ProjectDraft({
    required this.id,
    required this.title,
    this.thumbnailPath,
    required this.duration,
    required this.updatedAt,
    this.aspectRatio = '9:16',
    this.clipCount = 1,
  });

  String get formattedDuration {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inDays == 0) {
      return 'Hari ini ${updatedAt.hour.toString().padLeft(2, '0')}:${updatedAt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
    }
  }
}
