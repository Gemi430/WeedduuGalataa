class LyricsSubmission {
  final String id;
  final String songTitle;
  final String singerName;
  final String lyrics;
  final String scale;
  final String style;
  final String submittedBy;
  final String? phone;
  final DateTime submittedAt;
  final String status; // pending, approved, rejected
  final String? adminNote;

  LyricsSubmission({
    required this.id,
    required this.songTitle,
    required this.singerName,
    required this.lyrics,
    required this.scale,
    required this.style,
    required this.submittedBy,
    this.phone,
    required this.submittedAt,
    required this.status,
    this.adminNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'songTitle': songTitle,
      'singerName': singerName,
      'lyrics': lyrics,
      'scale': scale,
      'style': style,
      'submittedBy': submittedBy,
      'phone': phone,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
      'adminNote': adminNote,
    };
  }

  factory LyricsSubmission.fromMap(Map<String, dynamic> map) {
    return LyricsSubmission(
      id: map['id'] ?? '',
      songTitle: map['songTitle'] ?? '',
      singerName: map['singerName'] ?? '',
      lyrics: map['lyrics'] ?? '',
      scale: map['scale'] ?? '',
      style: map['style'] ?? '',
      submittedBy: map['submittedBy'] ?? '',
      phone: map['phone'],
      submittedAt: map['submittedAt'] != null ? DateTime.parse(map['submittedAt']) : DateTime.now(),
      status: map['status'] ?? 'pending',
      adminNote: map['adminNote'],
    );
  }
}