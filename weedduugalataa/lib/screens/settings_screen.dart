import 'package:flutter/material.dart';
import '../theme/theme_notifier.dart';
import '../theme/font_size_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Appearance"),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return _buildSettingsTile(
                icon: Icons.dark_mode,
                title: "Dark Mode",
                subtitle: "Toggle dark theme",
                trailing: Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (_) => toggleTheme(),
                ),
              );
            },
          ),
          _buildSectionHeader("Display"),
          _buildSettingsTile(
            icon: Icons.text_fields,
            title: "Font Size",
            subtitle: "Adjust lyrics font size",
            onTap: () => _showFontSizeDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: "Language",
            subtitle: "Afaan Oromo",
            onTap: () {},
          ),
          _buildSectionHeader("Data"),
          _buildSettingsTile(
            icon: Icons.download,
            title: "Download Songs",
            subtitle: "Save songs for offline use",
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          _buildSettingsTile(
            icon: Icons.sync,
            title: "Sync Data",
            subtitle: "Last synced: Never",
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("About"),
          _buildSettingsTile(
            icon: Icons.info,
            title: "App Version",
            subtitle: "1.0.0",
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.description,
            title: "Terms of Service",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1A237E)),
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
        onTap: onTap,
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Font Size"),
        content: ValueListenableBuilder<double>(
          valueListenable: fontSizeNotifier,
          builder: (context, currentSize, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: fontSizes.entries.map((entry) {
                final isSelected = currentSize == entry.value;
                return ListTile(
                  title: Text(entry.key, style: TextStyle(fontSize: entry.value)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF1A237E))
                      : null,
                  selected: isSelected,
                  onTap: () {
                    saveFontSize(entry.value);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
