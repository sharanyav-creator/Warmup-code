import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/design_tokens.dart';
import 'speech_recording_screen.dart';
import 'warmup_flow_context.dart';

class PrepCountdownScreen extends StatefulWidget {
  final WarmupFlowContext flowContext;

  const PrepCountdownScreen({super.key, required this.flowContext});

  @override
  State<PrepCountdownScreen> createState() => _PrepCountdownScreenState();
}

class _PrepCountdownScreenState extends State<PrepCountdownScreen> {
  Timer? _timer;
  int _secondsRemaining = prepSessionLength.inSeconds;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _ready = true;
        });
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSpeech() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SpeechRecordingScreen(flowContext: widget.flowContext)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_secondsRemaining / prepSessionLength.inSeconds);

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
                _ready ? widget.flowContext.headerLabel : '${widget.flowContext.headerLabel} PREP',
                textAlign: TextAlign.center,
                style: OnboardingText.eyebrow(),
              ),
              const SizedBox(height: 40),
              Text(
                '"${widget.flowContext.promptText}"',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 20),
              ),
              const Spacer(flex: 3),
              Text(
                '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 36),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 99,
                height: 99,
                child: CircularProgressIndicator(
                  value: _ready ? 1 : progress,
                  strokeWidth: 10,
                  backgroundColor: OnboardingColors.maroonBackground,
                  valueColor: const AlwaysStoppedAnimation(OnboardingColors.orange),
                ),
              ),
              const Spacer(flex: 4),
              if (_ready)
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
                    onPressed: _startSpeech,
                    child: Text('START SPEECH', style: OnboardingText.buttonLabel(color: Colors.white)),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                _ready
                    ? "We'll wrap things up when the timer ends."
                    : "We'll pause Prep once when the timer ends.",
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
