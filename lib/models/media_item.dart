class MediaItem {
  final String id;
  final List<String> studentIds;
  final String type; // 'photo' or 'video'
  final String title;
  final String date;
  final String? driveFileId;
  final String? url;
  final String? thumbUrl;
  final int? createdAt;
  final List<String>? studentNames;

  MediaItem({
    required this.id,
    required this.studentIds,
    required this.type,
    required this.title,
    required this.date,
    this.driveFileId,
    this.url,
    this.thumbUrl,
    this.createdAt,
    this.studentNames,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      studentIds: (json['studentIds'] as List<dynamic>?)?.cast<String>() ?? [],
      type: json['type'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      driveFileId: json['driveFileId'] as String?,
      url: json['url'] as String?,
      thumbUrl: json['thumbUrl'] as String?,
      createdAt: json['createdAt'] as int?,
      studentNames: (json['studentNames'] as List<dynamic>?)?.cast<String>(),
    );
  }

  bool get isPhoto => type == 'photo';
  bool get isVideo => type == 'video';

  String get displayUrl {
    if (url != null && url!.isNotEmpty && !url!.startsWith('data:')) return url!;
    if (thumbUrl != null && thumbUrl!.isNotEmpty && !thumbUrl!.startsWith('data:')) return thumbUrl!;
    return _placeholder(type == 'photo' ? '#7db89a' : '#1a2744', type == 'photo' ? '📷' : '🎬');
  }

  String get displayThumb {
    if (thumbUrl != null && thumbUrl!.isNotEmpty && !thumbUrl!.startsWith('data:')) return thumbUrl!;
    if (url != null && url!.isNotEmpty && !url!.startsWith('data:')) return url!;
    return _placeholder(type == 'photo' ? '#7db89a' : '#1a2744', type == 'photo' ? '📷' : '🎬');
  }

  static String _placeholder(String color, String emoji) {
    return 'https://placehold.co/400x300/$color/ffffff?text=$emoji';
  }

  String get taggedStudentsText {
    if (studentNames != null && studentNames!.isNotEmpty) {
      return studentNames!.join(', ');
    }
    return studentIds.join(', ');
  }
}
