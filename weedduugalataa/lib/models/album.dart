class Album {
  final String id;
  final String title;
  final String? coverImageUrl;
  final List<String> songIds;

  Album({
    required this.id,
    required this.title,
    this.coverImageUrl,
    this.songIds = const [],
  });

  factory Album.fromMap(Map<String, dynamic> data, String id) {
    return Album(
      id: id,
      title: data['title'] ?? '',
      coverImageUrl: data['coverImageUrl'],
      songIds: List<String>.from(data['songIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'coverImageUrl': coverImageUrl,
      'songIds': songIds,
    };
  }
}