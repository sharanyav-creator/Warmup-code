import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../mascot/warm_mascot.dart';
import 'prep_start_screen.dart';
import 'warmup_flow_context.dart';

class TopicShuffleScreen extends StatefulWidget {
  final String trackLabel;
  final List<String> promptPool;

  const TopicShuffleScreen({super.key, required this.trackLabel, required this.promptPool});

  @override
  State<TopicShuffleScreen> createState() => _TopicShuffleScreenState();
}

class _TopicShuffleScreenState extends State<TopicShuffleScreen> {
  @override
  void initState() {
    super.initState();
    _proceed();
  }

  Future<void> _proceed() async {
    await Future.delayed(WarmMascot.shuffleSequenceDuration);
    if (!mounted) return;
    final prompt = widget.promptPool[Random().nextInt(widget.promptPool.length)];
    final flowContext = WarmupFlowContext(
      trackLabel: widget.trackLabel,
      promptPool: widget.promptPool,
      promptText: prompt,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PrepStartScreen(flowContext: flowContext)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                '${widget.trackLabel} WARMUP',
                textAlign: TextAlign.center,
                style: OnboardingText.eyebrow(),
              ),
              const Spacer(flex: 3),
              Text(
                'Warm is shuffling topics',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 20),
              ),
              const Spacer(flex: 2),
              const WarmMascot(mode: MascotMode.shuffling, width: 132),
              const Spacer(flex: 3),
              Text(
                'This will take a few seconds...',
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
              ),
              const Spacer(flex: 6),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
