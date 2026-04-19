import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/style.dart';

class StylesAdminScreen extends StatefulWidget {
  const StylesAdminScreen({super.key});

  @override
  State<StylesAdminScreen> createState() => _StylesAdminScreenState();
}

class _StylesAdminScreenState extends State<StylesAdminScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _loading = false;
  String? _editingId;

  Future<void> _saveStyle() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (_editingId != null) {
        await FirebaseFirestore.instance.collection('styles').doc(_editingId).update(data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Style updated!")));
      } else {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance.collection('styles').doc(id).set({
          'id': id,
          'name': _nameController.text.trim(),
          'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          'createdAt': DateTime.now().toIso8601String(),
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Style added!")));
      }

      _nameController.clear();
      _descController.clear();
      _editingId = null;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteStyle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Style"),
        content: const Text("Are you sure? This may affect songs using this style."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('styles').doc(id).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Style deleted")));
    }
  }

  void _editStyle(String id, String name, String? desc) {
    setState(() {
      _editingId = id;
      _nameController.text = name;
      _descController.text = desc ?? '';
    });
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
          "Manage Styles",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: inputFillColor,
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingId != null ? "Edit Style" : "Add New Style",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Style Name",
                      labelStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor, width: 1.5),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Description (optional)",
                      labelStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor, width: 1.5),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _saveStyle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_editingId != null ? "Update Style" : "Add Style", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('styles').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.style, size: 64, color: textColor.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text("No styles yet. Add one above!", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final style = MusicStyle.fromMap(data);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: inputFillColor,
                        border: Border.all(color: borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.style, color: textColor),
                        ),
                        title: Text(style.name, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        subtitle: style.description != null ? Text(style.description!) : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: textColor.withOpacity(0.7)),
                              onPressed: () => _editStyle(doc.id, style.name, style.description),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStyle(doc.id),
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