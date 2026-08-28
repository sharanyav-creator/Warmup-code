import 'package:flutter/material.dart';

import 'goal_setting_screen.dart';
import '../../core/design_tokens.dart';
import 'widgets/onboarding_finish.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  void _continue(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GoalSettingScreen()),
    );
  }

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
              Text(
                'Create your account',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'It helps in saving and syncing your progress!',
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
              ),
              const Spacer(flex: 2),
              _WhitePillButton(label: 'Continue with Google', onTap: () => _continue(context)),
              const SizedBox(height: 12),
              _WhitePillButton(label: 'Continue with Apple', onTap: () => _continue(context)),
              const SizedBox(height: 24),
              _WhitePillButton(label: 'Continue with Phone Number', onTap: () => _continue(context)),
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
                  onPressed: () => _continue(context),
                  child: Text('Create Account', style: OnboardingText.buttonLabel(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => finishOnboarding(context),
                child: Text('Skip', style: OnboardingText.buttonLabel(color: Colors.black)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhitePillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WhitePillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(label, style: OnboardingText.body(color: Colors.black)),
      ),
    );
  }
}
