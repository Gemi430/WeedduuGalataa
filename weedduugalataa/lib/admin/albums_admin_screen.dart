import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/album.dart';
import 'album_form_screen.dart';
import 'album_songs_admin_screen.dart';

class AlbumsAdminScreen extends StatelessWidget {
  const AlbumsAdminScreen({super.key});

  Future<void> _deleteAlbum(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Album"),
        content: const Text("Are you sure you want to delete this album?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('albums').doc(id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Album deleted")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? Colors.black : const Color(0xFF1A237E);
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Manage Albums",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlbumFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text("Add Album"),
        backgroundColor: textColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? Colors.black : const Color(0xFF1A237E),
                    isDark ? Colors.grey[900]! : const Color(0xFF3949AB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Icon(Icons.album, size: 40, color: Colors.white.withOpacity(0.2)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('albums').orderBy('title').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.album, size: 64, color: textColor.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text("No albums yet. Add one!", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("${snapshot.data!.docs.length} Albums", textColor),
                      const SizedBox(height: 16),
                      ...snapshot.data!.docs.map((doc) {
                        final album = Album.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                        return _buildAlbumCard(album, cardColor, textColor, borderColor, context);
                      }).toList(),
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

  Widget _buildSectionHeader(String title, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: textColor.withOpacity(0.2), width: 1),
          ),
          child: Icon(Icons.album, color: textColor, size: 22),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumCard(Album album, Color cardColor, Color textColor, Color borderColor, BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Icon(Icons.album, color: textColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${album.songIds.length} songs",
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.reorder, color: textColor.withOpacity(0.7)),
                    tooltip: "Reorder songs",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AlbumSongsAdminScreen(albumId: album.id, albumTitle: album.title)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: textColor.withOpacity(0.7)),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AlbumFormScreen(album: album)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAlbum(context, album.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}