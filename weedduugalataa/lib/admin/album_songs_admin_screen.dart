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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? Colors.black : const Color(0xFF1A237E);
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "${widget.albumTitle} - Songs",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              tooltip: "Save order",
              onPressed: _saveOrder,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_off, size: 64, color: textColor.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text("No songs in this album", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6))),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.08),
                        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.drag_handle, color: textColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Drag to reorder, then tap Save",
                              style: TextStyle(fontSize: 13, color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          return Container(
                            key: ValueKey(song.id),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: cardColor,
                              border: Border.all(color: borderColor, width: 1.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: textColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: textColor.withOpacity(0.2), width: 1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: textColor,
                                          ),
                                        ),
                                        if (song.singerName != null)
                                          Text(
                                            song.singerName!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textColor.withOpacity(0.7),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.drag_handle, color: textColor.withOpacity(0.5)),
                                ],
                              ),
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