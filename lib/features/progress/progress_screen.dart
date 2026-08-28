import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<SessionRecord> _sessions = [];
  bool _loading = true;
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

  Set<DateTime> get _practiceDays => _sessions
      .map((s) => DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day))
      .toSet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _sessions.isEmpty
                ? const Center(child: Text('Practice sessions will show up here.'))
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildDeltaCard(context),
                      const SizedBox(height: 24),
                      Text('Score trend', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SizedBox(height: 200, child: _buildTrendChart()),
                      const SizedBox(height: 24),
                      Text('Practice calendar', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Card(child: _buildCalendar()),
                      const SizedBox(height: 24),
                      Text('Session history', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ..._sessions.map(_buildSessionTile),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDeltaCard(BuildContext context) {
    if (_sessions.length < 2) return const SizedBox.shrink();
    final recent = _sessions.take(5).toList();
    final older = _sessions.skip(5).take(5).toList();
    if (older.isEmpty) return const SizedBox.shrink();

    final recentAvgFillers = recent.map((s) => s.fillerCount).reduce((a, b) => a + b) / recent.length;
    final olderAvgFillers = older.map((s) => s.fillerCount).reduce((a, b) => a + b) / older.length;

    if (olderAvgFillers == 0) return const SizedBox.shrink();
    final change = ((olderAvgFillers - recentAvgFillers) / olderAvgFillers * 100).round();

    if (change <= 0) return const SizedBox.shrink();

    return Card(
      color: AppTheme.success.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.trending_up, color: AppTheme.success),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$change% fewer filler words compared to earlier sessions',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final ordered = _sessions.reversed.toList();
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
            color: AppTheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppTheme.primary.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now(),
      focusedDay: _focusedDay,
      onPageChanged: (day) => setState(() => _focusedDay = day),
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(formatButtonVisible: false),
      selectedDayPredicate: (_) => false,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          final key = DateTime(day.year, day.month, day.day);
          if (_practiceDays.contains(key)) {
            return Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${day.day}', style: const TextStyle(color: Colors.white)),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSessionTile(SessionRecord s) {
    return Card(
      child: ListTile(
        title: Text(DateFormat.yMMMd().add_jm().format(s.createdAt)),
        subtitle: Text(s.promptText, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text('${s.score}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
