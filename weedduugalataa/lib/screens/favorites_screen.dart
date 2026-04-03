import 'package:flutter/material.dart';
import './song_detail_screen.dart';
import '../services/favorites_service.dart';
import '../services/song_service.dart';
import '../models/song.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favService = FavoritesService();
    final songService = SongService();

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: StreamBuilder<List<String>>(
        stream: favService.favoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ids = snapshot.data ?? [];

          if (ids.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("No favorites yet", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the heart icon on a song to save it here",
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ids.length,
            itemBuilder: (context, index) {
              return FutureBuilder<Song?>(
                future: songService.getSong(ids[index]),
                builder: (context, songSnap) {
                  if (!songSnap.hasData) {
                    return const SizedBox(height: 72, child: Center(child: LinearProgressIndicator()));
                  }
                  final song = songSnap.data!;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.favorite, color: Colors.red),
                      ),
                      title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: song.style != null ? Text("${song.scale ?? ''} - ${song.style}") : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () => favService.toggleFavorite(song.id, song.title),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SongDetailScreen(songId: song.id)),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
