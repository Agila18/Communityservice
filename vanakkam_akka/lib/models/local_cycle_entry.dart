import 'package:hive/hive.dart';

part 'local_cycle_entry.g.dart';

/// Hive model for offline cycle tracking entries
@HiveType(typeId: 3)
class LocalCycleEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime? endDate;

  @HiveField(4)
  final String? flowLevel; // spotting, light, medium, heavy

  @HiveField(5)
  final String? symptoms; // JSON string list

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final bool isSynced;

  LocalCycleEntry({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.flowLevel,
    this.symptoms,
    this.notes,
    required this.createdAt,
    this.isSynced = false,
  });
}
