import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../data/models/session_record.dart';
import '../progress/transcript_highlighter.dart';
import 'insights_summary_screen.dart';
import 'warmup_flow_context.dart';

class TranscriptScreen extends StatelessWidget {
  final WarmupFlowContext flowContext;
  final SessionRecord session;

  const TranscriptScreen({super.key, required this.flowContext, required this.session});

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
              Text('YOUR TRANSCRIPT', style: OnboardingText.eyebrow()),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OnboardingColors.creamBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: session.transcript.isEmpty
                        ? Text(
                            '(no speech detected)',
                            style: OnboardingText.body(color: OnboardingColors.creamSubtext),
                          )
                        : Text.rich(
                            TextSpan(
                              children: buildTranscriptSpans(
                                session.transcript,
                                baseStyle: OnboardingText.body(color: Colors.black).copyWith(fontSize: 20, height: 1.6),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _legendItem('Filler words', const Color(0x33FF5A36)),
                  _legendItem('Repeats (fumbles)', const Color(0xFFB22452), isLine: true),
                ],
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
                      MaterialPageRoute(
                        builder: (_) => InsightsSummaryScreen(flowContext: flowContext, session: session),
                      ),
                    );
                  },
                  child: Text('See complete Insight', style: OnboardingText.buttonLabel(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
