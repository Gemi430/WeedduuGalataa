import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/album.dart';
import 'album_songs_screen.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF6A1B9A),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Albums"),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.album, size: 64, color: Colors.white.withValues(alpha: 0.15)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('albums').orderBy('title').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(Icons.album, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text("No albums available", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${docs.length} Albums",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final album = Album.fromMap(docs[index].data() as Map<String, dynamic>, docs[index].id);
                          final gradients = [
                            [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)],
                            [const Color(0xFF1A237E), const Color(0xFF3949AB)],
                            [const Color(0xFF00695C), const Color(0xFF00897B)],
                            [const Color(0xFFE65100), const Color(0xFFF57C00)],
                            [const Color(0xFF1565C0), const Color(0xFF1976D2)],
                            [const Color(0xFF2E7D32), const Color(0xFF388E3C)],
                          ][index % 6];
                          return _buildAlbumCard(album, gradients, context);
                        },
                      ),
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

  Widget _buildAlbumCard(Album album, List<Color> colors, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AlbumSongsScreen(albumId: album.id, albumTitle: album.title)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Icon(Icons.album, size: 100, color: Colors.white.withValues(alpha: 0.08)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.album, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    album.title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${album.songIds.length} songs",
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
