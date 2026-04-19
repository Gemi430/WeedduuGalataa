import 'package:flutter/material.dart';
import '../models/scale.dart';
import 'song_list_screen.dart';

class StyleSongsScreen extends StatelessWidget {
  final MusicScale scale;

  const StyleSongsScreen({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? Colors.black : const Color(0xFF1A237E);
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final iconColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "${scale.displayName} - Styles",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MusicScale.allStyles.length,
        itemBuilder: (context, index) {
          final style = MusicScale.allStyles[index];
          final isLast = index == MusicScale.allStyles.length - 1;

          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Icon(Icons.style, color: iconColor, size: 22),
              ),
              title: Text(
                style,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: iconColor.withOpacity(0.5),
                size: 16,
              ),
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