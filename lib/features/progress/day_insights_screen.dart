import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';
import 'transcript_highlighter.dart';

class DayInsightsScreen extends StatefulWidget {
  final DateTime initialDay;

  const DayInsightsScreen({super.key, required this.initialDay});

  @override
  State<DayInsightsScreen> createState() => _DayInsightsScreenState();
}

class _DayInsightsScreenState extends State<DayInsightsScreen> {
  List<SessionRecord> _allSessions = [];
  bool _loading = true;
  late DateTime _day;

  @override
  void initState() {
    super.initState();
    _day = DateTime(widget.initialDay.year, widget.initialDay.month, widget.initialDay.day);
    _load();
  }

  Future<void> _load() async {
    final sessions = await context.read<SessionRepository>().getAll();
    if (!mounted) return;
    setState(() {
      _allSessions = sessions;
      _loading = false;
    });
  }

  void _shiftDay(int delta) {
    final next = _day.add(Duration(days: delta));
    final today = DateTime.now();
    if (next.isAfter(DateTime(today.year, today.month, today.day))) return;
    setState(() => _day = next);
  }

  @override
  Widget build(BuildContext context) {
    SessionRecord? daySession;
    SessionRecord? previous;

    if (!_loading) {
      final sameDay = _allSessions.where((s) {
        final d = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
        return d == _day;
      }).toList();
      if (sameDay.isNotEmpty) {
        daySession = sameDay.first;
        final index = _allSessions.indexOf(daySession);
        if (index + 1 < _allSessions.length) previous = _allSessions[index + 1];
      }
    }

    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Text('Day Insights', style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _DateNav(day: _day, onPrev: () => _shiftDay(-1), onNext: () => _shiftDay(1)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : daySession == null
                      ? Center(
                          child: Text(
                            'No practice session on this day.',
                            style: OnboardingText.body(color: OnboardingColors.creamSubtext),
                          ),
                        )
                      : _DayDetail(session: daySession, previous: previous),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateNav extends StatelessWidget {
  final DateTime day;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateNav({required this.day, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: OnboardingColors.orange, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(onTap: onPrev, child: const Icon(Icons.chevron_left, color: Colors.white)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Text(
              DateFormat('d MMMM yyyy').format(day),
              style: OnboardingText.buttonLabel(color: Colors.black).copyWith(fontSize: 12),
            ),
          ),
          InkWell(onTap: onNext, child: const Icon(Icons.chevron_right, color: Colors.white)),
        ],
      ),
    );
  }
}

class _DayDetail extends StatelessWidget {
  final SessionRecord session;
  final SessionRecord? previous;

  const _DayDetail({required this.session, required this.previous});

  ({String label, bool isGood})? _change(int current, int? prev) {
    if (prev == null || prev == 0) return null;
    final diff = prev - current;
    final pct = (diff.abs() / prev * 100).round();
    if (pct == 0) return null;
    final decreased = diff > 0;
    return (label: decreased ? '$pct% improvement' : '$pct% increase', isGood: decreased);
  }

  ({String label, bool isGood}) _paceLabel(double wpm) {
    if (wpm >= 110 && wpm <= 160) return (label: 'Ideal pace', isGood: true);
    return (label: wpm < 110 ? 'Too slow' : 'Too fast', isGood: false);
  }

  @override
  Widget build(BuildContext context) {
    final promptText = session.transcript.isEmpty ? session.promptText : session.promptText;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        if (session.trackLabel != null) ...[
          Text(
            session.trackLabel!,
            style: OnboardingText.buttonLabel(color: OnboardingColors.burgundy).copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          '"$promptText"',
          style: OnboardingText.headline(color: Colors.black, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _statCard('Filler Words', '${session.fillerCount}', _change(session.fillerCount, previous?.fillerCount)),
            _statCard(
              'Crutch phrases',
              '${session.clutchWordCount}',
              _change(session.clutchWordCount, previous?.clutchWordCount),
            ),
            _statCard('Fumbles', '${session.fumbleCount}', _change(session.fumbleCount, previous?.fumbleCount)),
            _statCard('Grammar error', '0', null),
            _statCard(
              'Pauses',
              '${session.longPauseCount}',
              _change(session.longPauseCount, previous?.longPauseCount),
            ),
            _statCard('${session.wordsPerMinute.round()} wpm', '', null, tag: _paceLabel(session.wordsPerMinute)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRANSCRIPT',
                style: OnboardingText.buttonLabel(color: OnboardingColors.navInactive).copyWith(fontSize: 12),
              ),
              const SizedBox(height: 12),
              session.transcript.isEmpty
                  ? Text('(no speech detected)', style: OnboardingText.body(color: OnboardingColors.creamSubtext))
                  : Text.rich(
                      TextSpan(
                        children: buildTranscriptSpans(
                          session.transcript,
                          baseStyle: OnboardingText.body(color: Colors.black).copyWith(height: 1.6),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE5E0D8)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _legendItem('Filler words', const Color(0x33FF5A36)),
                  _legendItem('Repeats (fumbles)', const Color(0xFFB22452), isLine: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _statCard(String label, String value, ({String label, bool isGood})? change, {({String label, bool isGood})? tag}) {
    final badge = change ?? tag;
    return Container(
      width: 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: OnboardingText.buttonLabel(color: OnboardingColors.maroonBackground).copyWith(fontSize: 10),
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(value, style: OnboardingText.headline(color: Colors.black, fontSize: 15)),
          ],
          if (badge != null) ...[
            const SizedBox(height: 4),
            Text(
              badge.label,
              style: OnboardingText.buttonLabel(
                color: badge.isGood ? const Color(0xFF1B8A5A) : const Color(0xFFD90000),
              ).copyWith(fontSize: 8),
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, {bool isLine = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: isLine ? 2 : 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: OnboardingText.body(color: Colors.black).copyWith(fontSize: 12)),
      ],
    );
  }
}
