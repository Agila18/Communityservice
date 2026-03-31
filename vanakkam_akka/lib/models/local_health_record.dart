import 'package:hive/hive.dart';

part 'local_health_record.g.dart';

/// Hive model for offline health record storage (prescriptions, labs, scans)
@HiveType(typeId: 2)
class LocalHealthRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String recordType; // prescription, lab, scan

  @HiveField(3)
  final String? imagePath; // local file path to stored image

  @HiveField(4)
  final String? imageUrl; // server URL (after sync)

  @HiveField(5)
  final String? ocrText; // extracted text from image

  @HiveField(6)
  final String? aiExplanation; // AI summary in Tamil

  @HiveField(7)
  final String? title;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final bool isSynced;

  LocalHealthRecord({
    required this.id,
    required this.userId,
    required this.recordType,
    this.imagePath,
    this.imageUrl,
    this.ocrText,
    this.aiExplanation,
    this.title,
    this.notes,
    required this.createdAt,
    this.isSynced = false,
  });
}
