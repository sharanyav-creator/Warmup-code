import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';
import '../results/results_screen.dart';
import 'analysis_engine.dart';

class RecordScreen extends StatefulWidget {
  final String promptText;
  final String? trackLabel;

  const RecordScreen({super.key, required this.promptText, this.trackLabel});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final SpeechToText _speech = SpeechToText();
  final List<SpeechChunk> _chunks = [];

  bool _isInitializing = true;
  bool _isListening = false;
  bool _permissionDenied = false;
  String _transcript = '';
  DateTime? _startTime;
  Timer? _countdownTimer;
  int _secondsRemaining = targetSessionLength.inSeconds;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        _permissionDenied = true;
        _isInitializing = false;
      });
      return;
    }
    final available = await _speech.initialize();
    setState(() {
      _isInitializing = false;
      _permissionDenied = !available;
    });
    if (available) _startRecording();
  }

  void _startRecording() {
    _startTime = DateTime.now();
    _chunks.clear();
    setState(() {
      _isListening = true;
      _transcript = '';
      _secondsRemaining = targetSessionLength.inSeconds;
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

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        _finishRecording();
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  Future<void> _finishRecording() async {
    _countdownTimer?.cancel();
    if (!_isListening) return;
    final sessionRepository = context.read<SessionRepository>();
    setState(() => _isListening = false);
    await _speech.stop();

    final duration = _startTime == null
        ? Duration.zero
        : DateTime.now().difference(_startTime!);

    final result = analyzeSession(
      transcript: _transcript,
      chunks: _chunks,
      sessionDuration: duration,
    );

    final record = SessionRecord(
      createdAt: DateTime.now(),
      promptText: widget.promptText,
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
      trackLabel: widget.trackLabel,
    );
    await sessionRepository.insert(record);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultsScreen(result: result)),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: SafeArea(
        child: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : _permissionDenied
                ? _buildPermissionDenied()
                : _buildRecordingUi(),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_off, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Microphone access is needed to record your practice session.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: openAppSettings,
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingUi() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(widget.promptText, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '$_secondsRemaining s',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 40),
          ),
          const SizedBox(height: 16),
          Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 72,
            color: _isListening ? AppTheme.primary : AppTheme.textSecondary,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _transcript.isEmpty ? 'Start speaking…' : _transcript,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isListening ? _finishRecording : null,
              child: const Text('Finish now'),
            ),
          ),
        ],
      ),
    );
  }
}
