class OnboardingPageData {
  final String headline;
  final String body;

  const OnboardingPageData({required this.headline, required this.body});
}

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    headline: 'Practice Daily.\nA minute, a day.',
    body: 'Speak on a prompt, get feedback, and watch real progress build up: '
        'no pressure and no streaks to maintain.',
  ),
  OnboardingPageData(
    headline: 'Get accessed \non what you want!',
    body: 'Every session is recorded on filler words, pacing, pauses and fumbles '
        '— so you know exactly what to work on.',
  ),
  OnboardingPageData(
    headline: 'See where \nyou\'re headed.',
    body: 'Your growth is tracked over weeks, not days. \nSmall reps, real change.',
  ),
];
