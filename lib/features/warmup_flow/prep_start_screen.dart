import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants.dart';
import '../../core/design_tokens.dart';
import '../../data/prep_preferences.dart';
import 'prep_countdown_screen.dart';
import 'speech_recording_screen.dart';
import 'warmup_flow_context.dart';

class PrepStartScreen extends StatefulWidget {
  final WarmupFlowContext flowContext;

  const PrepStartScreen({super.key, required this.flowContext});

  @override
  State<PrepStartScreen> createState() => _PrepStartScreenState();
}

class _PrepStartScreenState extends State<PrepStartScreen> {
  final _prepPreferences = PrepPreferences();
  late WarmupFlowContext _flowContext;
  bool _skipPrep = false;

  // Guards against the initial async load resolving *after* the user has
  // already toggled the switch, which would otherwise silently overwrite
  // their choice with the stale on-disk value right before they tap Continue.
  bool _userHasSetToggle = false;

  @override
  void initState() {
    super.initState();
    _flowContext = widget.flowContext;
    _loadSkipPrep();
  }

  Future<void> _loadSkipPrep() async {
    final skip = await _prepPreferences.getSkipPrep();
    if (!mounted || _userHasSetToggle) return;
    setState(() => _skipPrep = skip);
  }

  void _onSkipPrepChanged(bool value) {
    setState(() {
      _skipPrep = value;
      _userHasSetToggle = true;
    });
    _prepPreferences.setSkipPrep(value);
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

  void _continue() {
    if (_skipPrep) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SpeechRecordingScreen(flowContext: _flowContext)),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PrepCountdownScreen(flowContext: _flowContext)),
      );
    }
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset('assets/main/insights_back_chevron.svg', width: 24, height: 24),
                    ),
                    const SizedBox(width: 10),
                    Text(_flowContext.headerLabel, textAlign: TextAlign.center, style: OnboardingText.eyebrow()),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  '"${_flowContext.promptText}"',
                  textAlign: TextAlign.center,
                  style: OnboardingText.headline(color: Colors.black, fontSize: 20),
                ),
                const Spacer(flex: 3),
                Text(
                  '00:${targetSessionLength.inSeconds.toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                  style: OnboardingText.headline(color: OnboardingColors.burgundy, fontSize: 36),
                ),
                const Spacer(flex: 3),
                Text(
                  'You can skip PREP if you feel confident!',
                  textAlign: TextAlign.center,
                  style: OnboardingText.body(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'SKIP PREP',
                      style: OnboardingText.buttonLabel(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
                    ),
                    Switch(
                      value: _skipPrep,
                      onChanged: _onSkipPrepChanged,
                      activeThumbColor: Colors.white,
                      activeTrackColor: OnboardingColors.burgundy,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFD9D9D9),
                      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
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
                    onPressed: _continue,
                    child: Text('Continue', style: OnboardingText.buttonLabel(color: Colors.white)),
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
      ),
    );
  }
}
