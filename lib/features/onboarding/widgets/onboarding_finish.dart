import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../shell/root_shell.dart';

/// Marks onboarding complete and enters the main app. Shared by every
/// screen that can end the onboarding/baseline flow (Skip, Not now,
/// or finishing the baseline analysis).
Future<void> finishOnboarding(BuildContext context) async {
  await markOnboardingComplete();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const RootShell()),
    (route) => false,
  );
}
