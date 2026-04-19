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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? Colors.black : const Color(0xFF1A237E);
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final iconColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.albumTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                  Icon(Icons.music_off, size: 64, color: textColor.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    "No songs in this album",
                    style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final song = snapshot.data![index];
              final isFirst = index == 0;
              final isLast = index == snapshot.data!.length - 1;

              return Container(
                margin: EdgeInsets.only(
                  bottom: isLast ? 0 : 12,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Icon(Icons.music_note, color: iconColor, size: 22),
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: iconColor.withOpacity(0.5),
                    size: 16,
                  ),
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