import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import 'baseline_recording_screen.dart';
import '../../core/design_tokens.dart';

class BaselineSetupScreen extends StatefulWidget {
  const BaselineSetupScreen({super.key});

  @override
  State<BaselineSetupScreen> createState() => _BaselineSetupScreenState();
}

class _BaselineSetupScreenState extends State<BaselineSetupScreen> {
  bool _micGranted = false;

  @override
  void initState() {
    super.initState();
    _checkMic();
  }

  Future<void> _checkMic() async {
    final granted = await Permission.microphone.isGranted;
    if (mounted) setState(() => _micGranted = granted);
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() => _micGranted = false);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BaselineRecordingScreen()),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(child: Text('DAY 0 · BASELINE', style: OnboardingText.eyebrow())),
              const SizedBox(height: 40),
              Text(
                "Just talk for a minute so we can understand where you're starting from. Start with a Base.",
                style: OnboardingText.headline(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(height: 24),
              Text(
                'You will have 60 seconds. Just speak naturally.\n\n'
                'Warmup listens for filler words, pacing, pauses, and fumbles, '
                'then shows you exactly how you spoke.',
                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _startRecording,
                      child: Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(19),
                        decoration: BoxDecoration(
                          color: OnboardingColors.burgundy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SvgPicture.asset('assets/onboarding/play_icon_large.svg'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Start recording', style: OnboardingText.body(color: OnboardingColors.creamSubtext)),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: openAppSettings,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/onboarding/mic_small_icon.svg', width: 24, height: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Microphone', style: OnboardingText.headline(color: Colors.black, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              _micGranted ? 'Permission Allowed' : 'Permission needed',
                              style: OnboardingText.body(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      SvgPicture.asset('assets/onboarding/chevron_icon.svg', width: 24, height: 24),
                    ],
                  ),
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
