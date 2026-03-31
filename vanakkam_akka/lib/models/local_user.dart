import 'package:hive/hive.dart';

part 'local_user.g.dart';

/// Hive model for offline user storage
@HiveType(typeId: 0)
class LocalUser extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String phoneNumber;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int? age;

  @HiveField(4)
  final String languagePref; // 'ta' or 'en'

  @HiveField(5)
  final String literacyMode; // 'voice', 'text', 'hybrid'

  @HiveField(6)
  final String? locationDistrict;

  @HiveField(7)
  final bool isVhn;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final String? accessToken;

  LocalUser({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.age,
    this.languagePref = 'ta',
    this.literacyMode = 'voice',
    this.locationDistrict,
    this.isVhn = false,
    required this.createdAt,
    this.accessToken,
  });
}
