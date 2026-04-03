import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/album.dart';

class AlbumFormScreen extends StatefulWidget {
  final Album? album;
  const AlbumFormScreen({super.key, this.album});

  @override
  State<AlbumFormScreen> createState() => _AlbumFormScreenState();
}

class _AlbumFormScreenState extends State<AlbumFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _loading = false;

  bool get _isEditing => widget.album != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.album!.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = {
        'title': _titleController.text.trim(),
        'coverImageUrl': null,
        'songIds': _isEditing ? widget.album!.songIds : [],
      };
      if (_isEditing) {
        await FirebaseFirestore.instance.collection('albums').doc(widget.album!.id).update({'title': data['title']});
      } else {
        await FirebaseFirestore.instance.collection('albums').add(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? "Album updated!" : "Album added!")),
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
      appBar: AppBar(title: Text(_isEditing ? "Edit Album" : "Add Album")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Album Title", border: OutlineInputBorder()),
                validator: (v) => v!.trim().isEmpty ? "Title is required" : null,
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
                      : Text(_isEditing ? "Update Album" : "Add Album", style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
