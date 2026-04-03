import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';
import '../models/album.dart';

class SongService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Scales & Styles
  Future<List<String>> getSongsByScaleAndStyle(String scale, String style) async {
    final snapshot = await _firestore
        .collection('songs')
        .where('scale', isEqualTo: scale)
        .where('style', isEqualTo: style)
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Albums
  Stream<List<Album>> getAlbums() {
    return _firestore.collection('albums').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Album.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<Album?> getAlbum(String albumId) async {
    final doc = await _firestore.collection('albums').doc(albumId).get();
    if (doc.exists) {
      return Album.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<Song>> getSongsByAlbum(String albumId) async {
    final snapshot = await _firestore
        .collection('songs')
        .where('albumId', isEqualTo: albumId)
        .get();
    return snapshot.docs.map((doc) => Song.fromMap(doc.data(), doc.id)).toList();
  }

  // Singles
  Stream<List<Song>> getSingles() {
    return _firestore
        .collection('songs')
        .where('isSingle', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Song.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Single song by ID
  Future<Song?> getSong(String songId) async {
    final doc = await _firestore.collection('songs').doc(songId).get();
    if (doc.exists) {
      return Song.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Search
  Future<List<Song>> searchSongs(String query) async {
    final snapshot = await _firestore
        .collection('songs')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => Song.fromMap(doc.data(), doc.id)).toList();
  }
}