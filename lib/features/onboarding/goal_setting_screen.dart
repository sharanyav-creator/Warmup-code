import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'mic_permission_screen.dart';
import '../../core/design_tokens.dart';

class _GoalOption {
  final String title;
  final String subtitle;
  final String iconAsset;
  final String iconAssetSelected;

  const _GoalOption({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.iconAssetSelected,
  });
}

const List<_GoalOption> _goalOptions = [
  _GoalOption(
    title: 'Public Speaking',
    subtitle: 'Presentations, talks, and speeches',
    iconAsset: 'assets/onboarding/goal_public_speaking.svg',
    iconAssetSelected: 'assets/onboarding/goal_public_speaking_selected.svg',
  ),
  _GoalOption(
    title: 'Interviews',
    subtitle: 'Behavioral and situational questions',
    iconAsset: 'assets/onboarding/goal_interviews.svg',
    iconAssetSelected: 'assets/onboarding/goal_interviews_selected.svg',
  ),
  _GoalOption(
    title: 'Everyday conversation',
    subtitle: 'Small talk that feels easy',
    iconAsset: 'assets/onboarding/goal_everyday_conversation.svg',
    iconAssetSelected: 'assets/onboarding/goal_everyday_conversation_selected.svg',
  ),
  _GoalOption(
    title: 'Storytelling',
    subtitle: 'Turn moments into memorable stories',
    iconAsset: 'assets/onboarding/goal_storytelling.svg',
    iconAssetSelected: 'assets/onboarding/goal_storytelling_selected.svg',
  ),
  _GoalOption(
    title: 'Meetings & work',
    subtitle: 'Speak up clearly in the room',
    iconAsset: 'assets/onboarding/goal_meetings_work.svg',
    iconAssetSelected: 'assets/onboarding/goal_meetings_work_selected.svg',
  ),
];

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'What do you want to get better at?',
                style: OnboardingText.headline(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick one goal to start, you can add more later.',
                style: OnboardingText.body(color: Colors.black),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _goalOptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = _goalOptions[index];
                    final selected = _selectedIndex == index;
                    return _GoalCard(
                      title: option.title,
                      subtitle: option.subtitle,
                      iconAsset: option.iconAsset,
                      iconAssetSelected: option.iconAssetSelected,
                      selected: selected,
                      onTap: () => setState(() => _selectedIndex = index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MicPermissionScreen()),
                    );
                  },
                  child: Text('Continue', style: OnboardingText.buttonLabel(color: Colors.white)),
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

class _GoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final String iconAssetSelected;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.iconAssetSelected,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? Colors.white : Colors.black;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? OnboardingColors.burgundy : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              selected ? iconAssetSelected : iconAsset,
              width: 37,
              height: 37,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: OnboardingText.headline(color: textColor, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: OnboardingText.body(color: selected ? Colors.white : OnboardingColors.creamSubtext)
                        .copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
