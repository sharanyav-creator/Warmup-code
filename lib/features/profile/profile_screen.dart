import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';
import '../../data/user_profile.dart';
import '../../main.dart';
import '../onboarding/onboarding_flow.dart';

class _ProfileItem {
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ProfileItem(this.label, {this.color, this.onTap});
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userProfile = UserProfile();
  String _displayName = '';

  static const _accountItems = [
    _ProfileItem('Account settings'),
    _ProfileItem('Notifications'),
    _ProfileItem('Practice settings'),
    _ProfileItem('Subscription'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await _userProfile.getDisplayName();
    if (!mounted) return;
    setState(() => _displayName = name);
  }

  Future<void> _logOut(BuildContext context) async {
    await clearOnboarding();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingFlow()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final supportItems = [
      const _ProfileItem('Data & privacy'),
      const _ProfileItem('Help & support'),
      _ProfileItem('Log out', color: const Color(0xFFA31D00), onTap: () => _logOut(context)),
    ];
    final initial = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '';

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
                  child: Text(initial, style: OnboardingText.headline(color: Colors.white, fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_displayName, style: OnboardingText.headline(color: Colors.black, fontSize: 18)),
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
            _SectionCard(items: supportItems),
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
  final List<_ProfileItem> items;

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
              onTap: items[i].onTap ?? () {},
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      items[i].label,
                      style: OnboardingText.headline(
                        color: items[i].color ?? OnboardingColors.textDark1f,
                        fontSize: 14,
                      ),
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
