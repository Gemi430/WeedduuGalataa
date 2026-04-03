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
  late Future<List<String>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = _service.getSongsByScaleAndStyle(widget.scale, widget.style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.style} Songs")),
      body: FutureBuilder<List<String>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No songs found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.teal),
                  title: Text("Song ${index + 1}"),
                  subtitle: Text(snapshot.data![index]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SongDetailScreen(songId: snapshot.data![index]),
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