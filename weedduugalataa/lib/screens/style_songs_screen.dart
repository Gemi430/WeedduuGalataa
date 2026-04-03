import 'package:flutter/material.dart';
import '../models/scale.dart';
import 'song_list_screen.dart';

class StyleSongsScreen extends StatelessWidget {
  final MusicScale scale;

  const StyleSongsScreen({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${scale.displayName} - Styles")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MusicScale.allStyles.length,
        itemBuilder: (context, index) {
          final style = MusicScale.allStyles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.music_note, color: Colors.teal),
              title: Text(style),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongListScreen(scale: scale.id, style: style),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}