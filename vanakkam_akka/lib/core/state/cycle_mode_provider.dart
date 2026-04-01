import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Reactive cycle / pregnancy mode aligned with backend [cycle_analyzer] and screening rules.
class CycleModeProvider extends ChangeNotifier {
  static const _boxName = 'cycle_prefs';
  static const _keyPregnancy = 'pregnancy_mode';
  static const _keyWeek = 'pregnancy_week';

  Box? _box;
  bool _ready = false;

  bool pregnancyMode = false;
  int pregnancyWeek = 12;
  bool aiSuggestsPregnancyTest = false;

  bool get isReady => _ready;

  Future<void> init() async {
    if (_ready) return;
    _box = await Hive.openBox(_boxName);
    pregnancyMode = (_box!.get(_keyPregnancy) as bool?) ?? false;
    pregnancyWeek = (_box!.get(_keyWeek) as int?) ?? 12;
    _ready = true;
    notifyListeners();
  }

  Future<void> setPregnancyMode(bool value, {int week = 12}) async {
    pregnancyMode = value;
    pregnancyWeek = week;
    if (_box != null) {
      await _box!.put(_keyPregnancy, value);
      await _box!.put(_keyWeek, week);
    }
    notifyListeners();
  }

  void setAiSuggestsPregnancyTest(bool value) {
    if (aiSuggestsPregnancyTest == value) return;
    aiSuggestsPregnancyTest = value;
    notifyListeners();
  }

  Future<void> confirmPregnancyFromScreening() async {
    await setPregnancyMode(true, week: pregnancyWeek.clamp(1, 40));
  }
}
