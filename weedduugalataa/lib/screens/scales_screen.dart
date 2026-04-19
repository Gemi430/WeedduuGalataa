import 'package:flutter/material.dart';
import '../models/scale.dart';
import 'style_songs_screen.dart';

class ScalesScreen extends StatelessWidget {
  const ScalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scales = MusicScale.allScales;
    final styles = MusicScale.allStyles;

    final appBarColor = isDark ? Colors.black : const Color(0xFF1A237E);
    final gradientStart = isDark ? Colors.black : const Color(0xFF1A237E);
    final gradientEnd = isDark ? Colors.grey[900]! : const Color(0xFF3949AB);
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final cardTextColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final iconColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final sectionTextColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Music Scales",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    Icon(Icons.piano, size: 48, color: Colors.white.withOpacity(0.2)),
                  ],
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
                  _buildSectionHeader("Select a Scale", Icons.music_note, iconColor, sectionTextColor),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: scales.length,
                    itemBuilder: (context, index) {
                      final scale = scales[index];
                      return _buildScaleCard(scale, cardColor, cardTextColor, borderColor, context);
                    },
                  ),
                  const SizedBox(height: 28),
                  _buildSectionHeader("All Styles", Icons.style, iconColor, sectionTextColor),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: styles.map((style) {
                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Text(
                          style,
                          style: TextStyle(
                            color: cardTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: textColor.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: textColor, size: 22),
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

  Widget _buildScaleCard(MusicScale scale, Color cardColor, Color textColor, Color borderColor, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StyleSongsScreen(scale: scale)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.piano, color: textColor, size: 24),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textColor.withOpacity(0.6),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scale.displayName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "6 Styles",
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
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