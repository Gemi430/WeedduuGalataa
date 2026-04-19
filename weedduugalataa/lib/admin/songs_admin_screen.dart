import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';
import 'song_form_screen.dart';

class SongsAdminScreen extends StatefulWidget {
  const SongsAdminScreen({super.key});

  @override
  State<SongsAdminScreen> createState() => _SongsAdminScreenState();
}

class _SongsAdminScreenState extends State<SongsAdminScreen> {
  final Set<String> _selected = {};
  bool _selectionMode = false;
  String _filterScale = 'All';
  String _filterStyle = 'All';

  final List<String> _scales = ['All', '1st', '2nd', '5th', '6th'];
  final List<String> _styles = ['All', 'Waltz', 'Slow Rock', 'Reggae', 'Chikchika', 'Wallo', 'Disco'];

  Future<void> _deleteSong(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Song"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('songs').doc(id).delete();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Song deleted")));
    }
  }

  Future<void> _bulkDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Selected"),
        content: Text("Delete ${_selected.length} songs?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete All", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in _selected) {
        batch.delete(FirebaseFirestore.instance.collection('songs').doc(id));
      }
      await batch.commit();
      setState(() { _selected.clear(); _selectionMode = false; });
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Songs deleted")));
    }
  }

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
        title: Text(
          _selectionMode ? "${_selected.length} selected" : "Manage Songs",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _bulkDelete(context),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() { _selected.clear(); _selectionMode = false; }),
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.checklist, color: Colors.white),
              tooltip: "Select multiple",
              onPressed: () => setState(() => _selectionMode = true),
            ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SongFormScreen())),
              icon: const Icon(Icons.add),
              label: const Text("Add Song"),
              backgroundColor: textColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
      body: Column(
        children: [
          Container(
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      border: Border.all(color: borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterScale,
                        isExpanded: true,
                        dropdownColor: cardColor,
                        items: _scales.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: textColor)))).toList(),
                        onChanged: (v) => setState(() => _filterScale = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      border: Border.all(color: borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterStyle,
                        isExpanded: true,
                        dropdownColor: cardColor,
                        items: _styles.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: textColor)))).toList(),
                        onChanged: (v) => setState(() => _filterStyle = v!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('songs').orderBy('title').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_off, size: 64, color: textColor.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text("No songs yet. Add one!", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data!.docs;
                if (_filterScale != 'All') docs = docs.where((d) => d['scale'] == _filterScale).toList();
                if (_filterStyle != 'All') docs = docs.where((d) => d['style'] == _filterStyle).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: textColor.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text("No songs match the filter", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final song = Song.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    final isSelected = _selected.contains(song.id);

                    return GestureDetector(
                      onTap: _selectionMode
                          ? () => setState(() => isSelected ? _selected.remove(song.id) : _selected.add(song.id))
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? textColor.withOpacity(0.08) : cardColor,
                          border: Border.all(color: isSelected ? textColor : borderColor, width: isSelected ? 2 : 1.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              if (_selectionMode)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected ? textColor : Colors.transparent,
                                    border: Border.all(color: textColor, width: 2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isSelected ? Icon(Icons.check, size: 16, color: isDark ? Colors.black : Colors.white) : null,
                                )
                              else
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: textColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor, width: 1),
                                  ),
                                  child: Icon(Icons.music_note, color: textColor, size: 22),
                                ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      [
                                        if (song.singerName != null) song.singerName!,
                                        if (song.scale != null) song.scale!,
                                        if (song.style != null) song.style!,
                                      ].join('  '),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!_selectionMode)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: textColor.withOpacity(0.7)),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => SongFormScreen(song: song)),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteSong(context, song.id),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}