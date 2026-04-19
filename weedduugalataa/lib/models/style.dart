class MusicStyle {
  final String id;
  final String name;
  final String? description;

  MusicStyle({
    required this.id,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory MusicStyle.fromMap(Map<String, dynamic> map) {
    return MusicStyle(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
    );
  }

  static List<String> get allStyles => [
        'Waltz',
        'Slow Rock',
        'Reggae',
        'Chikchika',
        'Wallo',
        'Disco',
        'Rumba',
        'Salsa',
        'Tango',
        'Foxtrot',
        'Jazz',
        'Blues',
        'Pop',
        'Rock',
        'Hip Hop',
        'Traditional',
      ];
}