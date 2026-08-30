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

  // The Android/iOS speech recognizer only stays alive for a single bounded
  // "listen session" — it can end well before our 60s target (silence,
  // OS-side timeouts) without ever calling onError. onStatus is used to
  // detect that and immediately start a fresh session so we keep capturing
  // for the whole target duration instead of silently going deaf partway
  // through. Each session's recognizedWords resets to empty, so finalized
  // text is accumulated separately from the current session's live partial.
  String _committedTranscript = '';
  String _currentPartial = '';
  String get _transcript => [
        _committedTranscript,
        _currentPartial,
      ].where((s) => s.isNotEmpty).join(' ');

  DateTime? _startTime;
  Timer? _timer;
  int _secondsRemaining = targetSessionLength.inSeconds;
  bool _finished = false;
  bool _restartPending = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted || !mounted) return;

    final available = await _speech.initialize(
      debugLogging: true,
      // Heavily customized Android builds (MIUI, etc.) can fail to resolve
      // the default speech recognition intent, which silently breaks audio
      // routing into the recognizer. This forces the plugin to look it up
      // explicitly instead of relying on the platform default.
      options: [SpeechToText.androidIntentLookup],
      onError: (error) {
        debugPrint('STT error: ${error.errorMsg} (permanent: ${error.permanent})');
      },
      onStatus: (status) {
        debugPrint('STT status: $status');
        _scheduleRestartIfDone(status);
      },
    );
    if (!available || !mounted) {
      setState(() => _initError = 'Speech recognition unavailable on this device.');
      return;
    }

    _startTime = DateTime.now();
    _listen();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        _finish();
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  // Real device recognizers (esp. OEM ones) commonly end a listen session
  // after just a few words, even with pauseFor/listenFor set generously —
  // and calling listen() again immediately, from inside the status callback,
  // is unreliable on hardware because the platform recognizer hasn't
  // finished tearing down yet (the plugin itself waits ~50ms before
  // releasing the native recognizer). A short delay plus a re-entrancy guard
  // makes the restart land cleanly instead of silently failing. Triggered
  // from both the final result and the "done" status — whichever arrives
  // first — to close the gap where the next word gets missed.
  void _scheduleRestart() {
    if (_finished || _restartPending) return;
    _restartPending = true;
    Future.delayed(const Duration(milliseconds: 150), () {
      _restartPending = false;
      if (!_finished && mounted) _listen();
    });
  }

  void _scheduleRestartIfDone(String status) {
    if (status == SpeechToText.doneStatus) _scheduleRestart();
  }

  Future<void> _listen() async {
    if (_finished) return;
    _currentPartial = '';
    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            if (result.finalResult) {
              _committedTranscript = _transcript;
              _currentPartial = '';
              _scheduleRestart();
            } else {
              _currentPartial = result.recognizedWords;
            }
          });
          _chunks.add(SpeechChunk(text: result.recognizedWords, timestamp: DateTime.now()));
        },
        // Deliberately short, not the full 60s target: Android's recognizer
        // isn't built to hold one unbroken utterance that long — its result
        // buffer only remembers the most recent portion once a session runs
        // too long, silently truncating the transcript to the tail end. Each
        // session is kept short so it naturally finalizes on normal speech
        // pauses (or the listenFor cap if the user never pauses), and the
        // restart chain in onResult/onStatus stitches the short segments
        // back into one transcript for the full target duration.
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
          // Hybrid recognition (on-device + network when available) rather
          // than forcing offline-only: noticeably more accurate, at the cost
          // of audio sometimes being sent to Google's recognizer instead of
          // staying fully on-device.
          onDevice: false,
          listenFor: const Duration(seconds: 20),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('STT listen() failed: $e');
      // Give the platform side a moment to settle, then try again rather
      // than leaving the rest of the session silently uncaptured.
      _scheduleRestart();
    }
  }

  Future<void> _finish() async {
    _timer?.cancel();
    if (_finished) return;
    _finished = true;
    final sessionRepository = context.read<SessionRepository>();
    await _speech.stop();
    // stop() resolves before the last session's final result callback
    // actually arrives over the platform channel — without this, the words
    // spoken right at the end of the session get dropped from the transcript.
    await Future.delayed(const Duration(milliseconds: 400));

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
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  widget.flowContext.headerLabel,
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
                SvgPicture.asset('assets/main/warmup_waveform.svg', height: 81),
                const Spacer(flex: 4),
                Text(
                  _initError ?? "We'll wrap things up when the timer ends.",
                  textAlign: TextAlign.center,
                  style: OnboardingText.body(
                    color: _initError != null ? OnboardingColors.burgundy : OnboardingColors.creamSubtext,
                  ).copyWith(fontSize: 12),
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
