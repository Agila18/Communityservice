import 'package:hive/hive.dart';

part 'local_screening.g.dart';

/// Hive model for offline screening session storage
@HiveType(typeId: 1)
class LocalScreening extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String module; // maternal, menstrual, general, etc.

  @HiveField(4)
  final String? symptomsReported; // JSON string list

  @HiveField(5)
  final String? aiResponse;

  @HiveField(6)
  final String riskLevel; // GREEN, YELLOW, RED

  @HiveField(7)
  final String? recommendation;

  @HiveField(8)
  final bool referralNeeded;

  @HiveField(9)
  final bool isSynced; // whether this has been synced to server

  LocalScreening({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.module,
    this.symptomsReported,
    this.aiResponse,
    this.riskLevel = 'GREEN',
    this.recommendation,
    this.referralNeeded = false,
    this.isSynced = false,
  });
}
