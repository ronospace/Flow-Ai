import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../database/database_service.dart';

/// Offline mode service for handling connectivity and data synchronization
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  late Connectivity _connectivity;
  late SharedPreferences _prefs;
  late DatabaseService _databaseService;
  
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  bool _isOffline = true;
  
  // Sync queue for operations to perform when online
  final List<PendingSyncOperation> _syncQueue = [];
  
  // Stream controllers for connectivity changes
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  final StreamController<List<PendingSyncOperation>> _syncQueueController = 
      StreamController<List<PendingSyncOperation>>.broadcast();

  // Keys for SharedPreferences
  static const String _syncQueueKey = 'offline_sync_queue';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _offlineModeEnabledKey = 'offline_mode_enabled';

  // Getters
  Stream<bool> get connectivityStream => _connectivityController.stream;
  Stream<List<PendingSyncOperation>> get syncQueueStream => _syncQueueController.stream;
  bool get isOffline => _isOffline;
  bool get isOnline => !_isOffline;
  List<PendingSyncOperation> get syncQueue => List.unmodifiable(_syncQueue);
  
  /// Initialize offline service
  Future<void> initialize() async {
    _connectivity = Connectivity();
    _prefs = await SharedPreferences.getInstance();
    _databaseService = DatabaseService();
    
    // Load sync queue from storage
    await _loadSyncQueue();
    
    // Check initial connectivity
    await _checkConnectivity();
    
    // Listen for connectivity changes (using older API which expects single ConnectivityResult)
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _onConnectivityChanged([result]);
    });
    
    debugPrint('🔄 Offline Service initialized - Status: ${_isOffline ? 'Offline' : 'Online'}');
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      _connectionStatus = [result];
      await _updateConnectivityStatus(_connectionStatus);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      _isOffline = true;
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    _connectionStatus = results;
    await _updateConnectivityStatus(results);
    
    // If we're back online, process sync queue
    if (isOnline && _syncQueue.isNotEmpty) {
      await processSyncQueue();
    }
  }

  /// Update connectivity status and notify listeners
  Future<void> _updateConnectivityStatus(List<ConnectivityResult> results) async {
    final wasOffline = _isOffline;
    
    // Check if we have actual internet connectivity, not just network connection
    _isOffline = results.contains(ConnectivityResult.none) || results.isEmpty || !(await _hasInternetAccess());
    
    if (wasOffline != _isOffline) {
      debugPrint('Connectivity changed: ${_isOffline ? 'OFFLINE' : 'ONLINE'}');
      _connectivityController.add(isOnline);
      
      // Update last sync timestamp when going online
      if (isOnline) {
        await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      }
    }
  }

  /// Test actual internet connectivity by pinging a reliable server
  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Add operation to sync queue when offline
  Future<void> addToSyncQueue(PendingSyncOperation operation) async {
    _syncQueue.add(operation);
    await _saveSyncQueue();
    _syncQueueController.add(_syncQueue);
    
    debugPrint('Added operation to sync queue: ${operation.type} - ${operation.id}');
  }

  /// Process all operations in sync queue
  Future<void> processSyncQueue() async {
    if (_syncQueue.isEmpty || _isOffline) return;
    
    debugPrint('Processing ${_syncQueue.length} queued operations...');
    final completedOperations = <PendingSyncOperation>[];
    
    for (final operation in _syncQueue) {
      try {
        final success = await _processOperation(operation);
        if (success) {
          completedOperations.add(operation);
          debugPrint('Synced operation: ${operation.type} - ${operation.id}');
        }
      } catch (e) {
        debugPrint('Failed to sync operation ${operation.id}: $e');
      }
    }
    
    // Remove completed operations
    for (final operation in completedOperations) {
      _syncQueue.remove(operation);
    }
    
    if (completedOperations.isNotEmpty) {
      await _saveSyncQueue();
      _syncQueueController.add(_syncQueue);
      
      // Update last sync timestamp
      await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    }
    
    debugPrint('Sync completed. Remaining operations: ${_syncQueue.length}');
  }

  /// Process individual sync operation
  Future<bool> _processOperation(PendingSyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.createCycle:
        return await _syncCreateCycle(operation);
      case SyncOperationType.updateCycle:
        return await _syncUpdateCycle(operation);
      case SyncOperationType.createDailyTracking:
        return await _syncCreateDailyTracking(operation);
      case SyncOperationType.updateDailyTracking:
        return await _syncUpdateDailyTracking(operation);
      case SyncOperationType.uploadSettings:
        return await _syncUploadSettings(operation);
    }
  }

  /// Sync cycle creation to server
  Future<bool> _syncCreateCycle(PendingSyncOperation operation) async {
    // In a real implementation, this would upload to your backend server
    // For now, we'll just mark it as synced
    debugPrint('Syncing cycle creation: ${operation.data}');
    return true;
  }

  /// Sync cycle update to server
  Future<bool> _syncUpdateCycle(PendingSyncOperation operation) async {
    debugPrint('Syncing cycle update: ${operation.data}');
    return true;
  }

  /// Sync daily tracking creation to server
  Future<bool> _syncCreateDailyTracking(PendingSyncOperation operation) async {
    debugPrint('Syncing daily tracking creation: ${operation.data}');
    return true;
  }

  /// Sync daily tracking update to server
  Future<bool> _syncUpdateDailyTracking(PendingSyncOperation operation) async {
    debugPrint('Syncing daily tracking update: ${operation.data}');
    return true;
  }

  /// Sync settings upload to server
  Future<bool> _syncUploadSettings(PendingSyncOperation operation) async {
    debugPrint('Syncing settings upload: ${operation.data}');
    return true;
  }

  /// Get last sync timestamp
  DateTime? getLastSyncTime() {
    final timestampString = _prefs.getString(_lastSyncKey);
    if (timestampString != null) {
      return DateTime.parse(timestampString);
    }
    return null;
  }

  /// Check if offline mode is enabled by user preference
  bool isOfflineModeEnabled() {
    return _prefs.getBool(_offlineModeEnabledKey) ?? true; // Default enabled
  }

  /// Enable/disable offline mode
  Future<void> setOfflineModeEnabled(bool enabled) async {
    await _prefs.setBool(_offlineModeEnabledKey, enabled);
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    _syncQueue.clear();
    await _saveSyncQueue();
    _syncQueueController.add(_syncQueue);
  }

  /// Force sync now (if online)
  Future<bool> forceSyncNow() async {
    if (_isOffline) {
      debugPrint('Cannot force sync - device is offline');
      return false;
    }
    
    await processSyncQueue();
    return _syncQueue.isEmpty;
  }

  /// Get sync status information
  Map<String, dynamic> getSyncStatus() {
    return {
      'isOffline': _isOffline,
      'connectionTypes': _connectionStatus.map((e) => e.name).toList(),
      'pendingOperations': _syncQueue.length,
      'lastSyncTime': getLastSyncTime()?.toIso8601String(),
      'offlineModeEnabled': isOfflineModeEnabled(),
    };
  }

  /// Save sync queue to persistent storage
  Future<void> _saveSyncQueue() async {
    final queueJson = _syncQueue.map((op) => op.toJson()).toList();
    await _prefs.setString(_syncQueueKey, json.encode(queueJson));
  }

  /// Load sync queue from persistent storage
  Future<void> _loadSyncQueue() async {
    final queueString = _prefs.getString(_syncQueueKey);
    if (queueString != null) {
      final List<dynamic> queueJson = json.decode(queueString);
      _syncQueue.clear();
      _syncQueue.addAll(
        queueJson.map((json) => PendingSyncOperation.fromJson(json))
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivityController.close();
    _syncQueueController.close();
  }
}

/// Enumeration for different types of sync operations
enum SyncOperationType {
  createCycle,
  updateCycle,
  createDailyTracking,
  updateDailyTracking,
  uploadSettings,
}

/// Model for pending sync operations
class PendingSyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  PendingSyncOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  /// Create a new operation with incremented retry count
  PendingSyncOperation withRetry() {
    return PendingSyncOperation(
      id: id,
      type: type,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount + 1,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  /// Create from JSON
  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) {
    return PendingSyncOperation(
      id: json['id'],
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      retryCount: json['retryCount'] ?? 0,
    );
  }
}

/// Utility mixin for widgets that need to handle offline mode
mixin OfflineCapableMixin<T extends StatefulWidget> on State<T> {
  late StreamSubscription<bool> _connectivitySubscription;
  bool _isOffline = true;

  bool get isOffline => _isOffline;
  bool get isOnline => !_isOffline;

  @override
  void initState() {
    super.initState();
    _initializeOfflineCapability();
  }

  void _initializeOfflineCapability() {
    final offlineService = OfflineService();
    _isOffline = offlineService.isOffline;
    
    _connectivitySubscription = offlineService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOffline = !isOnline;
        });
        
        if (isOnline) {
          onConnectionRestored();
        } else {
          onConnectionLost();
        }
      }
    });
  }

  /// Override this method to handle connection restoration
  void onConnectionRestored() {
    // Override in child classes
  }

  /// Override this method to handle connection loss
  void onConnectionLost() {
    // Override in child classes
  }

  /// Show offline message to user
  void showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: const Text('You are currently offline. Changes will be synced when connection is restored.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Show online message to user
  void showOnlineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: const Text('Connection restored. Syncing data...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
