import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';
import '../models/scale.dart';

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
  String? _selectedScale;
  String? _selectedStyle;
  bool _isSingle = false;
  bool _loading = false;

  bool get _isEditing => widget.song != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.song!.title;
      _lyricsController.text = widget.song!.lyrics;
      _selectedScale = widget.song!.scale;
      _selectedStyle = widget.song!.style;
      _isSingle = widget.song!.isSingle;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
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
        'albumId': null,
      };
      if (_isEditing) {
        await FirebaseFirestore.instance.collection('songs').doc(widget.song!.id).update(data);
      } else {
        await FirebaseFirestore.instance.collection('songs').add(data);
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
                decoration: const InputDecoration(labelText: "Song Title", border: OutlineInputBorder()),
                validator: (v) => v!.trim().isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedScale,
                decoration: const InputDecoration(labelText: "Scale", border: OutlineInputBorder()),
                items: MusicScale.allScales.map((s) => DropdownMenuItem(value: s.id, child: Text(s.displayName))).toList(),
                onChanged: (v) => setState(() => _selectedScale = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStyle,
                decoration: const InputDecoration(labelText: "Style", border: OutlineInputBorder()),
                items: MusicScale.allStyles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedStyle = v),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Is Single"),
                subtitle: const Text("Mark this song as a single"),
                value: _isSingle,
                onChanged: (v) => setState(() => _isSingle = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lyricsController,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: "Lyrics",
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
