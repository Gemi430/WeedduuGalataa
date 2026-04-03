import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';
import '../models/scale.dart';
import '../models/album.dart';

class SongFormScreen extends StatefulWidget {
  final Song? song;
  const SongFormScreen({super.key, this.song});

  @override
  State<SongFormScreen> createState() => _SongFormScreenState();
}

class _SongFormScreenState extends State<SongFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _singerController = TextEditingController();
  String? _selectedScale;
  String? _selectedStyle;
  String? _selectedAlbumId;
  bool _isSingle = false;
  bool _loading = false;
  List<Album> _albums = [];

  bool get _isEditing => widget.song != null;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
    if (_isEditing) {
      _titleController.text = widget.song!.title;
      _lyricsController.text = widget.song!.lyrics;
      _singerController.text = widget.song!.singerName ?? '';
      _selectedScale = widget.song!.scale;
      _selectedStyle = widget.song!.style;
      _selectedAlbumId = widget.song!.albumId;
      _isSingle = widget.song!.isSingle;
    }
  }

  Future<void> _loadAlbums() async {
    final snap = await FirebaseFirestore.instance.collection('albums').get();
    setState(() {
      _albums = snap.docs.map((d) => Album.fromMap(d.data(), d.id)).toList();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
    _singerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = {
        'title': _titleController.text.trim(),
        'lyrics': _lyricsController.text.trim(),
        'scale': _selectedScale,
        'style': _selectedStyle,
        'isSingle': _isSingle,
        'albumId': _selectedAlbumId,
        'singerName': _singerController.text.trim().isEmpty ? null : _singerController.text.trim(),
        'orderIndex': widget.song?.orderIndex ?? 0,
      };

      final db = FirebaseFirestore.instance;

      if (_isEditing) {
        await db.collection('songs').doc(widget.song!.id).update(data);
        // Update album assignment if changed
        await _updateAlbumAssignment(widget.song!.id, widget.song!.albumId, _selectedAlbumId);
      } else {
        final ref = await db.collection('songs').add(data);
        if (_selectedAlbumId != null) {
          await _addSongToAlbum(ref.id, _selectedAlbumId!);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? "Song updated!" : "Song added!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateAlbumAssignment(String songId, String? oldAlbumId, String? newAlbumId) async {
    final db = FirebaseFirestore.instance;
    if (oldAlbumId == newAlbumId) return;
    // Remove from old album
    if (oldAlbumId != null) {
      final oldAlbum = await db.collection('albums').doc(oldAlbumId).get();
      if (oldAlbum.exists) {
        final ids = List<String>.from(oldAlbum.data()!['songIds'] ?? []);
        ids.remove(songId);
        await db.collection('albums').doc(oldAlbumId).update({'songIds': ids});
      }
    }
    // Add to new album
    if (newAlbumId != null) {
      await _addSongToAlbum(songId, newAlbumId);
    }
  }

  Future<void> _addSongToAlbum(String songId, String albumId) async {
    final db = FirebaseFirestore.instance;
    final album = await db.collection('albums').doc(albumId).get();
    if (album.exists) {
      final ids = List<String>.from(album.data()!['songIds'] ?? []);
      if (!ids.contains(songId)) {
        ids.add(songId);
        await db.collection('albums').doc(albumId).update({'songIds': ids});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "Edit Song" : "Add Song")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Song Title *", border: OutlineInputBorder()),
                validator: (v) => v!.trim().isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _singerController,
                decoration: const InputDecoration(labelText: "Singer Name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedScale,
                decoration: const InputDecoration(labelText: "Scale", border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text("None")),
                  ...MusicScale.allScales.map((s) => DropdownMenuItem(value: s.id, child: Text(s.displayName))),
                ],
                onChanged: (v) => setState(() => _selectedScale = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStyle,
                decoration: const InputDecoration(labelText: "Style", border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text("None")),
                  ...MusicScale.allStyles.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (v) => setState(() => _selectedStyle = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAlbumId,
                decoration: const InputDecoration(labelText: "Album (optional)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.album)),
                items: [
                  const DropdownMenuItem(value: null, child: Text("No Album")),
                  ..._albums.map((a) => DropdownMenuItem(value: a.id, child: Text(a.title))),
                ],
                onChanged: (v) => setState(() => _selectedAlbumId = v),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text("Is Single"),
                subtitle: const Text("Mark this song as a single"),
                value: _isSingle,
                onChanged: (v) => setState(() => _isSingle = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lyricsController,
                maxLines: 14,
                decoration: const InputDecoration(
                  labelText: "Lyrics *",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.trim().isEmpty ? "Lyrics are required" : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isEditing ? "Update Song" : "Add Song", style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
