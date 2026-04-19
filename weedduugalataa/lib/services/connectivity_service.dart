import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_storage_service.dart';
import 'song_service.dart';

class ConnectivityService {
  static ConnectivityService? _instance;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  bool _isOnline = true;

  ConnectivityService._();

  static Future<ConnectivityService> getInstance() async {
    if (_instance == null) {
      _instance = ConnectivityService._();
      await _instance?._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    _subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    _isOnline = await _checkConnectivity();
  }

  Future<bool> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Future<void> _handleConnectivityChange(List<ConnectivityResult> results) async {
    final wasOnline = _isOnline;
    _isOnline = !results.contains(ConnectivityResult.none);
    
    // If we just came back online, sync data
    if (!wasOnline && _isOnline) {
      await _syncWhenReconnected();
    }
  }

  Future<void> _syncWhenReconnected() async {
    final localStorage = await LocalStorageService.getInstance();
    
    // Check if sync is enabled
    if (!localStorage.isSyncEnabled()) return;
    
    // Check for pending sync items
    final pending = localStorage.getPendingSync();
    if (pending.isNotEmpty) {
      // Upload pending data to Firestore
      // This would be implemented in a full sync service
      await localStorage.clearPendingSync();
    }
    
    // Download all songs and albums for offline use
    final songService = SongService();
    await songService.syncAllData();
  }

  bool get isOnline => _isOnline;

  Future<bool> checkOnline() async {
    return await _checkConnectivity();
  }

  void dispose() {
    _subscription?.cancel();
  }
}