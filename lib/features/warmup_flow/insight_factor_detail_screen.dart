import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';
import '../../data/models/session_record.dart';
import '../progress/transcript_highlighter.dart';
import 'insight_factor.dart';

class InsightFactorDetailScreen extends StatelessWidget {
  final WarmupFactor factor;
  final SessionRecord session;
  final SessionRecord? previous;

  const InsightFactorDetailScreen({
    super.key,
    required this.factor,
    required this.session,
    required this.previous,
  });

  bool get _showsTranscript =>
      factor == WarmupFactor.fillerWords || factor == WarmupFactor.fumbles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset('assets/main/insights_back_chevron.svg', width: 24, height: 24),
                  ),
                  const SizedBox(width: 10),
                  Text('WARMUP INSIGHTS', style: OnboardingText.eyebrow()),
                ],
              ),
              const SizedBox(height: 16),
              Text(factor.title, style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                'Compared to your last Warmups',
                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: OnboardingColors.creamBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: FactorBarCard(factor: factor, session: session, previous: previous),
                    ),
                    if (_showsTranscript) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: session.transcript.isEmpty
                            ? Text(
                                '(no speech detected)',
                                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
                              )
                            : Text.rich(
                                TextSpan(
                                  children: buildTranscriptSpans(
                                    session.transcript,
                                    baseStyle:
                                        OnboardingText.body(color: Colors.black).copyWith(height: 1.6),
                                    highlightFillers: factor == WarmupFactor.fillerWords,
                                    highlightFumbles: factor == WarmupFactor.fumbles,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ],
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Check Overall Insights', style: OnboardingText.buttonLabel(color: Colors.white)),
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
