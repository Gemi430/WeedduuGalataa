import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';
import '../models/album.dart';
import 'local_storage_service.dart';

class SongService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LocalStorageService? _localStorage;

  SongService({LocalStorageService? localStorage}) {
    _localStorage = localStorage;
  }

  Future<LocalStorageService> _getLocalStorage() async {
    _localStorage ??= await LocalStorageService.getInstance();
    return _localStorage!;
  }

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
    return _firestore.collection('albums').snapshots().asyncMap((snapshot) async {
      final albums = snapshot.docs.map((doc) => Album.fromMap(doc.data(), doc.id)).toList();
      // Cache albums for offline use
      final localStorage = await _getLocalStorage();
      await localStorage.cacheAlbums(albums);
      return albums;
    });
  }

  Future<Album?> getAlbum(String albumId) async {
    final doc = await _firestore.collection('albums').doc(albumId).get();
    if (doc.exists) {
      final album = Album.fromMap(doc.data()!, albumId);
      // Cache single album
      final localStorage = await _getLocalStorage();
      final albums = localStorage.getCachedAlbums();
      final existingIndex = albums.indexWhere((a) => a.id == albumId);
      if (existingIndex >= 0) {
        albums[existingIndex] = album;
      } else {
        albums.add(album);
      }
      await localStorage.cacheAlbums(albums);
      return album;
    }
    return null;
  }

  Future<List<Song>> getSongsByAlbum(String albumId) async {
    final snapshot = await _firestore
        .collection('songs')
        .where('albumId', isEqualTo: albumId)
        .get();
    final songs = snapshot.docs.map((doc) => Song.fromMap(doc.data(), doc.id)).toList();
    // Cache songs
    final localStorage = await _getLocalStorage();
    for (final song in songs) {
      await localStorage.cacheSong(song);
    }
    return songs;
  }

  // All songs
  Stream<List<Song>> getAllSongs() {
    return _firestore
        .collection('songs')
        .orderBy('title')
        .snapshots()
        .asyncMap((snapshot) async {
      final songs = snapshot.docs.map((doc) => Song.fromMap(doc.data(), doc.id)).toList();
      // Cache all songs for offline use
      final localStorage = await _getLocalStorage();
      await localStorage.cacheSongs(songs);
      return songs;
    });
  }

  // Singles
  Stream<List<Song>> getSingles() {
    return _firestore
        .collection('songs')
        .where('isSingle', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final songs = snapshot.docs.map((doc) => Song.fromMap(doc.data(), doc.id)).toList();
      // Cache singles
      final localStorage = await _getLocalStorage();
      await localStorage.cacheSongs(songs);
      return songs;
    });
  }

  // Single song by ID
  Future<Song?> getSong(String songId) async {
    final localStorage = await _getLocalStorage();
    
    // Try local cache first
    final cachedSongs = localStorage.getCachedSongs();
    final cachedSong = cachedSongs.firstWhere((s) => s.id == songId, orElse: () => Song(id: songId, title: '', lyrics: ''));
    if (cachedSong.lyrics.isNotEmpty) {
      return cachedSong;
    }
    
    // Fetch from Firestore if not in cache
    final doc = await _firestore.collection('songs').doc(songId).get();
    if (doc.exists) {
      final song = Song.fromMap(doc.data()!, doc.id);
      await localStorage.cacheSong(song);
      return song;
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

  // Offline access methods
  Future<List<Song>> getOfflineSongs() async {
    final localStorage = await _getLocalStorage();
    return localStorage.getCachedSongs();
  }

  Future<List<Album>> getOfflineAlbums() async {
    final localStorage = await _getLocalStorage();
    return localStorage.getCachedAlbums();
  }

  Future<Song?> getOfflineSong(String songId) async {
    final localStorage = await _getLocalStorage();
    final songs = localStorage.getCachedSongs();
    try {
      return songs.firstWhere((s) => s.id == songId);
    } catch (e) {
      return null;
    }
  }

  // Sync status
  Future<String> getLastSyncTime() async {
    final localStorage = await _getLocalStorage();
    return localStorage.getLastSyncTimeFormatted();
  }

  Future<bool> isSyncEnabled() async {
    final localStorage = await _getLocalStorage();
    return localStorage.isSyncEnabled();
  }

  Future<void> setSyncEnabled(bool enabled) async {
    final localStorage = await _getLocalStorage();
    await localStorage.setSyncEnabled(enabled);
  }

  // Full sync - download all data for offline use
  Future<void> syncAllData() async {
    final localStorage = await _getLocalStorage();
    
    // Fetch all songs
    final songsSnapshot = await _firestore.collection('songs').get();
    final songs = songsSnapshot.docs.map((doc) => Song.fromMap(doc.data(), doc.id)).toList();
    await localStorage.cacheSongs(songs);

    // Fetch all albums
    final albumsSnapshot = await _firestore.collection('albums').get();
    final albums = albumsSnapshot.docs.map((doc) => Album.fromMap(doc.data(), doc.id)).toList();
    await localStorage.cacheAlbums(albums);

    // Update sync time
    await localStorage.setLastSyncTime();
  }
}