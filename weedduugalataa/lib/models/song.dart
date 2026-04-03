class Song {
  final String id;
  final String title;
  final String lyrics;
  final String? scale;
  final String? style;
  final String? albumId;
  final bool isSingle;

  Song({
    required this.id,
    required this.title,
    required this.lyrics,
    this.scale,
    this.style,
    this.albumId,
    this.isSingle = false,
  });

  factory Song.fromMap(Map<String, dynamic> data, String id) {
    return Song(
      id: id,
      title: data['title'] ?? '',
      lyrics: data['lyrics'] ?? '',
      scale: data['scale'],
      style: data['style'],
      albumId: data['albumId'],
      isSingle: data['isSingle'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'lyrics': lyrics,
      'scale': scale,
      'style': style,
      'albumId': albumId,
      'isSingle': isSingle,
    };
  }
}