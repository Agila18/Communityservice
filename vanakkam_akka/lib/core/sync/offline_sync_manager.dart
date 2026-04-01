import 'dart:convert';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:workmanager/workmanager.dart';

enum SyncType { CREATE_SCREENING, UPDATE_CYCLE, UPLOAD_RECORD, SAVE_REMINDER, VHN_VISIT_NOTE }

/// Formalized structural action binding mapping decoupled intents specifically down into native Caches.
class SyncAction {
  final String id;
  final SyncType type;
  final String endpoint;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  int retries;
  DateTime? lastAttempt;
  bool isFailed;

  SyncAction({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.payload,
    required this.timestamp,
    this.retries = 0,
    this.lastAttempt,
    this.isFailed = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.toString(),
    'endpoint': endpoint,
    'payload': jsonEncode(payload),
    'timestamp': timestamp.toIso8601String(),
    'retries': retries,
    'lastAttempt': lastAttempt?.toIso8601String(),
    'isFailed': isFailed,
  };

  factory SyncAction.fromMap(Map<String, dynamic> map) => SyncAction(
    id: map['id'],
    type: SyncType.values.firstWhere((e) => e.toString() == map['type']),
    endpoint: map['endpoint'],
    payload: jsonDecode(map['payload']),
    timestamp: DateTime.parse(map['timestamp']),
    retries: map['retries'] ?? 0,
    lastAttempt: map['lastAttempt'] != null ? DateTime.parse(map['lastAttempt']) : null,
    isFailed: map['isFailed'] ?? false,
  );
}

/// Headless callback actively mapping background worker daemons explicitly bypassing standard UI constraints
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'processOfflineQueue') {
       final manager = OfflineSyncManager();
       await manager.initHiveOnly(); // Light init avoiding UI-blocked thread stalls
       await manager.processPendingQueue();
    }
    return Future.value(true);
  });
}

/// Comprehensive Offline-First system structurally mapping all data down natively to Hive caches 
/// BEFORE dispatching aggressively asynchronously once TCP connections are verified.
class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  late Box _queueBox;

  Future<void> initHiveOnly() async {
     if (!Hive.isBoxOpen('pending_queue')) {
         _queueBox = await Hive.openBox('pending_queue');
     } else {
         _queueBox = Hive.box('pending_queue');
     }
  }

  Future<void> init() async {
    await initHiveOnly();
    
    // Engages standard daemon bindings ensuring syncing happens silently behind the scenes
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    
    // Front-end active net listener instantly jumping the queue avoiding scheduled polling bounds
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
       if (results.isNotEmpty && results.first != ConnectivityResult.none) {
           processPendingQueue();
       }
    });

    // Clean any stagnant states trapped from abrupt OS task kills securely upon mount
    processPendingQueue();
  }

  /// Appends explicit Sync operations directly into native disk arrays safely
  void queueAction(SyncAction action) {
    _queueBox.put(action.id, action.toMap());
    
    // Explicitly command OS schedulers bounding the background constraint ensuring delivery eventually
    Workmanager().registerOneOffTask(
        "sync_${action.id}",
        "processOfflineQueue",
        constraints: Constraints(networkType: NetworkType.connected)
    );
  }

  /// Evaluates length mapping explicit Badge UI outputs directly back to the visual router layers natively
  int getPendingCount() {
    return _queueBox.values.where((e) {
       final map = Map<String,dynamic>.from(e);
       return map['isFailed'] != true;
    }).length;
  }

  /// Dispatches the core queue actively tracking structured bounds mapping retry delays explicitly.
  Future<void> processPendingQueue() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.first == ConnectivityResult.none) return;

    final queuedItems = _queueBox.values.toList();
    
    for (var raw in queuedItems) {
      final map = Map<String, dynamic>.from(raw);
      final action = SyncAction.fromMap(map);
      
      if (action.isFailed) continue; // Abandoned packet securely quarantined structurally

      if (!_shouldRetry(action)) continue; 

      try {
        await _executeRequest(action);
        // On strict success naturally purges the OS disk cache securing memory
        _queueBox.delete(action.id); 
        
      } catch (e) {
        action.retries++;
        action.lastAttempt = DateTime.now();
        
        if (action.retries >= 3) {
            action.isFailed = true;
            // Native UI state trigger notifying 'Sync Failed — Check Red Flags'
        }
        
        _queueBox.put(action.id, action.toMap()); // Mutate locally gracefully recording backoff state
      }
    }
  }

  /// Smart dynamic pacing strictly respecting TCP backoff bounds avoiding API flood gating (1m -> 5m -> 15m)
  bool _shouldRetry(SyncAction action) {
     if (action.lastAttempt == null) return true;
     final diffMins = DateTime.now().difference(action.lastAttempt!).inMinutes;
     
     if (action.retries == 1 && diffMins >= 1) return true;
     if (action.retries == 2 && diffMins >= 5) return true;
     if (action.retries == 3 && diffMins >= 15) return true;
     
     return false;
  }

  /// Resolves the abstracted Enum constraints natively back into rigid network calls securely
  Future<void> _executeRequest(SyncAction action) async {
     if (action.type == SyncType.UPLOAD_RECORD) {
         await _dio.post(action.endpoint, data: FormData.fromMap(action.payload));
     } else {
         await _dio.post(action.endpoint, data: action.payload);
     }
  }
}
