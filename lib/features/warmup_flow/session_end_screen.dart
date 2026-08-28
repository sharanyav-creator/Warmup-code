import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/weekly_stats.dart';
import '../shell/root_shell.dart';
import 'warmup_copy.dart';

class SessionEndScreen extends StatefulWidget {
  final SessionRecord session;

  const SessionEndScreen({super.key, required this.session});

  @override
  State<SessionEndScreen> createState() => _SessionEndScreenState();
}

class _SessionEndScreenState extends State<SessionEndScreen> {
  int _sessionsThisWeek = 0;
  int? _fillerImprovementPercent;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await context.read<SessionRepository>().getAll();
    if (!mounted) return;

    final stats = computeWeeklyStats(all);

    int? improvement;
    if (all.length > 1) {
      final firstEver = all.last;
      if (firstEver.fillerCount > 0) {
        final diff = firstEver.fillerCount - widget.session.fillerCount;
        if (diff > 0) improvement = (diff / firstEver.fillerCount * 100).round();
      }
    }

    setState(() {
      _sessionsThisWeek = stats.sessionsCount;
      _fillerImprovementPercent = improvement;
      _loading = false;
    });
  }

  void _finish(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  void _practiceWithTrack(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 2)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text("TODAY'S WARMUP SUMMARY", style: OnboardingText.eyebrow()),
              const Spacer(flex: 2),
              Column(
                children: [
                  SvgPicture.asset('assets/onboarding/logo.svg', width: 151.13, height: 37.2),
                  const SizedBox(height: 4),
                  Text(
                    'Your voice, refined.',
                    style: OnboardingText.buttonLabel(color: Colors.black).copyWith(fontSize: 10),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: OnboardingColors.burgundy, borderRadius: BorderRadius.circular(20)),
                child: SvgPicture.asset('assets/main/checkmark_icon.svg', width: 32, height: 32),
              ),
              const SizedBox(height: 24),
              Text(
                summaryHeadline(widget.session),
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 24),
              ),
              const SizedBox(height: 12),
              _loading
                  ? const SizedBox(height: 16)
                  : Text(
                      _fillerImprovementPercent != null
                          ? '$_sessionsThisWeek sessions this week · filler words down $_fillerImprovementPercent% since you started'
                          : '$_sessionsThisWeek session${_sessionsThisWeek == 1 ? '' : 's'} this week',
                      textAlign: TextAlign.center,
                      style: OnboardingText.body(color: OnboardingColors.creamSubtext),
                    ),
              const Spacer(flex: 4),
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
                  onPressed: () => _finish(context),
                  child: Text('See you tomorrow', style: OnboardingText.buttonLabel(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _practiceWithTrack(context),
                child: Text(
                  'Practice with a Track',
                  style: OnboardingText.buttonLabel(color: OnboardingColors.creamSubtext),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
