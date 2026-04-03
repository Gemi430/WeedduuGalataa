import 'package:flutter/material.dart';
import '../models/scale.dart';
import 'style_songs_screen.dart';

class ScalesScreen extends StatelessWidget {
  const ScalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scales = MusicScale.allScales;
    final styles = MusicScale.allStyles;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Music Scales"),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1A237E), const Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.piano, size: 64, color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Select a Scale", Icons.music_note),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: scales.length,
                    itemBuilder: (context, index) {
                      final scale = scales[index];
                      final colors = [
                        [Colors.teal, Colors.teal[700]!],
                        [Colors.purple, Colors.purple[700]!],
                        [Colors.orange, Colors.orange[700]!],
                        [Colors.pink, Colors.pink[700]!],
                      ][index];
                      return _buildScaleCard(scale, colors, context);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("All Styles", Icons.style),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: styles.map((style) {
                      return Chip(
                        label: Text(style),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[300]!),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1A237E)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScaleCard(MusicScale scale, List<Color> colors, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StyleSongsScreen(scale: scale)),
      ),
      child: Container(
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
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.piano, color: Colors.white, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    scale.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "6 Styles",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
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