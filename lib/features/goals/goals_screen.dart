import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';
import '../record/record_screen.dart';

class _TrackItem {
  final String eyebrow;
  final String title;
  final String subtitle;
  final bool primary;
  final List<String> prompts;

  const _TrackItem({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.prompts,
    this.primary = false,
  });
}

const List<_TrackItem> _yourTracks = [
  _TrackItem(
    eyebrow: 'PRIMARY TRACK',
    title: 'Interview Track',
    subtitle: 'Behavioral and situational questions',
    primary: true,
    prompts: [
      'Tell me about a time you disagreed with a teammate.',
      'Describe a project that didn\'t go as planned.',
      'Walk me through a decision you regret.',
    ],
  ),
  _TrackItem(
    eyebrow: 'RANDOM • IMPROMPTU',
    title: 'Everyday conversation',
    subtitle: 'Small talk that feels easy',
    prompts: [
      'What did you do this weekend?',
      "What's a show you've been meaning to watch?",
      'Any good food recommendations lately?',
    ],
  ),
  _TrackItem(
    eyebrow: 'TECHNIQUE BASED',
    title: 'Storytelling',
    subtitle: 'Turn moments into memorable stories',
    prompts: [
      'Tell a story about a time you got lost.',
      'Describe the best surprise you ever had.',
      'Talk about a moment that changed your perspective.',
    ],
  ),
];

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  void _startTrackPractice(BuildContext context, _TrackItem track) {
    final prompt = track.prompts[DateTime.now().millisecondsSinceEpoch % track.prompts.length];
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecordScreen(promptText: prompt)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Your Tracks', style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  for (final track in _yourTracks)
                    _TrackCard(track: track, onPlay: () => _startTrackPractice(context, track)),
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
                      onPressed: () {},
                      child: Text('Explore more Tracks', style: OnboardingText.buttonLabel(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final _TrackItem track;
  final VoidCallback onPlay;

  const _TrackCard({required this.track, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: track.primary
            ? const Border(left: BorderSide(color: OnboardingColors.burgundy, width: 6))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.eyebrow,
                  style: OnboardingText.buttonLabel(color: OnboardingColors.eyebrowGray).copyWith(fontSize: 10),
                ),
                const SizedBox(height: 6),
                Text(track.title, style: OnboardingText.headline(color: Colors.black, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  track.subtitle,
                  style: OnboardingText.buttonLabel(color: OnboardingColors.orange).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onPlay,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: OnboardingColors.burgundy, borderRadius: BorderRadius.circular(10)),
              child: SvgPicture.asset('assets/main/track_play_icon.svg', width: 24, height: 24),
            ),
          ),
        ],
      ),
    );
  }
}
