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

  void _share(String title, String lyrics) {
    Share.share('$title\n\n$lyrics');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? Colors.black : const Color(0xFF1A237E);
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final iconColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<Song?>(
        future: _songFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: textColor));
          }
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off, size: 64, color: textColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    "Song not found",
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ],
              ),
            );
          }
          final song = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: appBarColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.black, Colors.grey[900]!]
                            : [const Color(0xFF1A237E), const Color(0xFF3949AB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.music_note,
                        size: 80,
                        color: Color.fromRGBO(255, 255, 255, 0.2),
                      ),
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
                    onPressed: () => _share(song.title, song.lyrics),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (song.singerName != null || song.scale != null || song.style != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (song.singerName != null) _buildChip(song.singerName!, Colors.green, textColor),
                            if (song.scale != null) _buildChip(song.scale!, const Color(0xFF1A237E), textColor),
                            if (song.style != null) _buildChip(song.style!, const Color(0xFFFF6F00), textColor),
                            if (song.isSingle) _buildChip("Single", const Color(0xFF4CAF50), textColor),
                          ],
                        ),
                      const SizedBox(height: 24),
                      _buildLyricsSection(song.lyrics, textColor),
                      const SizedBox(height: 24),
                      _buildActionButtons(song.title, song.lyrics, textColor),
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

  Widget _buildChip(String label, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromRGBO(color.red, color.green, color.blue, 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLyricsSection(String lyrics, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: textColor.withOpacity(0.5)),
              const SizedBox(width: 8),
              Text(
                "Lyrics",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<double>(
            valueListenable: fontSizeNotifier,
            builder: (context, fontSize, _) => Text(
              lyrics,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.8,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String title, String lyrics, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDark ? const Color(0xFF7986CB) : const Color(0xFF1A237E);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: lyrics));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Lyrics copied!"),
                  backgroundColor: buttonColor,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text("Copy Lyrics"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _share(title, lyrics),
            icon: const Icon(Icons.share),
            label: const Text("Share"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: buttonColor),
              foregroundColor: buttonColor,
            ),
          ),
        ),
      ],
    );
  }
}


