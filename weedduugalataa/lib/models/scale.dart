class MusicScale {
  final String id;
  final String name;
  final String displayName;

  MusicScale({
    required this.id,
    required this.name,
    required this.displayName,
  });

  static List<MusicScale> get allScales => [
        MusicScale(id: '1st', name: '1st Scale', displayName: '1st Scale'),
        MusicScale(id: '2nd', name: '2nd Scale', displayName: '2nd Scale'),
        MusicScale(id: '5th', name: '5th Scale', displayName: '5th Scale'),
        MusicScale(id: '6th', name: '6th Scale', displayName: '6th Scale'),
      ];

  static List<String> get allStyles => [
        'Waltz',
        'Slow Rock',
        'Reggae',
        'Chikchika',
        'Wallo',
        'Disco',
      ];
}