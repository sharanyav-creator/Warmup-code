import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/analysis_result.dart';
import '../shell/root_shell.dart';

class ResultsScreen extends StatelessWidget {
  final AnalysisResult result;

  const ResultsScreen({super.key, required this.result});

  Color get _scoreColor {
    if (result.score >= 75) return AppTheme.success;
    if (result.score >= 50) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session results'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: _scoreColor.withValues(alpha: 0.12),
                    child: Text(
                      '${result.score}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 36, color: _scoreColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Clarity score', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _statRow(context, [
              _Stat(label: 'Words', value: '${result.wordCount}'),
              _Stat(label: 'Pace', value: '${result.wordsPerMinute.round()} wpm'),
              _Stat(label: 'Duration', value: '${result.durationSeconds.round()}s'),
            ]),
            const SizedBox(height: 16),
            _sectionCard(
              context,
              title: 'Filler words',
              trailing: '${result.fillerCount}',
              child: result.fillerBreakdown.isEmpty
                  ? const Text('None detected — nice and clean.')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.fillerBreakdown.entries
                          .map((e) => Chip(label: Text('${e.key} ×${e.value}')))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              context,
              title: 'Clutch words',
              trailing: '${result.clutchWords.length}',
              child: result.clutchWords.isEmpty
                  ? const Text('No repeated words stood out.')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.clutchWords
                          .map((c) => Chip(label: Text('${c.word} ×${c.count}')))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              context,
              title: 'Long pauses',
              trailing: '${result.longPauseCount}',
              child: Text(
                result.longPauseCount == 0
                    ? 'Good, steady flow with no long pauses.'
                    : 'Moments where speech paused for 2+ seconds.',
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              context,
              title: 'Transcript',
              child: Text(
                result.transcript.isEmpty ? '(no speech detected)' : result.transcript,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RootShell()),
                    (route) => false,
                  );
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(BuildContext context, List<_Stat> stats) {
    return Row(
      children: stats
          .map(
            (s) => Expanded(
              child: Column(
                children: [
                  Text(s.value, style: Theme.of(context).textTheme.titleLarge),
                  Text(s.label, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    String? trailing,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (trailing != null)
                  Text(trailing, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Stat {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});
}
