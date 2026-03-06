import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _setupSystemUI();
    _initializeVideoControllers();
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeVideoControllers() async {
    for (int i = 0; i < onboardingPages.length; i++) {
      final page = onboardingPages[i];
      if (page.isVideo) {
        final controller = VideoPlayerController.asset(page.mediaPath);
        _videoControllers[i] = controller;

        try {
          await controller.initialize();
          controller.setLooping(true);
          controller.setVolume(0);

          if (i == 0 && mounted) {
            controller.play();
          }

          if (mounted) setState(() {});
        } catch (_) {
          // Video failed to load, will show fallback
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);

    for (final entry in _videoControllers.entries) {
      if (entry.key == page) {
        entry.value.play();
      } else {
        entry.value.pause();
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) entry.value.seekTo(Duration.zero);
        });
      }
    }
  }

  void _goToNextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) context.go('/login');
  }

  void _skipOnboarding() {
    _pageController.animateToPage(
      onboardingPages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final horizontalPadding = size.width * 0.06;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) {
              final page = onboardingPages[index];
              final videoController = _videoControllers[index];

              return _OnboardingPage(
                page: page,
                videoController: videoController,
              );
            },
          ),

          // Skip Button
          if (_currentPage < onboardingPages.length - 1)
            Positioned(
              top: padding.top + size.height * 0.02,
              right: horizontalPadding,
              child: _SkipButton(onTap: _skipOnboarding),
            ),

          // Bottom Controls
          Positioned(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: padding.bottom + size.height * 0.04,
            child: _BottomControls(
              currentPage: _currentPage,
              totalPages: onboardingPages.length,
              onPrevious: _goToPreviousPage,
              onNext: _goToNextPage,
              isLastPage: _currentPage == onboardingPages.length - 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData page;
  final VideoPlayerController? videoController;

  const _OnboardingPage({
    required this.page,
    this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.06;
    final textBottomPosition = size.height * 0.18;
    final titleFontSize = size.width * 0.085;
    final subtitleFontSize = size.width * 0.038;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Media
          if (page.isVideo && videoController != null && videoController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoController!.value.size.width,
                  height: videoController!.value.size.height,
                  child: VideoPlayer(videoController!),
                ),
              ),
            )
          else
            Container(
              color: AppColors.primaryDark,
              child: Center(
                child: Icon(
                  _getPageIcon(),
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),

          // Bottom gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 0.6, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // Text Content
          Positioned(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: textBottomPosition,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.title,
                  style: TextStyle(
                    fontSize: titleFontSize.clamp(28.0, 40.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  page.subtitle,
                  style: TextStyle(
                    fontSize: subtitleFontSize.clamp(13.0, 17.0),
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPageIcon() {
    switch (page.title) {
      case 'Discover Products\nYou Love':
        return Icons.shopping_bag_outlined;
      case 'Search & Filter\nWith Ease':
        return Icons.search_rounded;
      default:
        return Icons.cloud_off_rounded;
    }
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonPaddingH = size.width * 0.022;
    final buttonPaddingV = size.height * 0.006;
    final fontSize = (size.width * 0.028).clamp(10.0, 13.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: buttonPaddingH.clamp(8.0, 12.0),
          vertical: buttonPaddingV.clamp(4.0, 6.0),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Text(
          'Skip',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLastPage;

  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonSize = (size.width * 0.14).clamp(48.0, 64.0);
    final bool isFirstPage = currentPage == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isFirstPage)
          SizedBox(width: buttonSize)
        else
          _BackButton(onTap: onPrevious, size: buttonSize),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            totalPages,
            (index) => _PageIndicator(isActive: index == currentPage),
          ),
        ),

        isLastPage
            ? _GetStartedButton(onTap: onNext)
            : _ForwardButton(onTap: onNext, size: buttonSize),
      ],
    );
  }
}

class _ForwardButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const _ForwardButton({required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    final iconSize = (size * 0.38).clamp(18.0, 26.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(size * 0.06),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const _BackButton({required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    final iconSize = (size * 0.4).clamp(18.0, 24.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withValues(alpha: 0.3),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;

  const _PageIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dotSize = (size.width * 0.025).clamp(8.0, 12.0);
    final margin = (size.width * 0.012).clamp(4.0, 6.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: margin),
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1),
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GetStartedButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final paddingH = (size.width * 0.05).clamp(16.0, 28.0);
    final paddingV = (size.height * 0.018).clamp(12.0, 18.0);
    final fontSize = (size.width * 0.04).clamp(14.0, 18.0);
    final iconSize = (size.width * 0.05).clamp(18.0, 22.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: paddingH,
          vertical: paddingV,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }
}
