import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../models/album.dart';

class LocalStorageService {
  static const String _songsKey = 'cached_songs';
  static const String _albumsKey = 'cached_albums';
  static const String _lastSyncKey = 'last_sync_time';
  static const String _syncEnabledKey = 'sync_enabled';
  static const String _pendingSyncKey = 'pending_sync';

  static LocalStorageService? _instance;
  static SharedPreferences? _prefs;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Songs caching
  Future<void> cacheSongs(List<Song> songs) async {
    final songsJson = songs.map((s) => jsonEncode(s.toMap()..['docId'] = s.id)).toList();
    await _prefs?.setStringList(_songsKey, songsJson);
  }

  List<Song> getCachedSongs() {
    final songsJson = _prefs?.getStringList(_songsKey) ?? [];
    return songsJson.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return Song.fromMap(map, map['docId']);
    }).toList();
  }

  Future<void> cacheSong(Song song) async {
    final songs = getCachedSongs();
    final existingIndex = songs.indexWhere((s) => s.id == song.id);
    if (existingIndex >= 0) {
      songs[existingIndex] = song;
    } else {
      songs.add(song);
    }
    await cacheSongs(songs);
  }

  // Albums caching
  Future<void> cacheAlbums(List<Album> albums) async {
    final albumsJson = albums.map((a) => jsonEncode(a.toMap()..['docId'] = a.id)).toList();
    await _prefs?.setStringList(_albumsKey, albumsJson);
  }

  List<Album> getCachedAlbums() {
    final albumsJson = _prefs?.getStringList(_albumsKey) ?? [];
    return albumsJson.map((a) {
      final map = jsonDecode(a) as Map<String, dynamic>;
      return Album.fromMap(map, map['docId']);
    }).toList();
  }

  // Sync metadata
  Future<void> setLastSyncTime() async {
    await _prefs?.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  int? getLastSyncTime() {
    return _prefs?.getInt(_lastSyncKey);
  }

  String getLastSyncTimeFormatted() {
    final timestamp = getLastSyncTime();
    if (timestamp == null) return 'Never';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> setSyncEnabled(bool enabled) async {
    await _prefs?.setBool(_syncEnabledKey, enabled);
  }

  bool isSyncEnabled() {
    return _prefs?.getBool(_syncEnabledKey) ?? false;
  }

  // Pending sync queue (for offline submissions)
  Future<void> addPendingSync(Map<String, dynamic> data) async {
    final pending = getPendingSync();
    pending.add(data);
    await _prefs?.setStringList(_pendingSyncKey, pending.map(jsonEncode).toList());
  }

  List<Map<String, dynamic>> getPendingSync() {
    final pendingJson = _prefs?.getStringList(_pendingSyncKey) ?? [];
    return pendingJson.map((p) => jsonDecode(p) as Map<String, dynamic>).toList();
  }

  Future<void> clearPendingSync() async {
    await _prefs?.remove(_pendingSyncKey);
  }

  // Clear all cached data
  Future<void> clearAllCache() async {
    await _prefs?.remove(_songsKey);
    await _prefs?.remove(_albumsKey);
    await _prefs?.remove(_pendingSyncKey);
  }
}