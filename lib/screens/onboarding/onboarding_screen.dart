import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'tag': 'Household Waste Management',
      'title': 'Smarter Collection.\nCleaner Streets.\nGreener Community 🌱',
      'description': 'Real-time collection schedules, assigned drop points, and automated notifications for your household.',
      'icon': '♻️',
    },
    {
      'tag': 'Waste Segregation Guide',
      'title': 'Segregate with Ease.\nProtect Nature.',
      'description': 'Know exactly what goes into organic, recyclable plastic, paper, glass, and hazardous collection bins.',
      'icon': '🌿',
    },
    {
      'tag': 'BinGo Community',
      'title': 'Connect with Neighbors.\nShare Local Drives.',
      'description': 'Participate in neighborhood cleanups, polls, and stay informed on community waste management.',
      'icon': '🏘️',
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setOnboardingCompleted(true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Brand Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.limeAccent,
                          borderRadius: AppRadii.smRadius,
                        ),
                        child: const Center(
                          child: Text('♻️', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'BinGo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Visual Illustration Hero Card
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final item = _slides[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF1E2620), const Color(0xFF14191C)]
                              : [const Color(0xFFE8F2E4), const Color(0xFFF7FAF5)],
                        ),
                        borderRadius: AppRadii.xlRadius,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 40,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              item['icon']!,
                              style: const TextStyle(fontSize: 84),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Slide Dots Indicator
              Row(
                children: List.generate(_slides.length, (index) {
                  final active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 6),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? (isDark ? AppColors.limeAccent : AppColors.darkPill)
                          : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1)),
                      borderRadius: AppRadii.pillRadius,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Tag & Titles
              Text(
                slide['tag']!.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.emeraldBrand,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                slide['title']!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.6,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                slide['description']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
              ),

              const SizedBox(height: 28),

              // Bottom CTA Pill (Matching Reference 3)
              GestureDetector(
                onTap: () {
                  if (_currentPage < _slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finishOnboarding();
                  }
                },
                child: Container(
                  height: 62,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.limeAccent : AppColors.darkPill,
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkPill : AppColors.limeAccent,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 24,
                            color: isDark ? AppColors.limeAccent : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _currentPage < _slides.length - 1 ? 'Continue' : 'Get Started',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimaryLight : AppColors.darkPillText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Text(
                          '>>',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryLight.withValues(alpha: 0.6)
                                : AppColors.darkPillText.withValues(alpha: 0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
