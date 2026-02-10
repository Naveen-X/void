import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:void_space/data/stores/preferences_store.dart';
import 'package:void_space/services/haptic_service.dart';
import 'package:void_space/app/feature_flags.dart';
import 'package:void_space/ui/theme/void_theme.dart';
import 'package:void_space/ui/theme/void_design.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "VOID SPACE",
      description: "Your personal digital vault.\nA sanctuary for your thoughts, links, and files.",
      icon: Icons.all_inclusive_rounded,
    ),
    OnboardingContent(
      title: "ORGANIZE",
      description: "Save everything in one place.\nImages, PDFs, Links, and Notes.",
      icon: Icons.grid_view_rounded,
    ),
    if (isAiEnabled)
      OnboardingContent(
        title: "AI POWERED",
        description: "Semantic search and auto-summarization.\nFind what you need, instantly.",
        icon: Icons.auto_awesome_rounded,
      ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    HapticService.light();
    if (_currentPage < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    HapticService.medium();
    await PreferencesStore.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = VoidTheme.of(context);
    
    return Scaffold(
      backgroundColor: theme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  HapticService.selection();
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return _buildPage(theme, _contents[index]);
                },
              ),
            ),
            
            // Bottom controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                   // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? theme.textPrimary 
                              : theme.textPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.textPrimary,
                        foregroundColor: theme.bgPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _contents.length - 1 ? "GET STARTED" : "NEXT",
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(VoidTheme theme, OnboardingContent content) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.textPrimary.withValues(alpha: 0.05),
              border: Border.all(
                  color: theme.textPrimary.withValues(alpha: 0.1),
                  width: 1,
              ),
            ),
            child: Icon(
              content.icon,
              size: 80,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 64),
          Text(
            content.title,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 16,
              height: 1.5,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
  });
}
