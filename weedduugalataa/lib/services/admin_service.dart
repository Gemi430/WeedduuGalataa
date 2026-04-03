import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';
import '../models/album.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSong(Song song) async {
    await _firestore.collection('songs').doc(song.id).set(song.toMap());
  }

  Future<void> updateSong(String songId, Map<String, dynamic> data) async {
    await _firestore.collection('songs').doc(songId).update(data);
  }

  Future<void> deleteSong(String songId) async {
    await _firestore.collection('songs').doc(songId).delete();
  }

  Future<void> addAlbum(Album album) async {
    await _firestore.collection('albums').doc(album.id).set(album.toMap());
  }

  Future<void> updateAlbum(String albumId, Map<String, dynamic> data) async {
    await _firestore.collection('albums').doc(albumId).update(data);
  }

  Future<void> deleteAlbum(String albumId) async {
    await _firestore.collection('albums').doc(albumId).delete();
  }
}