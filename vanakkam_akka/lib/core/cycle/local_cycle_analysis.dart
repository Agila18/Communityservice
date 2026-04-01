/// Mirrors [backend/ai/cycle_analyzer.py] for offline analysis from cached Hive entries.
Map<String, dynamic> analyzeCyclePatternLocal(List<Map<String, dynamic>> entries) {
  if (entries.length < 2) {
    return {
      'avg_cycle_length': 0,
      'irregularity_flag': false,
      'pregnancy_probability': false,
      'recommendation_tamil':
          'மேலும் சில மாதவிடாய் தேதிகளை பதிவு செய்யவும். (Log more dates for accurate analysis.)',
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
        'மாதவிடாய் நாட்கள் மிக குறைவு. ஊட்டச்சத்து குறைபாடாக இருக்கலாம்.';
  }

  return {
    'avg_cycle_length': avgLength.round(),
    'irregularity_flag': irregularityFlag || pcosPattern,
    'pregnancy_probability': pregnancyProbability,
    'recommendation_tamil': recommendation,
  };
}
