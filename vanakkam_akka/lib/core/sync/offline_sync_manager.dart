import 'dart:async';
import 'dart:collection';

/// Manages offline data sync for areas with limited connectivity
/// Critical for rural deployment where internet is intermittent
class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

  final Queue<SyncOperation> _pendingOperations = Queue<SyncOperation>();
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  /// Whether there are pending operations to sync
  bool get hasPendingSync => _pendingOperations.isNotEmpty;

  /// Number of operations waiting to sync
  int get pendingCount => _pendingOperations.length;

  /// Last successful sync timestamp
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Queue a data operation for syncing when connectivity is available
  void enqueue(SyncOperation operation) {
    _pendingOperations.add(operation);
  }

  /// Attempt to sync all pending operations
  /// Returns the number of successfully synced operations
  Future<int> syncAll() async {
    if (_isSyncing || _pendingOperations.isEmpty) return 0;

    _isSyncing = true;
    int syncedCount = 0;

    try {
      while (_pendingOperations.isNotEmpty) {
        final operation = _pendingOperations.first;
        final success = await _performSync(operation);
        if (success) {
          _pendingOperations.removeFirst();
          syncedCount++;
        } else {
          break; // Stop on first failure - likely no connectivity
        }
      }
      if (syncedCount > 0) {
        _lastSyncTime = DateTime.now();
      }
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }

  /// Perform a single sync operation
  Future<bool> _performSync(SyncOperation operation) async {
    // TODO: Implement actual sync logic with backend API
    // This will involve:
    // 1. Checking network connectivity
    // 2. Sending data to the server
    // 3. Handling conflict resolution
    // 4. Updating local storage with server response
    await Future.delayed(const Duration(milliseconds: 100)); // Placeholder
    return false;
  }
}

/// Represents a data operation to be synced
class SyncOperation {
  final String id;
  final String type; // 'create', 'update', 'delete'
  final String collection; // e.g., 'health_records', 'cycle_data'
  final Map<String, dynamic> data;
  final DateTime createdAt;

  SyncOperation({
    required this.id,
    required this.type,
    required this.collection,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
