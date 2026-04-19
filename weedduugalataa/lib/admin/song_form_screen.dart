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
  List<String> _styles = MusicScale.allStyles;

  bool get _isEditing => widget.song != null;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Future<void> _loadData() async {
    final albumsSnap = await FirebaseFirestore.instance.collection('albums').get();
    final stylesSnap = await FirebaseFirestore.instance.collection('styles').get();

    setState(() {
      _albums = albumsSnap.docs.map((d) => Album.fromMap(d.data(), d.id)).toList();
      if (stylesSnap.docs.isNotEmpty) {
        _styles = stylesSnap.docs.map((d) => d['name'] as String).toList();
      }
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
    if (oldAlbumId != null) {
      final oldAlbum = await db.collection('albums').doc(oldAlbumId).get();
      if (oldAlbum.exists) {
        final ids = List<String>.from(oldAlbum.data()!['songIds'] ?? []);
        ids.remove(songId);
        await db.collection('albums').doc(oldAlbumId).update({'songIds': ids});
      }
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? Colors.black : const Color(0xFF1A237E);
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final inputFillColor = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? "Edit Song" : "Add Song",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: "Song Title *",
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _singerController,
                label: "Singer Name",
                icon: Icons.person,
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedScale,
                items: [const DropdownMenuItem(value: null, child: Text("None")), ...MusicScale.allScales.map((s) => DropdownMenuItem(value: s.id, child: Text(s.displayName)))],
                label: "Scale",
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
                onChanged: (v) => setState(() => _selectedScale = v),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedStyle,
                items: [const DropdownMenuItem(value: null, child: Text("None")), ..._styles.map((s) => DropdownMenuItem(value: s, child: Text(s)))],
                label: "Style",
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
                onChanged: (v) => setState(() => _selectedStyle = v),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedAlbumId,
                items: [const DropdownMenuItem(value: null, child: Text("No Album")), ..._albums.map((a) => DropdownMenuItem(value: a.id, child: Text(a.title)))],
                label: "Album (optional)",
                icon: Icons.album,
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
                onChanged: (v) => setState(() => _selectedAlbumId = v),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.08),
                  border: Border.all(color: textColor.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Is Single", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
                        Text("Mark this song as a single", style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
                      ],
                    ),
                    Switch(
                      value: _isSingle,
                      onChanged: (v) => setState(() => _isSingle = v),
                      activeColor: textColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lyricsController,
                label: "Lyrics *",
                maxLines: 14,
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: textColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isEditing ? "Update Song" : "Add Song",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color textColor,
    required Color borderColor,
    required Color fillColor,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        prefixIcon: icon != null ? Icon(icon, color: textColor) : null,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textColor, width: 2),
        ),
      ),
      style: TextStyle(color: textColor),
      validator: (v) => v!.trim().isEmpty ? "$label is required" : null,
    );
  }

  Widget _buildDropdown({
    required dynamic value,
    required List<DropdownMenuItem> items,
    required String label,
    required Color textColor,
    required Color borderColor,
    required Color fillColor,
    required ValueChanged onChanged,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField(
          value: value,
          dropdownColor: fillColor,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: textColor),
            prefixIcon: icon != null ? Icon(icon, color: textColor) : null,
            border: InputBorder.none,
          ),
          style: TextStyle(color: textColor, fontSize: 15),
          items: items,
          onChanged: (v) => onChanged(v),
        ),
      ),
    );
  }
}