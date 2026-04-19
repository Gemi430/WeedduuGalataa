import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lyrics_submission.dart';
import 'song_form_screen.dart';

class LyricsSubmissionsAdminScreen extends StatefulWidget {
  const LyricsSubmissionsAdminScreen({super.key});

  @override
  State<LyricsSubmissionsAdminScreen> createState() => _LyricsSubmissionsAdminScreenState();
}

class _LyricsSubmissionsAdminScreenState extends State<LyricsSubmissionsAdminScreen> {
  String _filterStatus = 'pending';

  Future<void> _approveSubmission(LyricsSubmission submission) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Approve & Create Song"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("This will create a new song with the submitted lyrics."),
            const SizedBox(height: 8),
            Text("Title: ${submission.songTitle}", style: const TextStyle(fontWeight: FontWeight.bold)),
            if (submission.singerName != null) Text("Singer: ${submission.singerName}"),
            Text("Scale: ${submission.scale}"),
            Text("Style: ${submission.style}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Approve & Create", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Create the song
        final songRef = await FirebaseFirestore.instance.collection('songs').add({
          'title': submission.songTitle,
          'lyrics': submission.lyrics,
          'scale': submission.scale,
          'style': submission.style,
          'singerName': submission.singerName,
          'isSingle': true,
          'albumId': null,
          'orderIndex': 0,
        });

        // Update submission status
        await FirebaseFirestore.instance.collection('lyrics_submissions').doc(submission.id).update({
          'status': 'approved',
          'approvedAt': DateTime.now().toIso8601String(),
          'songId': songRef.id,
        });

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Song created and submission approved!")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _rejectSubmission(String id, String note) async {
    await FirebaseFirestore.instance.collection('lyrics_submissions').doc(id).update({
      'status': 'rejected',
      'rejectedAt': DateTime.now().toIso8601String(),
      'adminNote': note,
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Submission rejected")));
  }

  void _showRejectDialog(String id) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Submission"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Reason for rejection (optional):"),
            const SizedBox(height: 12),
            TextFormField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter reason..."),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _rejectSubmission(id, noteController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Reject"),
          ),
        ],
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
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Lyrics Submissions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Row(
              children: ['pending', 'approved', 'rejected'].map((status) {
                final isSelected = _filterStatus == status;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filterStatus = status),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        status[0].toUpperCase() + status.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? textColor : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lyrics_submissions')
                  .orderBy('submittedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: textColor.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text("No submissions", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data!.docs.where((d) => d['status'] == _filterStatus).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 64, color: Colors.green.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          "No ${_filterStatus} submissions",
                          style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final submission = LyricsSubmission.fromMap(doc.data() as Map<String, dynamic>);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(submission.status, isDark).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    submission.status[0].toUpperCase() + submission.status.substring(1),
                                    style: TextStyle(
                                      color: _getStatusColor(submission.status, isDark),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(submission.submittedAt),
                                  style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              submission.songTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (submission.singerName != null)
                              Text(
                                submission.singerName!,
                                style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (submission.scale.isNotEmpty)
                                  _buildChip(submission.scale, textColor),
                                if (submission.style.isNotEmpty)
                                  _buildChip(submission.style, textColor),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: textColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                submission.lyrics,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: textColor),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Submitted by: ${submission.submittedBy}",
                              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
                            ),
                            if (submission.phone != null)
                              Text(
                                "Phone: ${submission.phone}",
                                style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
                              ),
                            if (submission.status == 'pending') ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showRejectDialog(submission.id),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text("Reject"),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _approveSubmission(submission),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text("Approve"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (submission.status == 'rejected' && submission.adminNote != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Reason: ${submission.adminNote}",
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
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

  Widget _buildChip(String label, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: textColor),
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return isDark ? const Color(0xFF9FA8DA) : const Color(0xFF1A237E);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}