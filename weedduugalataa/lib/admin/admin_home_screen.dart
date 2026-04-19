import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'songs_admin_screen.dart';
import 'albums_admin_screen.dart';
import 'styles_admin_screen.dart';
import 'lyrics_submissions_admin_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    Icon(Icons.admin_panel_settings, size: 48, color: Colors.white.withOpacity(0.2)),
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
                  _buildSectionHeader("Content Management", Icons.dashboard, textColor),
                  const SizedBox(height: 16),
                  _buildAdminCard(
                    context,
                    icon: Icons.music_note,
                    title: "Songs",
                    subtitle: "Add, edit or delete songs",
                    color: textColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SongsAdminScreen())),
                  ),
                  const SizedBox(height: 14),
                  _buildAdminCard(
                    context,
                    icon: Icons.album,
                    title: "Albums",
                    subtitle: "Add, edit or delete albums",
                    color: textColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlbumsAdminScreen())),
                  ),
                  const SizedBox(height: 14),
                  _buildAdminCard(
                    context,
                    icon: Icons.style,
                    title: "Styles",
                    subtitle: "Manage music styles",
                    color: textColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StylesAdminScreen())),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("User Submissions", Icons.rate_review, textColor),
                  const SizedBox(height: 16),
                  _buildAdminCard(
                    context,
                    icon: Icons.lyrics,
                    title: "Lyrics Submissions",
                    subtitle: "Review and approve user submissions",
                    color: textColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LyricsSubmissionsAdminScreen())),
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

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
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

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color cardColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.2), width: 1),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}