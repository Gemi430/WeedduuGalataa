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
            expandedHeight: 180,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFFFF6F00),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Singles"),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF6F00), const Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.star, size: 64, color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Song>>(
              stream: SongService().getSingles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "No singles available",
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final song = snapshot.data![index];
                    final colors = [
                      [Colors.amber, Colors.orange],
                      [Colors.pink, Colors.purple],
                      [Colors.teal, Colors.teal[700]!],
                      [Colors.blue, Colors.blue[700]!],
                    ][index % 4];
                    return _buildSingleCard(song, colors, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleCard(Song song, List<Color> colors, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SongDetailScreen(songId: song.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 28),
          ),
          title: Text(
            song.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: song.style != null
              ? Text(
                  song.style!,
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                )
              : null,
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}