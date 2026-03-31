import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
    try {
      // Typically dynamically loaded via UserProvider or AuthService scope
      final res = await _dio.get('/cycle/analysis/1'); 
      final data = res.data;
      
      setState(() {
        _aiInsightText = data['recommendation_tamil'] ?? "காணவில்லை";
        _isIrregular = data['irregularity_flag'] == true || data['pregnancy_probability'] == true;
        _isLoadingInsight = false;
      });
      
      // Accessibility priority: auto-read serious alerts
      if (_isIrregular) {
         context.read<VoiceService>().speak(_aiInsightText);
      }
    } catch (e) {
      setState(() {
        _isLoadingInsight = false;
        _aiInsightText = "சர்வர் பிழை. இணைய இணைப்பு சரிபார்க்கவும்.";
      });
    }
  }

  /// Posts structured event data into POST /cycle/period
  Future<void> _logPeriod() async {
    if (_selectedDay == null) return;
    
    // Explicitly stripping time components for strict DB parity
    final normalizedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    
    try {
       await _dio.post('/cycle/period', data: {
         "user_id": 1, 
         "start_date": DateFormat('yyyy-MM-dd').format(normalizedDate),
         "flow_level": _flowLevel,
         "symptoms": _symptoms,
      });
      
      setState(() => _historicalPeriods[normalizedDate] = "PERIOD");
      
      context.read<VoiceService>().speak("பதிவு செய்யப்பட்டது"); // "Logged successfully"
      _fetchAnalysis(); // Retrieve recalculated heuristic averages immediately
      
    } catch(e) {
      context.read<VoiceService>().speak("சேமிக்க முடியவில்லை"); // "Failed to save"
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
