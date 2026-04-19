import 'package:flutter/material.dart';
import '../theme/theme_notifier.dart';
import '../theme/font_size_notifier.dart';
import '../admin/admin_login_screen.dart';
import 'lyrics_submission_screen.dart';
import '../services/song_service.dart';
import '../services/connectivity_service.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SongService _songService = SongService();
  late Future<bool> _isOnlineFuture;
  late Future<String> _lastSyncFuture;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _isOnlineFuture = ConnectivityService.getInstance().then((s) => s.isOnline);
    _lastSyncFuture = _songService.getLastSyncTime();
  }

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    try {
      final connectivity = await ConnectivityService.getInstance();
      if (await connectivity.checkOnline()) {
        await _songService.syncAllData();
        if (mounted) {
          setState(() {
            _lastSyncFuture = _songService.getLastSyncTime();
          });
          _showSyncSuccessDialog();
        }
      } else {
        if (mounted) _showOfflineDialog();
      }
    } catch (e) {
      if (mounted) _showErrorDialog(e.toString());
    }
    if (mounted) setState(() => _isSyncing = false);
  }

  void _showSyncSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text("Sync Complete"),
          ],
        ),
        content: Text("All songs and albums have been downloaded for offline use."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showOfflineDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.orange),
            const SizedBox(width: 8),
            Text("Offline"),
          ],
        ),
        content: Text("Please connect to the internet to sync your data."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text("Sync failed: $message"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: isDark ? Colors.black : const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              background: Container(
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Appearance", textColor),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.dark_mode,
                    title: "Dark Mode",
                    subtitle: "Toggle dark theme",
                    textColor: textColor,
                    borderColor: borderColor,
                    cardColor: cardColor,
                    trailing: ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, mode, _) {
                        return Switch(
                          value: mode == ThemeMode.dark,
                          onChanged: (_) => toggleTheme(),
                          activeColor: textColor,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Display", textColor),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.text_fields,
                    title: "Font Size",
                    subtitle: "Adjust lyrics font size",
                    textColor: textColor,
                    borderColor: borderColor,
                    cardColor: cardColor,
                    onTap: () => _showFontSizeDialog(context, textColor, borderColor),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.language,
                    title: "Language",
                    subtitle: "Afaan Oromo",
                    textColor: textColor,
                    borderColor: borderColor,
                    cardColor: cardColor,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Contribute", textColor),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.lyrics,
                    title: "Submit Lyrics",
                    subtitle: "Contribute lyrics to our library",
                    textColor: textColor,
                    borderColor: borderColor,
                    cardColor: cardColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LyricsSubmissionScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Data", textColor),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.download,
                    title: "Download Songs",
                    subtitle: "Save songs for offline use",
                    textColor: textColor,
                    borderColor: borderColor,
                    cardColor: cardColor,
                    trailing: FutureBuilder<bool>(
                      future: _isOnlineFuture,
                      builder: (context, snapshot) {
                        return Switch(
                          value: snapshot.data ?? false,
                          onChanged: (value) async {
                            final localStorage = await LocalStorageService.getInstance();
                            await localStorage.setSyncEnabled(value);
                            if (value && snapshot.data == true) {
                              await _handleSync();
                            }
                            setState(() {});
                          },
                          activeColor: textColor,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<String>(
                    future: _lastSyncFuture,
                    builder: (context, syncSnapshot) {
                      return _buildSettingsTile(
                        context,
                        icon: Icons.sync,
                        title: "Sync Data",
                        subtitle: "Last synced: ${syncSnapshot.data ?? 'Loading...'}",
                        textColor: textColor,
                        borderColor: borderColor,
                        cardColor: cardColor,
                        trailing: _isSyncing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: textColor,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                color: textColor.withOpacity(0.5),
                                size: 16,
                              ),
                        onTap: _isSyncing ? null : _handleSync,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Admin", textColor),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.admin_panel_settings,
                    title: "Admin Dashboard",
                    subtitle: "Manage songs, albums, and styles",
                    textColor: textColor,
                    borderColor: borderColor,
                    cardColor: cardColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("About", textColor),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info,
                    title: "App Version",
                    subtitle: "1.0.0",
                    textColor: textColor,
                    borderColor: borderColor,
                    cardColor: cardColor,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.privacy_tip,
                    title: "Privacy Policy",
                    textColor: textColor,
                    borderColor: borderColor,
                    cardColor: cardColor,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    context,
                    icon: Icons.description,
                    title: "Terms of Service",
                    textColor: textColor,
                    borderColor: borderColor,
                    cardColor: cardColor,
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: textColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color textColor,
    required Color borderColor,
    required Color cardColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: textColor.withOpacity(0.2), width: 1),
                ),
                child: Icon(icon, color: textColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  (onTap != null
                      ? Icon(
                          Icons.arrow_forward_ios,
                          color: textColor.withOpacity(0.5),
                          size: 16,
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, Color textColor, Color borderColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.text_fields, color: textColor),
            const SizedBox(width: 8),
            Text("Font Size", style: TextStyle(color: textColor)),
          ],
        ),
        content: ValueListenableBuilder<double>(
          valueListenable: fontSizeNotifier,
          builder: (context, currentSize, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: fontSizes.entries.map((entry) {
                final isSelected = currentSize == entry.value;
                return GestureDetector(
                  onTap: () {
                    saveFontSize(entry.value);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? textColor.withOpacity(0.1) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? textColor : borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(entry.key, style: TextStyle(fontSize: entry.value, color: textColor)),
                        const Spacer(),
                        if (isSelected) Icon(Icons.check, color: textColor),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}