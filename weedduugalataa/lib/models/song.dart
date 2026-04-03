class Song {
  final String id;
  final String title;
  final String lyrics;
  final String? scale;
  final String? style;
  final String? albumId;
  final bool isSingle;
  final String? singerName;
  final int orderIndex;

  Song({
    required this.id,
    required this.title,
    required this.lyrics,
    this.scale,
    this.style,
    this.albumId,
    this.isSingle = false,
    this.singerName,
    this.orderIndex = 0,
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
      singerName: data['singerName'],
      orderIndex: data['orderIndex'] ?? 0,
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
      'singerName': singerName,
      'orderIndex': orderIndex,
    };
  }
}