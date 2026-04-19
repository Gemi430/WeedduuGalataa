import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scale.dart';
import '../models/style.dart';

class LyricsSubmissionScreen extends StatefulWidget {
  const LyricsSubmissionScreen({super.key});

  @override
  State<LyricsSubmissionScreen> createState() => _LyricsSubmissionScreenState();
}

class _LyricsSubmissionScreenState extends State<LyricsSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _singerController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedScale;
  String? _selectedStyle;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _singerController.dispose();
    _lyricsController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance.collection('lyrics_submissions').doc(id).set({
        'id': id,
        'songTitle': _titleController.text.trim(),
        'singerName': _singerController.text.trim().isEmpty ? null : _singerController.text.trim(),
        'lyrics': _lyricsController.text.trim(),
        'scale': _selectedScale,
        'style': _selectedStyle,
        'submittedBy': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'submittedAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              "Submission Received!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Thank you! Your lyrics have been submitted for review. We'll add it after verification.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
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
        title: const Text(
          "Submit Lyrics",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.08),
                  border: Border.all(color: textColor.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.lyrics, size: 40, color: textColor.withOpacity(0.6)),
                    const SizedBox(height: 12),
                    Text(
                      "Contribute to Our Library",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Submit lyrics for songs you know. Our team will review and add them after verification.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Song Information", textColor),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _titleController,
                label: "Song Title *",
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _singerController,
                label: "Singer Name (optional)",
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<String>(
                      value: _selectedScale,
                      items: [const DropdownMenuItem<String>(value: null, child: Text("Scale"))] +
                          MusicScale.allScales.map((s) => DropdownMenuItem<String>(value: s.id, child: Text(s.displayName))).toList(),
                      textColor: textColor,
                      borderColor: borderColor,
                      fillColor: inputFillColor,
                      onChanged: (v) => setState(() => _selectedScale = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown<String>(
                      value: _selectedStyle,
                      items: [const DropdownMenuItem<String>(value: null, child: Text("Style"))] +
                          MusicScale.allStyles.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                      textColor: textColor,
                      borderColor: borderColor,
                      fillColor: inputFillColor,
                      onChanged: (v) => setState(() => _selectedStyle = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lyricsController,
                label: "Lyrics *",
                maxLines: 10,
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Your Information", textColor),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: "Your Name *",
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: "Phone (optional)",
                textColor: textColor,
                borderColor: borderColor,
                fillColor: inputFillColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: textColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Submit Lyrics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "We'll review and add within 24-48 hours",
                  style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
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
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color textColor,
    required Color borderColor,
    required Color fillColor,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
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

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Color textColor,
    required Color borderColor,
    required Color fillColor,
    required ValueChanged<T?> onChanged,
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
          decoration: const InputDecoration(border: InputBorder.none),
          style: TextStyle(color: textColor, fontSize: 14),
          items: items,
          onChanged: (v) => onChanged(v),
        ),
      ),
    );
  }
}