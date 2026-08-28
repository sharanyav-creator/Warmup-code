import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/constants.dart';
import '../../core/design_tokens.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';
import '../record/analysis_engine.dart';
import 'transcribing_screen.dart';
import 'warmup_flow_context.dart';

class SpeechRecordingScreen extends StatefulWidget {
  final WarmupFlowContext flowContext;

  const SpeechRecordingScreen({super.key, required this.flowContext});

  @override
  State<SpeechRecordingScreen> createState() => _SpeechRecordingScreenState();
}

class _SpeechRecordingScreenState extends State<SpeechRecordingScreen> {
  final SpeechToText _speech = SpeechToText();
  final List<SpeechChunk> _chunks = [];

  String _transcript = '';
  DateTime? _startTime;
  Timer? _timer;
  int _secondsRemaining = targetSessionLength.inSeconds;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted || !mounted) return;
    final available = await _speech.initialize();
    if (!available || !mounted) return;

    _startTime = DateTime.now();
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
      if (_secondsRemaining <= 1) {
        _finish();
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  Future<void> _finish() async {
    _timer?.cancel();
    if (_finished) return;
    _finished = true;
    final sessionRepository = context.read<SessionRepository>();
    await _speech.stop();

    final duration = _startTime == null ? Duration.zero : DateTime.now().difference(_startTime!);
    final result = analyzeSession(transcript: _transcript, chunks: _chunks, sessionDuration: duration);

    final record = SessionRecord(
      createdAt: DateTime.now(),
      promptText: widget.flowContext.promptText,
      transcript: result.transcript,
      wordCount: result.wordCount,
      durationSeconds: result.durationSeconds,
      wordsPerMinute: result.wordsPerMinute,
      fillerCount: result.fillerCount,
      fillerBreakdown: result.fillerBreakdown,
      clutchWordCount: result.clutchWords.length,
      longPauseCount: result.longPauseCount,
      score: result.score,
      fumbleCount: result.fumbleCount,
      trackLabel: widget.flowContext.trackLabel,
    );
    final id = await sessionRepository.insert(record);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TranscribingScreen(
          flowContext: widget.flowContext,
          session: record.copyWith(id: id),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    super.dispose();
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
              Text(widget.flowContext.headerLabel, style: OnboardingText.eyebrow()),
              const SizedBox(height: 40),
              Text(
                '"${widget.flowContext.promptText}"',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 20),
              ),
              const Spacer(flex: 3),
              Text(
                '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                style: OnboardingText.headline(color: Colors.black, fontSize: 36),
              ),
              const SizedBox(height: 32),
              SvgPicture.asset('assets/main/warmup_waveform.svg', height: 81),
              const Spacer(flex: 4),
              Text(
                "We'll wrap things up when the timer ends.",
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
