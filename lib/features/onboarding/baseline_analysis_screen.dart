import 'package:flutter/material.dart';

import '../../data/models/analysis_result.dart';
import '../../core/design_tokens.dart';
import 'widgets/onboarding_finish.dart';

class BaselineAnalysisScreen extends StatelessWidget {
  final AnalysisResult result;

  const BaselineAnalysisScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text('BASELINE ANALYSIS', style: OnboardingText.eyebrow()),
              const Spacer(flex: 2),
              Text(
                'Day 0 Baseline Saved',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 24),
              ),
              const SizedBox(height: 16),
              Text(
                'This is your starting point, not a score. \n'
                'Future sessions will show how you improve.',
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
              ),
              const Spacer(flex: 2),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: OnboardingColors.burgundySoftBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _statRow('Filler Words', '${result.fillerCount}'),
                    const SizedBox(height: 12),
                    _statRow('Pace', '${result.wordsPerMinute.round()} wpm'),
                    const SizedBox(height: 12),
                    _statRow('Crutch phrases', '${result.clutchWords.length}'),
                    const SizedBox(height: 12),
                    _statRow('Long pauses', '${result.longPauseCount}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Don't overthink it. This warmup is simply \n"
                'about finding your natural rhythm.\n\n'
                'This is just a start.',
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
              ),
              const Spacer(flex: 3),
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
                  onPressed: () => finishOnboarding(context),
                  child: Text('Start your Warmup journey', style: OnboardingText.buttonLabel(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: OnboardingText.statLabel(color: Colors.black)),
        Text(value, style: OnboardingText.statLabel(color: Colors.black)),
      ],
    );
  }
}
