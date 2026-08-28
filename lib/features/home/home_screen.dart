import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/daily_prompts.dart';
import '../../data/models/session_record.dart';
import '../../data/repositories/session_repository.dart';
import '../record/record_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prompt = promptForDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Warmup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text("Today's prompt", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(prompt, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18),
                const SizedBox(width: 6),
                const Text('About one minute'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.mic),
                label: const Text('Start practice'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RecordScreen(promptText: prompt)),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text('Last session', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FutureBuilder<List<SessionRecord>>(
              future: context.read<SessionRepository>().getRecent(1),
              builder: (context, snapshot) {
                final sessions = snapshot.data ?? [];
                if (sessions.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No sessions yet — your first one starts today.'),
                    ),
                  );
                }
                final s = sessions.first;
                return Card(
                  child: ListTile(
                    title: Text('Score ${s.score}'),
                    subtitle: Text('${s.wordCount} words · ${s.fillerCount} fillers · ${s.wordsPerMinute.round()} wpm'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
