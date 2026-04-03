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
    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text("${_selected.length} selected")
            : const Text("Manage Songs"),
        actions: [
          if (_selectionMode) ...[
            IconButton(icon: const Icon(Icons.delete), color: Colors.red, onPressed: () => _bulkDelete(context)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _selected.clear(); _selectionMode = false; })),
          ] else
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: "Select multiple",
              onPressed: () => setState(() => _selectionMode = true),
            ),
        ],
      ),
      floatingActionButton: _selectionMode ? null : FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SongFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text("Add Song"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterScale,
                    decoration: const InputDecoration(labelText: "Scale", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: _scales.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _filterScale = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterStyle,
                    decoration: const InputDecoration(labelText: "Style", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: _styles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _filterStyle = v!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('songs').orderBy('title').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No songs yet. Add one!"));
                }

                var docs = snapshot.data!.docs;
                if (_filterScale != 'All') docs = docs.where((d) => d['scale'] == _filterScale).toList();
                if (_filterStyle != 'All') docs = docs.where((d) => d['style'] == _filterStyle).toList();

                if (docs.isEmpty) return const Center(child: Text("No songs match the filter"));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final song = Song.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    final isSelected = _selected.contains(song.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isSelected ? const Color(0xFF1A237E).withValues(alpha: 0.08) : null,
                      child: ListTile(
                        leading: _selectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (v) => setState(() => v! ? _selected.add(song.id) : _selected.remove(song.id)),
                              )
                            : Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.music_note, color: Colors.teal),
                              ),
                        title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text([
                          if (song.singerName != null) song.singerName!,
                          if (song.scale != null) song.scale!,
                          if (song.style != null) song.style!,
                        ].join('  ')),
                        onTap: _selectionMode
                            ? () => setState(() => isSelected ? _selected.remove(song.id) : _selected.add(song.id))
                            : null,
                        trailing: _selectionMode ? null : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SongFormScreen(song: song))),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSong(context, song.id),
                            ),
                          ],
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
