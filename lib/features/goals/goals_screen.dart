import 'package:flutter/material.dart';

/// Placeholder — replace with the exact Figma design once that screen is shared.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  static const _tracks = [
    (title: 'Reduce filler words', subtitle: 'Cut down on "um", "like", and "so"', icon: Icons.spellcheck),
    (title: 'Interview prep', subtitle: 'Practice clear, confident answers', icon: Icons.work_outline),
    (title: 'Public speaking', subtitle: 'Build comfort speaking to a room', icon: Icons.campaign_outlined),
    (title: 'Everyday conversation', subtitle: 'Sound natural in daily chats', icon: Icons.chat_bubble_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Focus areas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final track in _tracks)
              Card(
                child: ListTile(
                  leading: Icon(track.icon),
                  title: Text(track.title),
                  subtitle: Text(track.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }
}
