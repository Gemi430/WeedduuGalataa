import 'package:flutter/material.dart';
import './song_detail_screen.dart';
import '../services/song_service.dart';
import '../models/song.dart';

class SongListScreen extends StatefulWidget {
  final String scale;
  final String style;

  const SongListScreen({super.key, required this.scale, required this.style});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final SongService _service = SongService();
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = _getSongs();
  }

  Future<List<Song>> _getSongs() async {
    final ids = await _service.getSongsByScaleAndStyle(widget.scale, widget.style);
    final songs = <Song>[];
    for (final id in ids) {
      final song = await _service.getSong(id);
      if (song != null) songs.add(song);
    }
    return songs;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text("${widget.style} Songs")),
      body: FutureBuilder<List<Song>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text("No songs found", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final song = snapshot.data![index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SongDetailScreen(songId: song.id)),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isDark ? [] : [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.music_note, color: Color(0xFF1A237E), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(song.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            if (song.singerName != null)
                              Text(song.singerName!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}