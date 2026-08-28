import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';

class _Track {
  final String label;
  final String description;

  const _Track({required this.label, required this.description});
}

class _Framework {
  final String track;
  final String title;
  final String subtitle;
  final bool practiced;

  const _Framework({
    required this.track,
    required this.title,
    required this.subtitle,
    required this.practiced,
  });
}

const List<_Track> _tracks = [
  _Track(label: 'All', description: 'Frameworks for every kind of speaking practice.'),
  _Track(
    label: 'Public Speaking',
    description: 'For presentations, talks, and speeches to structure your ideas so a room can follow them.',
  ),
  _Track(label: 'Interviews', description: 'Structures for clear, confident answers under pressure.'),
  _Track(label: 'Everyday Conversation', description: 'Keep small talk and casual chats flowing naturally.'),
  _Track(label: 'Storytelling', description: 'Shape moments into stories people remember.'),
  _Track(label: 'Meetings & work', description: 'Speak up clearly and get to the point in the room.'),
];

const List<_Framework> _frameworks = [
  _Framework(
    track: 'Public Speaking',
    title: "Monroe's Motivated Sequence",
    subtitle: 'The classic structure for persuasive speeches.',
    practiced: false,
  ),
  _Framework(
    track: 'Public Speaking',
    title: 'Rule of Three',
    subtitle: 'Structure your body around exactly three main ideas.',
    practiced: true,
  ),
  _Framework(
    track: 'Interviews',
    title: 'PREP',
    subtitle: 'Point, Reason, Example, Point: fast and persuasive.',
    practiced: true,
  ),
  _Framework(
    track: 'Interviews',
    title: 'STAR',
    subtitle: 'Situation, Task, Action, Result: for behavioral questions.',
    practiced: false,
  ),
  _Framework(
    track: 'Storytelling',
    title: 'Hero\'s Journey (mini)',
    subtitle: 'A simple arc: setup, struggle, turn, payoff.',
    practiced: false,
  ),
];

class FrameworksScreen extends StatefulWidget {
  const FrameworksScreen({super.key});

  @override
  State<FrameworksScreen> createState() => _FrameworksScreenState();
}

class _FrameworksScreenState extends State<FrameworksScreen> {
  int _selectedTrack = 1; // defaults to "Public Speaking", matching the design

  @override
  Widget build(BuildContext context) {
    final track = _tracks[_selectedTrack];
    final frameworks = track.label == 'All'
        ? _frameworks
        : _frameworks.where((f) => f.track == track.label).toList();

    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset('assets/main/frameworks_header_icon.svg', width: 24, height: 24),
                  ),
                  const SizedBox(width: 10),
                  Text('Frameworks', style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'BASED ON TRACKS',
                style: OnboardingText.buttonLabel(color: OnboardingColors.eyebrowGray).copyWith(fontSize: 10),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _tracks.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final selected = index == _selectedTrack;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedTrack = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? OnboardingColors.burgundy : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: OnboardingColors.burgundy),
                      ),
                      child: Text(
                        _tracks[index].label,
                        style: OnboardingText.buttonLabel(color: selected ? Colors.white : Colors.black)
                            .copyWith(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(track.description, style: OnboardingText.body(color: OnboardingColors.creamSubtext)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  for (final f in frameworks) _FrameworkCard(framework: f),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameworkCard extends StatelessWidget {
  final _Framework framework;

  const _FrameworkCard({required this.framework});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (framework.practiced) ...[
                      SvgPicture.asset('assets/main/practiced_check_icon.svg', width: 12, height: 12),
                      const SizedBox(width: 4),
                      Text(
                        'PRACTICED',
                        style: OnboardingText.buttonLabel(color: OnboardingColors.textGray444).copyWith(fontSize: 10),
                      ),
                    ] else
                      Text(
                        'TRY FRAMEWORK',
                        style: OnboardingText.buttonLabel(color: OnboardingColors.tryFrameworkOrange)
                            .copyWith(fontSize: 10),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(framework.title, style: OnboardingText.headline(color: Colors.black, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  framework.subtitle,
                  style: OnboardingText.body(color: OnboardingColors.eyebrowGray).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          SvgPicture.asset('assets/main/chevron_right_small.svg', width: 12, height: 12),
        ],
      ),
    );
  }
}
