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
      if (_isEditing) {
        await FirebaseFirestore.instance.collection('albums').doc(widget.album!.id).update({
          'title': _titleController.text.trim(),
        });
      } else {
        await FirebaseFirestore.instance.collection('albums').add({
          'title': _titleController.text.trim(),
          'coverImageUrl': null,
          'songIds': [],
        });
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
          _isEditing ? "Edit Album" : "Add Album",
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.08),
                  border: Border.all(color: textColor.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.album, size: 48, color: textColor.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text(
                      _isEditing ? "Update album details" : "Create a new album",
                      style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Album Title",
                  labelStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(Icons.album, color: textColor),
                  filled: true,
                  fillColor: inputFillColor,
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
                style: TextStyle(color: textColor, fontSize: 15),
                validator: (v) => v!.trim().isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 28),
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
                          _isEditing ? "Update Album" : "Add Album",
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
}