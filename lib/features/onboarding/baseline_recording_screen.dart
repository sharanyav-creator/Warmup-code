import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/constants.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';
import '../record/analysis_engine.dart';
import 'baseline_analysis_screen.dart';
import 'baseline_prompts.dart';
import '../../core/design_tokens.dart';

class BaselineRecordingScreen extends StatefulWidget {
  const BaselineRecordingScreen({super.key});

  @override
  State<BaselineRecordingScreen> createState() => _BaselineRecordingScreenState();
}

class _BaselineRecordingScreenState extends State<BaselineRecordingScreen> {
  final SpeechToText _speech = SpeechToText();
  final List<SpeechChunk> _chunks = [];
  final Random _random = Random();

  late String _prompt;
  bool _isRecording = false;
  String _transcript = '';
  DateTime? _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _prompt = baselinePrompts[_random.nextInt(baselinePrompts.length)];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    super.dispose();
  }

  void _shuffleTopic() {
    setState(() {
      String next;
      do {
        next = baselinePrompts[_random.nextInt(baselinePrompts.length)];
      } while (next == _prompt && baselinePrompts.length > 1);
      _prompt = next;
    });
  }

  Future<void> _start() async {
    final available = await _speech.initialize();
    if (!available || !mounted) return;

    _startTime = DateTime.now();
    _chunks.clear();
    setState(() {
      _isRecording = true;
      _transcript = '';
      _elapsedSeconds = 0;
    });

    _speech.listen(
      onResult: (result) {
        setState(() => _transcript = result.recognizedWords);
        _chunks.add(SpeechChunk(text: result.recognizedWords, timestamp: DateTime.now()));
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        listenFor: targetSessionLength,
        pauseFor: targetSessionLength,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_elapsedSeconds >= targetSessionLength.inSeconds - 1) {
        _finish();
      } else {
        setState(() => _elapsedSeconds += 1);
      }
    });
  }

  Future<void> _finish() async {
    _timer?.cancel();
    if (!_isRecording) return;
    final sessionRepository = context.read<SessionRepository>();
    setState(() => _isRecording = false);
    await _speech.stop();

    final duration = _startTime == null ? Duration.zero : DateTime.now().difference(_startTime!);
    final result = analyzeSession(transcript: _transcript, chunks: _chunks, sessionDuration: duration);

    final record = SessionRecord(
      createdAt: DateTime.now(),
      promptText: 'Day 0 Baseline: "$_prompt"',
      transcript: result.transcript,
      wordCount: result.wordCount,
      durationSeconds: result.durationSeconds,
      wordsPerMinute: result.wordsPerMinute,
      fillerCount: result.fillerCount,
      fillerBreakdown: result.fillerBreakdown,
      clutchWordCount: result.clutchWords.length,
      longPauseCount: result.longPauseCount,
      score: result.score,
    );
    await sessionRepository.insert(record);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => BaselineAnalysisScreen(result: result)),
    );
  }

  String get _timerLabel {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
              Text(
                _isRecording ? 'BASELINE RECORDING' : 'BASELINE STARTING',
                style: OnboardingText.eyebrow(),
              ),
              const SizedBox(height: 40),
              Text(
                '"$_prompt"',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 20),
              ),
              const Spacer(flex: 3),
              Text(
                _timerLabel,
                style: OnboardingText.headline(color: Colors.black, fontSize: 36),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 81,
                child: _isRecording
                    ? Center(child: SvgPicture.asset('assets/onboarding/waveform.svg', height: 81))
                    : null,
              ),
              const Spacer(flex: 4),
              if (!_isRecording) ...[
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
                    onPressed: _start,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/onboarding/play_icon_small.svg', width: 20, height: 20),
                        const SizedBox(width: 12),
                        Text('START', style: OnboardingText.buttonLabel(color: Colors.white)),
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
                    onPressed: _shuffleTopic,
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
              ] else
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
                    onPressed: _finish,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('FINISH', style: OnboardingText.buttonLabel(color: Colors.white)),
                        const SizedBox(width: 12),
                        SvgPicture.asset('assets/onboarding/stop_icon.svg', width: 20, height: 20),
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
