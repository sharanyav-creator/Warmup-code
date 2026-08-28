import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../../data/daily_prompts.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/weekly_stats.dart';
import '../goals/frameworks_screen.dart';
import '../warmup_flow/topic_shuffle_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SessionRecord> _sessions = [];
  bool _loading = true;

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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning, Dev!';
    if (hour < 17) return 'Afternoon, Dev!';
    return 'Evening, Dev!';
  }

  void _startImpromptu() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TopicShuffleScreen(trackLabel: 'IMPROMPTU', promptPool: dailyPrompts),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final stats = computeWeeklyStats(_sessions);

    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: OnboardingText.body(color: OnboardingColors.maroonBackground).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _greeting,
                    style: OnboardingText.headline(color: OnboardingColors.burgundy, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _ImpromptuCard(onTap: _startImpromptu),
                  const SizedBox(height: 16),
                  _ThisWeekCard(
                    stats: stats,
                    onCheckProgress: () => widget.onNavigateToTab?.call(1),
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    iconAsset: 'assets/main/home_frameworks_icon.svg',
                    title: 'Read Frameworks',
                    subtitle: 'Know ways you can structure your speech',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FrameworksScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    iconAsset: 'assets/main/home_transcripts_icon.svg',
                    title: 'Check Previous Transcripts',
                    subtitle: 'Check your past Warmups',
                    onTap: () => widget.onNavigateToTab?.call(1),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ImpromptuCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ImpromptuCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: OnboardingColors.maroonBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SvgPicture.asset('assets/onboarding/quote_bubble.svg', width: 48, height: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ask Warm for an Impromptu', style: OnboardingText.headline(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    'Random • Conversational',
                    style: OnboardingText.buttonLabel(color: OnboardingColors.orange).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            SvgPicture.asset('assets/main/impromptu_play_icon.svg', width: 42, height: 42),
          ],
        ),
      ),
    );
  }
}

class _ThisWeekCard extends StatelessWidget {
  final WeeklyStats stats;
  final VoidCallback onCheckProgress;

  const _ThisWeekCard({required this.stats, required this.onCheckProgress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: OnboardingColors.orange, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('This week', style: OnboardingText.buttonLabel(color: Colors.black).copyWith(fontSize: 12)),
              const Spacer(),
              Text(
                '${stats.sessionsCount}/7 sessions',
                style: OnboardingText.headline(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 26,
                    decoration: BoxDecoration(
                      color: stats.dayFilled[i] ? OnboardingColors.weekBlockFilled : OnboardingColors.weekBlockEmpty,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Avg Pace',
                  value: '${stats.avgPace.round()} wpm',
                  valueColor: OnboardingColors.avgPaceGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(label: 'Crutch phrases', value: '${stats.crutchPercent.round()} %'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(label: 'Fumbles', value: '${stats.fumbles} times'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onCheckProgress,
            child: Text(
              'CHECK COMPLETE PROGRESS >',
              textAlign: TextAlign.right,
              style: OnboardingText.buttonLabel(color: OnboardingColors.maroonBackground).copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MiniStat({required this.label, required this.value, this.valueColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: OnboardingColors.burgundy, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: OnboardingText.buttonLabel(color: const Color(0xFFECECEC)).copyWith(fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(value, style: OnboardingText.headline(color: valueColor, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: OnboardingColors.burgundy, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            SvgPicture.asset(iconAsset, width: 32, height: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: OnboardingText.headline(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: OnboardingText.body(color: const Color(0xFFB2B2B2)).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
