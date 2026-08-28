import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants.dart';
import '../../core/design_tokens.dart';
import 'prep_countdown_screen.dart';
import 'warmup_flow_context.dart';

class PrepStartScreen extends StatefulWidget {
  final WarmupFlowContext flowContext;

  const PrepStartScreen({super.key, required this.flowContext});

  @override
  State<PrepStartScreen> createState() => _PrepStartScreenState();
}

class _PrepStartScreenState extends State<PrepStartScreen> {
  late WarmupFlowContext _flowContext;

  @override
  void initState() {
    super.initState();
    _flowContext = widget.flowContext;
  }

  void _shuffle() {
    final pool = _flowContext.promptPool;
    if (pool.length <= 1) return;
    String next;
    do {
      next = pool[Random().nextInt(pool.length)];
    } while (next == _flowContext.promptText);
    setState(() => _flowContext = _flowContext.withPrompt(next));
  }

  void _startPrep() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PrepCountdownScreen(flowContext: _flowContext)),
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
              const SizedBox(height: 16),
              Text(_flowContext.headerLabel, style: OnboardingText.eyebrow()),
              const SizedBox(height: 40),
              Text(
                '"${_flowContext.promptText}"',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 20),
              ),
              const Spacer(flex: 3),
              Text(
                '00:${targetSessionLength.inSeconds.toString().padLeft(2, '0')}',
                style: OnboardingText.headline(color: OnboardingColors.burgundy, fontSize: 36),
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
                  onPressed: _startPrep,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/main/start_prep_icon.svg', width: 20, height: 20),
                      const SizedBox(width: 12),
                      Text('START PREP', style: OnboardingText.buttonLabel(color: Colors.white)),
                    ],
                  ),
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
                  onPressed: _shuffle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/onboarding/shuffle_icon.svg', width: 20, height: 20),
                      const SizedBox(width: 10),
                      Text('Shuffle Topic', style: OnboardingText.buttonLabel(color: OnboardingColors.creamSubtext)),
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
