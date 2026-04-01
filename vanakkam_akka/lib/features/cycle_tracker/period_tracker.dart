import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/cycle/local_cycle_analysis.dart';
import '../../core/state/cycle_mode_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/services/local_db_service.dart';
import '../../shared/services/voice_service.dart';
import '../../shared/widgets/voice_button.dart';

/// Full comprehensive calendar UI integrating period tracking, flow assessment, 
/// and dynamically rendering localized hormonal health markers directly below.
class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Input State
  String _flowLevel = "MEDIUM"; // Light | Medium | Heavy
  final List<String> _symptoms = [];
  
  final Map<String, String> _flowLabels = {
    "HEAVY": "அதிகம்",
    "MEDIUM": "சாதாரண",
    "LIGHT": "குறைவு"
  };

  final Map<String, String> _symptomLabels = {
    "pain": "வலி",
    "bloating": "வீக்கம்",
    "fatigue": "சோர்வு"
  };

  // Analysis State
  bool _isLoadingInsight = true;
  String _aiInsightText = "லோடிங்...";
  bool _isIrregular = false;
  
  // Standardized mocked cache mimicking historical inputs to highlight dates visually
  final Map<DateTime, String> _historicalPeriods = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchAnalysis(); // Background API load
  }

  /// Pulls the aggregate mathematical insights based off prior 3-cycle logs
  Future<void> _fetchAnalysis() async {
    late Map<String, dynamic> data;
    try {
      final res = await _dio.get('/cycle/analysis/1');
      data = Map<String, dynamic>.from(res.data as Map);
    } catch (_) {
      data = analyzeCyclePatternLocal(LocalDbService().getCycleEntriesSorted());
    }

    if (!mounted) return;
    final preg = data['pregnancy_probability'] == true;
    final irregular =
        data['irregularity_flag'] == true || preg;
    context.read<CycleModeProvider>().setAiSuggestsPregnancyTest(preg);

    setState(() {
      _aiInsightText = data['recommendation_tamil'] ?? "காணவில்லை";
      _isIrregular = irregular;
      _isLoadingInsight = false;
    });

    if (irregular && mounted) {
      context.read<VoiceService>().speak(_aiInsightText);
    }
  }

  /// Offline-first period log → Hive + sync queue; refreshes AI insight when possible.
  Future<void> _logPeriod() async {
    if (_selectedDay == null) return;

    final normalizedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final payload = {
      "user_id": 1,
      "start_date": DateFormat('yyyy-MM-dd').format(normalizedDate),
      "flow_level": _flowLevel,
      "symptoms": _symptoms,
    };

    try {
      await LocalDbService().saveCycleEntryLocally(payload);
      setState(() => _historicalPeriods[normalizedDate] = "PERIOD");
      if (mounted) context.read<VoiceService>().speak("பதிவு செய்யப்பட்டது");
      await _fetchAnalysis();
    } catch (e) {
      if (mounted) context.read<VoiceService>().speak("சேமிக்க முடியவில்லை");
    }
  }

  void _processVoiceCommand(String rawText) {
     final text = rawText.toLowerCase();
     if (text.contains("ஆரம்பமாச்சு") || text.contains("முடித்து")) {
         _logPeriod();
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("மாதவிடாய் பதிவேடு", style: AppTextStyles.headingMedium), // Period Diary
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
             SliverToBoxAdapter(child: _buildCalendarView()),
             SliverToBoxAdapter(
                child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       const SizedBox(height: 24),
                       _buildPregnancyTransitionBanner(),
                       _buildControlPanel(),
                       const SizedBox(height: 32),
                       _buildAiInsightBox(),
                       const SizedBox(height: 48), // Padding for scroll clearance around mic
                     ],
                   ),
                ),
             )
          ],
        ),
      ),
      // Persistent contextual logging capability via STT engine
      floatingActionButton: VoiceButton(
        onResult: _processVoiceCommand,
        // Override accessibility constraints allowing continuous listening contexts if desired
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPregnancyTransitionBanner() {
    return Consumer<CycleModeProvider>(
      builder: (context, mode, _) {
        if (!mode.aiSuggestsPregnancyTest || mode.pregnancyMode) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                await context.read<CycleModeProvider>().setPregnancyMode(true);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.pregnant_woman_rounded, size: 40, color: AppColors.secondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "கர்ப்ப பரிசோதனை பற்றி AI குறிப்பு உள்ளது. கர்ப்ப கால கையேடுக்குச் செல்ல தட்டவும்.",
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.secondary),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===============================================
  //  CALENDAR COMPONENT
  // ===============================================
  Widget _buildCalendarView() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        calendarStyle: CalendarStyle(
           todayDecoration: const BoxDecoration(
             color: AppColors.primary,
             shape: BoxShape.circle,
           ),
           selectedDecoration: BoxDecoration(
             color: AppColors.primary.withValues(alpha: 0.5),
             shape: BoxShape.circle,
             border: Border.all(color: AppColors.primary, width: 2)
           ),
           markerDecoration: const BoxDecoration(
             color: AppColors.riskRed,
             shape: BoxShape.circle
           )
        ),
        headerStyle: HeaderStyle(
           titleTextStyle: AppTextStyles.headingMedium,
           formatButtonVisible: false,
           titleCentered: true,
        ),
        // Build visually explicit bleeding vs fertile window cues via Custom Builders
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
             final norm = DateTime(day.year, day.month, day.day);
             if (_historicalPeriods[norm] == "PERIOD") {
                return Container(
                  margin: const EdgeInsets.all(6.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.riskRed, shape: BoxShape.circle),
                  child: Text(day.day.toString(), style: AppTextStyles.bodyLarge.copyWith(color: Colors.white)),
                );
             }
             return null;
          }
        ),
      ),
    );
  }

  // ===============================================
  //  LOGGING CONTROLS (FLOW & SYMPTOMS)
  // ===============================================
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text("ரத்தக் கசிவின் அளவு:", style: AppTextStyles.headingMedium), // Flow amount
           const SizedBox(height: 16),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: _flowLabels.entries.map((entry) {
                final isSelected = _flowLevel == entry.key;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
                        foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
                        elevation: 0,
                      ),
                      onPressed: () => setState(() => _flowLevel = entry.key),
                      child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
             }).toList(),
           ),
           
           const SizedBox(height: 24),
           
           Text("அறிகுறிகள்:", style: AppTextStyles.headingMedium), // Symptoms
           const SizedBox(height: 16),
           Wrap(
             spacing: 12,
             runSpacing: 12,
             children: _symptomLabels.entries.map((entry) {
               final isSelected = _symptoms.contains(entry.key);
               return FilterChip(
                 label: Text(entry.value),
                 selected: isSelected,
                 selectedColor: AppColors.primary.withValues(alpha: 0.2),
                 checkmarkColor: AppColors.primary,
                 onSelected: (val) {
                    setState(() { val ? _symptoms.add(entry.key) : _symptoms.remove(entry.key); });
                 },
               );
             }).toList()
           ),

           const SizedBox(height: 32),
           SizedBox(
             width: double.infinity,
             height: 54,
             child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                   backgroundColor: AppColors.riskRed,
                   foregroundColor: Colors.white,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                icon: const Icon(Icons.water_drop_rounded),
                label: Text("பதிவு செய் (Log Period)", style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
                onPressed: _logPeriod,
             ),
           )
        ],
      )
    );
  }

  // ===============================================
  //  AI DRIVEN TISSUE REPORTING & VHN ALERTS
  // ===============================================
  Widget _buildAiInsightBox() {
    final bgColor = _isIrregular ? AppColors.riskYellow.withValues(alpha: 0.1) : AppColors.riskGreen.withValues(alpha: 0.1);
    final borderColor = _isIrregular ? AppColors.riskYellow : AppColors.riskGreen;
    final iconColor = _isIrregular ? AppColors.riskYellow : AppColors.riskGreen;
    
    return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2)
       ),
       child: _isLoadingInsight 
         ? const Center(child: CircularProgressIndicator())
         : Column(
             children: [
               Icon(_isIrregular ? Icons.warning_amber_rounded : Icons.auto_graph_rounded, color: iconColor, size: 48),
               const SizedBox(height: 12),
               Text(
                 _aiInsightText,
                 textAlign: TextAlign.center,
                 style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary)
               ),
             ]
         )
    );
  }
}
