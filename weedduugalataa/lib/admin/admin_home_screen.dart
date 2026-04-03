import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'songs_admin_screen.dart';
import 'albums_admin_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Manage Content", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildAdminCard(
              context,
              icon: Icons.music_note,
              title: "Songs",
              subtitle: "Add, edit or delete songs",
              color: Colors.teal,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SongsAdminScreen())),
            ),
            const SizedBox(height: 16),
            _buildAdminCard(
              context,
              icon: Icons.album,
              title: "Albums",
              subtitle: "Add, edit or delete albums",
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlbumsAdminScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
