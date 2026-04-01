import 'package:hive_flutter/hive_flutter.dart';
import '../../core/sync/offline_sync_manager.dart';
import 'package:uuid/uuid.dart';

/// Database Manager ensuring 100% of User interactivity lands fundamentally in Local bounds
/// eliminating UI spinner blocking inherently before dispatching securely to queue modules.
class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  late Box _screeningBox;
  late Box _cycleBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Caches mapping independent historical arrays assuring continuous tracking without web
    _screeningBox = await Hive.openBox('cached_screenings');
    _cycleBox = await Hive.openBox('cached_cycles');
    
    // Explicitly hook active listeners automatically jumping the daemon bounds upon init
    await OfflineSyncManager().init();
  }

  /// Secures the Medical Voice abstractions natively to disk directly before pinging Server logic loops
  Future<void> saveScreeningLocally(Map<String, dynamic> sessionMetrics) async {
    final id = const Uuid().v4();
    sessionMetrics['id'] = id;
    sessionMetrics['synced'] = false;
    
    await _screeningBox.put(id, sessionMetrics);
    
    // Dispatch mapping explicitly coercing generic bounds securely utilizing the precise SyncEnum parameters
    final action = SyncAction(
       id: "sync_$id",
       type: SyncType.CREATE_SCREENING,
       endpoint: '/screening/save-session',
       payload: sessionMetrics,
       timestamp: DateTime.now()
    );
    OfflineSyncManager().queueAction(action);
  }

  /// Caches strict maternal period entries natively to visually draw UI states completely offline reliably
  Future<void> saveCycleEntryLocally(Map<String, dynamic> cycleMetrics) async {
    final id = const Uuid().v4();
    cycleMetrics['id'] = id;
    cycleMetrics['synced'] = false;
    
    await _cycleBox.put(id, cycleMetrics);
    
    final action = SyncAction(
       id: "sync_$id",
       type: SyncType.UPDATE_CYCLE,
       endpoint: '/cycle/period',
       payload: cycleMetrics,
       timestamp: DateTime.now()
    );
    OfflineSyncManager().queueAction(action);
  }

  // --- Utility Diagnostics Mapping Interfaces ---

  /// Evaluator exposing direct explicit arrays mapping natively out to Dashboard UI Badge rendering
  List<Map<String, dynamic>> getPendingActions() {
    if (!Hive.isBoxOpen('pending_queue')) return [];
    final box = Hive.box('pending_queue');
    return box.values.map((e) => Map<String,dynamic>.from(e)).toList();
  }

  /// Structural hook tracking active Native clearance bounding DB memory optimally
  void markActionSynced(String actionId) {
    if (!Hive.isBoxOpen('pending_queue')) return;
    final box = Hive.box('pending_queue');
    if (box.containsKey(actionId)) {
       box.delete(actionId);
    }
  }

  /// Purges arrays structurally mapping explicitly for manual Diagnostic Resets overriding all queues natively
  void clearSyncedActions() {
    if (!Hive.isBoxOpen('pending_queue')) return;
    final box = Hive.box('pending_queue');
    
    // Iterate structurally preventing concurrency modification exceptions natively
    final keysToDrop = [];
    for (var key in box.keys) {
       final map = Map<String, dynamic>.from(box.get(key));
       if (map['isFailed'] == true) { // Purge failures intentionally
           keysToDrop.add(key);
       }
    }
    
    box.deleteAll(keysToDrop);
  }
}
