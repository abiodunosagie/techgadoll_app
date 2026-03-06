enum OnboardingMediaType { image, video }

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String mediaPath;
  final OnboardingMediaType mediaType;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.mediaPath,
    this.mediaType = OnboardingMediaType.image,
  });

  bool get isVideo => mediaType == OnboardingMediaType.video;
}

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    title: 'Discover Products\nYou Love',
    subtitle:
        'Browse through a curated catalog of products with detailed information, ratings, and pricing.',
    mediaPath: 'assets/videos/onboarding_1.mp4',
    mediaType: OnboardingMediaType.video,
  ),
  OnboardingPageData(
    title: 'Search & Filter\nWith Ease',
    subtitle:
        'Find exactly what you need with real-time search and category filters that work together.',
    mediaPath: 'assets/videos/onboarding_2.mp4',
    mediaType: OnboardingMediaType.video,
  ),
  OnboardingPageData(
    title: 'Browse Anywhere,\nAnytime',
    subtitle:
        'Products are cached locally so you can browse your favorites even without an internet connection.',
    mediaPath: 'assets/videos/onboarding_3.mp4',
    mediaType: OnboardingMediaType.video,
  ),
];
