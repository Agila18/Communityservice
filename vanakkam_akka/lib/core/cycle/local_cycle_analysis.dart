import 'package:intl/intl.dart';

/// Mirrors [backend/ai/cycle_analyzer.py] for offline analysis from cached Hive entries.
/// Enhanced with ovulation prediction and fertile window calculations
Map<String, dynamic> analyzeCyclePatternLocal(
  List<Map<String, dynamic>> entries,
) {
  if (entries.length < 2) {
    return {
      'avg_cycle_length': 0,
      'irregularity_flag': false,
      'pregnancy_probability': false,
      'recommendation_tamil':
          'மேலும் சில மாதவிடாய் தேதிகளை பதிவு செய்யவும். (Log more dates for accurate analysis.)',
      'next_period_date': null,
      'fertile_window_start': null,
      'fertile_window_end': null,
      'ovulation_date': null,
    };
  }

  final sorted = List<Map<String, dynamic>>.from(entries);
  sorted.sort((a, b) {
    final da = DateTime.parse(a['start_date'] as String);
    final db = DateTime.parse(b['start_date'] as String);
    return da.compareTo(db);
  });

  final cycleLengths = <int>[];
  var heavyFlowCount = 0;
  var shortCycles = 0;

  for (var i = 1; i < sorted.length; i++) {
    final prev = DateTime.parse(sorted[i - 1]['start_date'] as String);
    final curr = DateTime.parse(sorted[i]['start_date'] as String);
    cycleLengths.add(curr.difference(prev).inDays);

    final flow = (sorted[i - 1]['flow_level'] as String?)?.toUpperCase();
    if (flow == 'HEAVY') heavyFlowCount++;

    if (curr.difference(prev).inDays < 21) shortCycles++;
  }

  final lastFlow = (sorted.last['flow_level'] as String?)?.toUpperCase();
  if (lastFlow == 'HEAVY') heavyFlowCount++;

  final avgLength = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;

  var irregularityFlag = false;
  var pcosPattern = false;

  if (cycleLengths.length > 1) {
    final maxCL = cycleLengths.reduce((a, b) => a > b ? a : b);
    final minCL = cycleLengths.reduce((a, b) => a < b ? a : b);
    if (maxCL - minCL >= 8) irregularityFlag = true;
  }

  if (avgLength > 35 && heavyFlowCount > 0) {
    irregularityFlag = true;
    pcosPattern = true;
  }

  final lastStart = DateTime.parse(sorted.last['start_date'] as String);
  final daysSinceLast = DateTime.now().difference(lastStart).inDays;
  final pregnancyProbability = daysSinceLast > (avgLength + 10);

  // Calculate next predicted period
  DateTime? nextPeriodDate;
  if (avgLength > 0) {
    nextPeriodDate = lastStart.add(Duration(days: avgLength.round()));
  }

  // Calculate fertile window (typically days 11-17 of 28-day cycle)
  DateTime? fertileWindowStart;
  DateTime? fertileWindowEnd;
  DateTime? ovulationDate;

  if (nextPeriodDate != null && avgLength > 0) {
    // Ovulation typically occurs 14 days before next period
    ovulationDate = nextPeriodDate.subtract(const Duration(days: 14));

    // Fertile window is 5 days before to 1 day after ovulation
    fertileWindowStart = ovulationDate?.subtract(const Duration(days: 5));
    fertileWindowEnd = ovulationDate?.add(const Duration(days: 1));
  }

  var recommendation = 'உங்கள் cycle சீராக உள்ளது.';
  if (pregnancyProbability) {
    recommendation =
        'உங்கள் மாதவிடாய் 10 நாட்களுக்கு மேல் தள்ளிப்போயுள்ளது. கர்ப்ப பரிசோதனை (Pregnancy check) செய்து கொள்ளவும்.';
  } else if (pcosPattern) {
    recommendation =
        'உங்கள் cycle சீராக இல்லை (Long cycles + Heavy flow). நீங்கள் VHN அக்காவிடம் பேசுங்கள்.';
  } else if (irregularityFlag) {
    recommendation = 'உங்கள் cycle சீராக இல்லை — VHN அக்காவிடம் பேசுங்கள்.';
  } else if (shortCycles > 0) {
    recommendation =
        'மாதவிடாய் நாட்கள் மிக குறைவு. ஊட்ச்சத்து குறைபாடாக இருக்கலாம்.';
  } else if (fertileWindowStart != null) {
    final now = DateTime.now();
    if (now.isAfter(fertileWindowStart!) && now.isBefore(fertileWindowEnd!)) {
      recommendation =
          'இப்போது காலம்! குழந்தை பெற்றுவதற்கு சிறந்த நாட்கள் உள்ளன.';
    } else {
      recommendation =
          'அடுத்த இல்லை: இப்போது காலம் ${DateFormat('MMM dd').format(fertileWindowStart!)} - ${DateFormat('MMM dd').format(fertileWindowEnd!)}';
    }
  }

  return {
    'avg_cycle_length': avgLength.round(),
    'irregularity_flag': irregularityFlag || pcosPattern,
    'pregnancy_probability': pregnancyProbability,
    'recommendation_tamil': recommendation,
    'next_period_date': nextPeriodDate != null
        ? DateFormat('yyyy-MM-dd').format(nextPeriodDate!)
        : null,
    'fertile_window_start': fertileWindowStart != null
        ? DateFormat('yyyy-MM-dd').format(fertileWindowStart!)
        : null,
    'fertile_window_end': fertileWindowEnd != null
        ? DateFormat('yyyy-MM-dd').format(fertileWindowEnd!)
        : null,
    'ovulation_date': ovulationDate != null
        ? DateFormat('yyyy-MM-dd').format(ovulationDate!)
        : null,
  };
}
