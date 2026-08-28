import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';
import '../../data/models/session_record.dart';
import 'transcript_screen.dart';
import 'warmup_flow_context.dart';

class TranscribingScreen extends StatefulWidget {
  final WarmupFlowContext flowContext;
  final SessionRecord session;

  const TranscribingScreen({super.key, required this.flowContext, required this.session});

  @override
  State<TranscribingScreen> createState() => _TranscribingScreenState();
}

class _TranscribingScreenState extends State<TranscribingScreen> {
  @override
  void initState() {
    super.initState();
    _proceed();
  }

  Future<void> _proceed() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TranscriptScreen(flowContext: widget.flowContext, session: widget.session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('WARMUP TRANSCRIBING', style: OnboardingText.eyebrow()),
            const Spacer(flex: 3),
            SvgPicture.asset('assets/main/warmup_waveform.svg', height: 81),
            const Spacer(flex: 3),
            Text(
              'Listening back closely...',
              style: OnboardingText.headline(color: Colors.black, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Almost there. \nYour transcript is coming together.',
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
              ),
            ),
            const Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}
