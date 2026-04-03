import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/song_service.dart';
import '../services/favorites_service.dart';
import '../models/song.dart';
import '../theme/font_size_notifier.dart';

class SongDetailScreen extends StatefulWidget {
  final String songId;
  const SongDetailScreen({super.key, required this.songId});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  final SongService _songService = SongService();
  final FavoritesService _favService = FavoritesService();
  late Future<Song?> _songFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _songFuture = _songService.getSong(widget.songId);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final fav = await _favService.isFavorite(widget.songId);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite(String title) async {
    await _favService.toggleFavorite(widget.songId, title);
    if (mounted) setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Song?>(
        future: _songFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Song not found"));
          }
          final song = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF1A237E),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.music_note, size: 80, color: Color.fromRGBO(255, 255, 255, 0.2)),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(song.title),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () => SharePlus.instance.share(ShareParams(text: '\n\n')),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (song.scale != null || song.style != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (song.scale != null) _buildChip(song.scale!, const Color(0xFF1A237E)),
                            if (song.style != null) _buildChip(song.style!, const Color(0xFFFF6F00)),
                            if (song.isSingle) _buildChip("Single", const Color(0xFF4CAF50)),
                          ],
                        ),
                      const SizedBox(height: 24),
                      _buildLyricsSection(song.lyrics),
                      const SizedBox(height: 24),
                      _buildActionButtons(song.lyrics),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromRGBO(color.red, color.green, color.blue, 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildLyricsSection(String lyrics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(158, 158, 158, 0.1), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.format_quote, color: Color.fromRGBO(26, 35, 126, 0.5)),
              SizedBox(width: 8),
              Text("Lyrics", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color.fromRGBO(26, 35, 126, 0.7))),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<double>(
            valueListenable: fontSizeNotifier,
            builder: (context, fontSize, _) => Text(
              lyrics,
              style: TextStyle(fontSize: fontSize, height: 1.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String lyrics) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: lyrics));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Lyrics copied!"), duration: Duration(seconds: 2)),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text("Copy Lyrics"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text("Share"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFF1A237E)),
              foregroundColor: const Color(0xFF1A237E),
            ),
          ),
        ),
      ],
    );
  }
}


