import 'package:flutter/material.dart';

import 'onboarding_data.dart';
import 'onboarding_welcome_page.dart';
import 'sign_in_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _page = 0;

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _next() {
    if (_page < onboardingPages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _goToSignIn();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          for (var i = 0; i < onboardingPages.length; i++)
            OnboardingWelcomePage(
              data: onboardingPages[i],
              pageIndex: i,
              totalPages: onboardingPages.length,
              onNext: _next,
              onSkip: _goToSignIn,
            ),
        ],
      ),
    );
  }
}
