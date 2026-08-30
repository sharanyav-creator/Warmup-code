import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'data/repositories/session_repository.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/shell/root_shell.dart';

const _hasOnboardedKey = 'has_onboarded';

void main() {
  runApp(const WarmupApp());
}

class WarmupApp extends StatelessWidget {
  const WarmupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<SessionRepository>(
      create: (_) => SessionRepository(),
      child: MaterialApp(
        title: 'Warmup',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppRoot(),
      ),
    );
  }
}

/// Routes to onboarding on first launch, straight to the app afterwards.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  Future<bool> _hasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasOnboardedKey) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasOnboarded(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data! ? const RootShell() : const OnboardingFlow();
      },
    );
  }
}

/// Call when onboarding/sign-in completes so it doesn't show again.
Future<void> markOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_hasOnboardedKey, true);
}

/// Call on log out so the next launch starts from onboarding again.
Future<void> clearOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_hasOnboardedKey, false);
}
