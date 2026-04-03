import 'package:flutter/material.dart';
import './song_detail_screen.dart';
import '../services/song_service.dart';
import '../models/song.dart';

class AlbumSongsScreen extends StatefulWidget {
  final String albumId;
  final String albumTitle;

  const AlbumSongsScreen({super.key, required this.albumId, required this.albumTitle});

  @override
  State<AlbumSongsScreen> createState() => _AlbumSongsScreenState();
}

class _AlbumSongsScreenState extends State<AlbumSongsScreen> {
  final SongService _service = SongService();
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = _service.getSongsByAlbum(widget.albumId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.albumTitle)),
      body: FutureBuilder<List<Song>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No songs in this album"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final song = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.teal),
                  title: Text(song.title),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SongDetailScreen(songId: song.id),
                    ),
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