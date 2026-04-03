import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';

class AlbumSongsAdminScreen extends StatefulWidget {
  final String albumId;
  final String albumTitle;

  const AlbumSongsAdminScreen({super.key, required this.albumId, required this.albumTitle});

  @override
  State<AlbumSongsAdminScreen> createState() => _AlbumSongsAdminScreenState();
}

class _AlbumSongsAdminScreenState extends State<AlbumSongsAdminScreen> {
  List<Song> _songs = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final snap = await FirebaseFirestore.instance
        .collection('songs')
        .where('albumId', isEqualTo: widget.albumId)
        .orderBy('orderIndex')
        .get();
    setState(() {
      _songs = snap.docs.map((d) => Song.fromMap(d.data(), d.id)).toList();
      _loading = false;
    });
  }

  Future<void> _saveOrder() async {
    setState(() => _saving = true);
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < _songs.length; i++) {
      batch.update(
        FirebaseFirestore.instance.collection('songs').doc(_songs[i].id),
        {'orderIndex': i},
      );
    }
    await batch.commit();
    setState(() => _saving = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order saved!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.albumTitle} - Songs"),
        actions: [
          if (_saving)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: "Save order",
              onPressed: _saveOrder,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? const Center(child: Text("No songs in this album"))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.amber.withValues(alpha: 0.1),
                      child: const Row(
                        children: [
                          Icon(Icons.drag_handle, color: Colors.amber),
                          SizedBox(width: 8),
                          Text("Drag to reorder, then tap Save", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _songs.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final song = _songs.removeAt(oldIndex);
                            _songs.insert(newIndex, song);
                          });
                        },
                        itemBuilder: (context, index) {
                          final song = _songs[index];
                          return Card(
                            key: ValueKey(song.id),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
                                child: Text("${index + 1}", style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
                              ),
                              title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: song.singerName != null ? Text(song.singerName!) : null,
                              trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
