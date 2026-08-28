import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'baseline_setup_screen.dart';
import '../../core/design_tokens.dart';
import 'widgets/onboarding_finish.dart';

class BaselineIntroScreen extends StatelessWidget {
  const BaselineIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              SvgPicture.asset('assets/onboarding/logo.svg', width: 151.13, height: 37.2),
              const Spacer(flex: 3),
              Text(
                "Let's hear your \nstarting point",
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 24),
              ),
              const SizedBox(height: 16),
              Text(
                'Set your Day 0. See how you improve.',
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
              ),
              const Spacer(flex: 6),
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
                      MaterialPageRoute(builder: (_) => const BaselineSetupScreen()),
                    );
                  },
                  child: Text('Record Baseline', style: OnboardingText.buttonLabel(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: OnboardingColors.creamSubtext,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () => finishOnboarding(context),
                  child: Text('Skip for now', style: OnboardingText.buttonLabel(color: OnboardingColors.creamSubtext)),
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
