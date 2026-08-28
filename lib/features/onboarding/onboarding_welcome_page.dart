import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'onboarding_data.dart';
import '../../core/design_tokens.dart';
import 'widgets/progress_dots.dart';

class OnboardingWelcomePage extends StatelessWidget {
  final OnboardingPageData data;
  final int pageIndex;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingWelcomePage({
    super.key,
    required this.data,
    required this.pageIndex,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OnboardingColors.maroonBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ProgressDots(total: totalPages, activeIndex: pageIndex),
              const SizedBox(height: 40),
              Text(data.headline, style: OnboardingText.headline(color: Colors.white)),
              const SizedBox(height: 16),
              Text(data.body, style: OnboardingText.body(color: Colors.white)),
              const Spacer(flex: 3),
              Center(
                child: SvgPicture.asset(
                  'assets/onboarding/quote_bubble.svg',
                  width: 100.57,
                  height: 78,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: SvgPicture.asset(
                  'assets/onboarding/logo.svg',
                  width: 151.13,
                  height: 37.2,
                ),
              ),
              const Spacer(flex: 4),
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
                  onPressed: onNext,
                  child: Text('Next', style: OnboardingText.buttonLabel(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OnboardingColors.orangeSkipBackground,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: onSkip,
                  child: Text('Skip', style: OnboardingText.buttonLabel(color: Colors.white)),
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
