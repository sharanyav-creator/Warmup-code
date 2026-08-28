import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';
import 'insight_factor.dart';
import 'insight_factor_detail_screen.dart';
import 'session_end_screen.dart';
import 'warmup_copy.dart';
import 'warmup_flow_context.dart';

class InsightsSummaryScreen extends StatefulWidget {
  final WarmupFlowContext flowContext;
  final SessionRecord session;

  const InsightsSummaryScreen({super.key, required this.flowContext, required this.session});

  @override
  State<InsightsSummaryScreen> createState() => _InsightsSummaryScreenState();
}

class _InsightsSummaryScreenState extends State<InsightsSummaryScreen> {
  SessionRecord? _previous;
  bool _loading = true;

  static const _factors = [
    WarmupFactor.fillerWords,
    WarmupFactor.pace,
    WarmupFactor.longPauses,
    WarmupFactor.fumbles,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await context.read<SessionRepository>().getAll();
    final index = all.indexWhere((s) => s.id == widget.session.id);
    if (!mounted) return;
    setState(() {
      _previous = (index != -1 && index + 1 < all.length) ? all[index + 1] : null;
      _loading = false;
    });
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
              const SizedBox(height: 16),
              Text(
                summaryHeadline(widget.session),
                style: OnboardingText.headline(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Compared to your last Warmup',
                  style: OnboardingText.body(color: OnboardingColors.creamSubtext),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: OnboardingColors.creamBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListView.separated(
                          itemCount: _factors.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final factor = _factors[index];
                            return FactorBarCard(
                              factor: factor,
                              session: widget.session,
                              previous: _previous,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => InsightFactorDetailScreen(
                                      factor: factor,
                                      session: widget.session,
                                      previous: _previous,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap each factor to dive deeper and take a closer look.',
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SessionEndScreen(session: widget.session)),
                    );
                  },
                  child: Text('Continue', style: OnboardingText.buttonLabel(color: Colors.white)),
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
