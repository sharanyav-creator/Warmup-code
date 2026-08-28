import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/design_tokens.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';

enum _ProgressTab { growth, trends, calendar, history }

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<SessionRecord> _sessions = [];
  bool _loading = true;
  _ProgressTab _tab = _ProgressTab.growth;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await context.read<SessionRepository>().getAll();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 8),
                  Text('Progress', style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _TabSelector(current: _tab, onChanged: (t) => setState(() => _tab = t)),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildTabContent()),
                ],
              ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_sessions.isEmpty) {
      return const Center(child: Text('Practice sessions will show up here.'));
    }
    switch (_tab) {
      case _ProgressTab.growth:
        return _GrowthTab(sessions: _sessions);
      case _ProgressTab.trends:
        return _TrendsTab(sessions: _sessions);
      case _ProgressTab.calendar:
        return _CalendarTab(
          sessions: _sessions,
          focusedDay: _focusedDay,
          onPageChanged: (d) => setState(() => _focusedDay = d),
        );
      case _ProgressTab.history:
        return _HistoryTab(sessions: _sessions);
    }
  }
}

class _TabSelector extends StatelessWidget {
  final _ProgressTab current;
  final ValueChanged<_ProgressTab> onChanged;

  const _TabSelector({required this.current, required this.onChanged});

  static const _labels = {
    _ProgressTab.growth: 'Growth',
    _ProgressTab.trends: 'Trends',
    _ProgressTab.calendar: 'Calendar',
    _ProgressTab.history: 'History',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: OnboardingColors.burgundy, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: _labels.entries.map((entry) {
          final active = entry.key == current;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onChanged(entry.key),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: OnboardingText.buttonLabel(color: active ? Colors.black : Colors.white).copyWith(fontSize: 12),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GrowthTab extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _GrowthTab({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        _buildDeltaCard(context),
        const SizedBox(height: 16),
        Text('Score trend', style: OnboardingText.headline(color: Colors.black, fontSize: 14)),
        const SizedBox(height: 12),
        SizedBox(height: 220, child: _buildTrendChart()),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDeltaCard(BuildContext context) {
    if (sessions.length < 2) return const SizedBox.shrink();
    final recent = sessions.take(5).toList();
    final older = sessions.skip(5).take(5).toList();
    if (older.isEmpty) return const SizedBox.shrink();

    final recentAvgFillers = recent.map((s) => s.fillerCount).reduce((a, b) => a + b) / recent.length;
    final olderAvgFillers = older.map((s) => s.fillerCount).reduce((a, b) => a + b) / older.length;

    if (olderAvgFillers == 0) return const SizedBox.shrink();
    final change = ((olderAvgFillers - recentAvgFillers) / olderAvgFillers * 100).round();
    if (change <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OnboardingColors.burgundySoftBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.trending_up, color: OnboardingColors.burgundy),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$change% fewer filler words compared to earlier sessions',
                style: OnboardingText.buttonLabel(color: Colors.black).copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final ordered = sessions.reversed.toList();
    final spots = <FlSpot>[
      for (var i = 0; i < ordered.length; i++) FlSpot(i.toDouble(), ordered[i].score.toDouble()),
    ];
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: OnboardingColors.burgundy,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: OnboardingColors.burgundySoftBackground),
          ),
        ],
      ),
    );
  }
}

class _TrendsTab extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _TrendsTab({required this.sessions});

  static const _series = [
    (label: 'Filler words', color: Color(0xFFFFB4A2)),
    (label: 'Crutch phrases', color: OnboardingColors.orange),
    (label: 'Pauses', color: OnboardingColors.burgundy),
    (label: 'Repetitions', color: Color(0xFF6C63B5)),
    (label: 'Grammar error', color: Color(0xFF2FA39B)),
  ];

  List<List<int>> _dailyTotals() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final days = [for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i))];

    final fillerByDay = List.filled(7, 0);
    final crutchByDay = List.filled(7, 0);
    final pausesByDay = List.filled(7, 0);

    for (final s in sessions) {
      final day = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
      final index = days.indexWhere((d) => d == day);
      if (index == -1) continue;
      fillerByDay[index] += s.fillerCount;
      crutchByDay[index] += s.clutchWordCount;
      pausesByDay[index] += s.longPauseCount;
    }
    return [fillerByDay, crutchByDay, pausesByDay, List.filled(7, 0), List.filled(7, 0)];
  }

  @override
  Widget build(BuildContext context) {
    final totals = _dailyTotals();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Last 7 days', style: OnboardingText.buttonLabel(color: Colors.black).copyWith(fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: OnboardingColors.creamBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text('Weekly', style: OnboardingText.buttonLabel(color: Colors.black).copyWith(fontSize: 12)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(height: 180, child: _buildChart(totals)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  for (final s in _series)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 16, height: 4, color: s.color),
                        const SizedBox(width: 6),
                        Text(s.label, style: OnboardingText.body(color: Colors.black).copyWith(fontSize: 12)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap each factor to dive deeper and take an individual look.',
          textAlign: TextAlign.center,
          style: OnboardingText.body(color: OnboardingColors.creamSubtext).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OnboardingColors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {},
            child: Text('Check Individual Insights', style: OnboardingText.buttonLabel(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChart(List<List<int>> totals) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          for (var i = 0; i < _series.length; i++)
            LineChartBarData(
              spots: [for (var d = 0; d < 7; d++) FlSpot(d.toDouble(), totals[i][d].toDouble())],
              isCurved: true,
              color: _series[i].color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  final List<SessionRecord> sessions;
  final DateTime focusedDay;
  final ValueChanged<DateTime> onPageChanged;

  const _CalendarTab({required this.sessions, required this.focusedDay, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    final practiceDays = sessions
        .map((s) => DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day))
        .toSet();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now(),
            focusedDay: focusedDay,
            onPageChanged: onPageChanged,
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            selectedDayPredicate: (_) => false,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final key = DateTime(day.year, day.month, day.day);
                if (practiceDays.contains(key)) {
                  return Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(color: OnboardingColors.burgundy, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${day.day}', style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _HistoryTab({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        for (final s in sessions)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.yMMMd().add_jm().format(s.createdAt),
                        style: OnboardingText.headline(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.promptText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OnboardingText.body(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text('${s.score}', style: OnboardingText.headline(color: OnboardingColors.burgundy, fontSize: 16)),
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
