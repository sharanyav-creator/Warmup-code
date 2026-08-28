import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _accountItems = ['Account settings', 'Notifications', 'Practice settings', 'Subscription'];
  static const _supportItems = ['Data & privacy', 'Help & support', 'About & legal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            Text('Profile', style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: OnboardingColors.burgundy, shape: BoxShape.circle),
                  child: Text('D', style: OnboardingText.headline(color: Colors.white, fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dev Patel', style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      'Member since April 2026',
                      style: OnboardingText.buttonLabel(color: OnboardingColors.textDark1f).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel('ACCOUNT'),
            const SizedBox(height: 8),
            _SectionCard(items: _accountItems),
            const SizedBox(height: 24),
            _SectionLabel('SUPPORT'),
            const SizedBox(height: 8),
            _SectionCard(items: _supportItems),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: OnboardingText.buttonLabel(color: OnboardingColors.eyebrowGray).copyWith(fontSize: 10));
  }
}

class _SectionCard extends StatelessWidget {
  final List<String> items;

  const _SectionCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE5E0D8)),
              const SizedBox(height: 14),
            ],
            InkWell(
              onTap: () {},
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      items[i],
                      style: OnboardingText.headline(color: OnboardingColors.textDark1f, fontSize: 14),
                    ),
                  ),
                  SvgPicture.asset('assets/main/chevron_right_small.svg', width: 12, height: 12),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
