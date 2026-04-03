import 'package:flutter/material.dart';
import './song_detail_screen.dart';
import '../services/song_service.dart';
import '../models/song.dart';

class SinglesScreen extends StatelessWidget {
  const SinglesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("All Songs"),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.library_music, size: 64, color: Colors.white.withValues(alpha: 0.15)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Song>>(
              stream: SongService().getAllSongs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(Icons.music_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text("No songs available", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  );
                }

                final songs = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${songs.length} Songs",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      ...songs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final song = entry.value;
                        final colors = [
                          [const Color(0xFF1A237E), const Color(0xFF3949AB)],
                          [const Color(0xFF00695C), const Color(0xFF00897B)],
                          [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)],
                          [const Color(0xFFE65100), const Color(0xFFF57C00)],
                          [const Color(0xFF1565C0), const Color(0xFF1976D2)],
                          [const Color(0xFF2E7D32), const Color(0xFF388E3C)],
                        ][index % 6];

                        return _buildSongCard(song, colors, context);
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongCard(Song song, List<Color> colors, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SongDetailScreen(songId: song.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: colors, begin: Alignment.centerLeft, end: Alignment.centerRight),
          boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.music_note, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (song.singerName != null)
                          _tag(song.singerName!),
                        if (song.scale != null)
                          _tag(song.scale!),
                        if (song.style != null)
                          _tag(song.style!),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}
