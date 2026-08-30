import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';
import '../../data/user_profile.dart';
import 'goal_setting_screen.dart';
import 'widgets/onboarding_finish.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _nameController = TextEditingController();
  final _userProfile = UserProfile();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue(BuildContext context) async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await _userProfile.setDisplayName(name);
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GoalSettingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Text(
                'Create your account',
                textAlign: TextAlign.center,
                style: OnboardingText.headline(color: Colors.black, fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'It helps in saving and syncing your progress!',
                textAlign: TextAlign.center,
                style: OnboardingText.body(color: OnboardingColors.creamSubtext),
              ),
              const Spacer(flex: 3),
              _FormField(controller: _nameController, hint: 'Name *'),
              const SizedBox(height: 12),
              const _FormField(hint: 'Phone Number'),
              const SizedBox(height: 12),
              const _FormField(hint: 'Email ID'),
              const SizedBox(height: 16),
              Text(
                'Or',
                style: OnboardingText.buttonLabel(color: OnboardingColors.creamSubtext).copyWith(fontSize: 12),
              ),
              const SizedBox(height: 16),
              _WhitePillButton(
                label: 'Continue with Google',
                iconAsset: 'assets/onboarding/google_icon.svg',
                iconSize: const Size(18, 18),
                onTap: () => _continue(context),
              ),
              const SizedBox(height: 12),
              _WhitePillButton(
                label: 'Continue with Apple',
                iconAsset: 'assets/onboarding/apple_icon.svg',
                iconSize: const Size(25, 28),
                onTap: () => _continue(context),
              ),
              const SizedBox(height: 24),
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
                  onPressed: () => _continue(context),
                  child: Text('Create Account', style: OnboardingText.buttonLabel(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => finishOnboarding(context),
                child: Text('Skip', style: OnboardingText.buttonLabel(color: Colors.black)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;

  const _FormField({required this.hint, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: OnboardingText.body(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: OnboardingText.body(color: OnboardingColors.creamSubtext),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}

class _WhitePillButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final Size iconSize;
  final VoidCallback onTap;

  const _WhitePillButton({
    required this.label,
    required this.iconAsset,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconAsset, width: iconSize.width, height: iconSize.height),
            const SizedBox(width: 10),
            Text(label, style: OnboardingText.body(color: OnboardingColors.creamSubtext)),
          ],
        ),
      ),
    );
  }
}
