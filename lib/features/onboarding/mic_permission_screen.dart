import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import 'baseline_intro_screen.dart';
import '../../core/design_tokens.dart';
import 'widgets/onboarding_finish.dart';

class MicPermissionScreen extends StatelessWidget {
  const MicPermissionScreen({super.key});

  Future<void> _allow(BuildContext context) async {
    await Permission.microphone.request();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BaselineIntroScreen()),
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
              SvgPicture.asset('assets/onboarding/logo.svg', width: 151.13, height: 37.2),
              const Spacer(flex: 4),
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: OnboardingColors.burgundy,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: SvgPicture.asset('assets/onboarding/mic_permission_icon.svg'),
              ),
              const SizedBox(height: 24),
              Text(
                'Warmup needs your mic',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 24),
              ),
              const SizedBox(height: 16),
              Text(
                'to hear you practice and turn your speech into feedback. '
                'Processed securely — your voice is never stored or shared.',
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
              ),
              const Spacer(flex: 5),
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
                  onPressed: () => _allow(context),
                  child: Text('Allow microphone access', style: OnboardingText.buttonLabel(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => finishOnboarding(context),
                child: Text('Not now', style: OnboardingText.buttonLabel(color: OnboardingColors.creamSubtext)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
