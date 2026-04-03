import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> get _userId async {
    User? user = _auth.currentUser;
    if (user == null) {
      final cred = await _auth.signInAnonymously();
      user = cred.user;
    }
    return user?.uid;
  }

  CollectionReference? _favRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  Stream<List<String>> favoritesStream() {
    return Stream.fromFuture(_userId).asyncExpand((uid) {
      if (uid == null) return const Stream.empty();
      return _favRef(uid)!.snapshots().map(
            (snap) => snap.docs.map((d) => d.id).toList(),
          );
    });
  }

  Future<bool> isFavorite(String songId) async {
    final uid = await _userId;
    if (uid == null) return false;
    final doc = await _favRef(uid)!.doc(songId).get();
    return doc.exists;
  }

  Future<void> toggleFavorite(String songId, String title) async {
    final uid = await _userId;
    if (uid == null) return;
    final ref = _favRef(uid)!.doc(songId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({'title': title, 'addedAt': FieldValue.serverTimestamp()});
    }
    debugPrint(doc.exists ? "Removed from favorites" : "Added to favorites");
  }
}
