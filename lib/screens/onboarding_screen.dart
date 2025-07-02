import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class OnboardingItem {
  final String emoji;
  final String title;
  final String desc;
  final String buttonLabel;
  final IconData icon;
  final List<String> floatingElements;
  final String imagePath;

  OnboardingItem({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.buttonLabel,
    required this.icon,
    required this.floatingElements,
    required this.imagePath,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  bool _isAnimating = false;
  late AnimationController _rotationController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  static const Color primaryBg = Color(0xFF0A192F);
  static const Color secondaryBg = Color(0xFF112240);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color accentBlue = Color(0xFF3A7BD5);

  final List<OnboardingItem> onboardingData = [
    OnboardingItem(
      emoji: '🚀',
      title: 'أهلاً بك في قسطها',
      desc:
          'حيث تبدأ خطتك الذكية للتقسيط بدون بنوك، بأمان، وتحكم كامل بين يديك!',
      buttonLabel: 'التالي',
      icon: Icons.auto_awesome,
      floatingElements: ['💎', '⭐', '✨'],
      imagePath: 'assets/animations/onboarding1.json',
    ),
    OnboardingItem(
      emoji: '💳',
      title: 'اشتري وادفع بالتقسيط',
      desc: 'منتجات وخدمات. ابدأ خطة تقسيط بدون أي وسطاء أو تعقيدات.',
      buttonLabel: 'التالي',
      icon: Icons.flash_on,
      floatingElements: ['💰', '🎯', '⚡'],
      imagePath: 'assets/animations/onboarding2.json',
    ),
    OnboardingItem(
      emoji: '🛡️',
      title: 'دفع آمن وخيارات مرنة',
      desc:
          'ادفع أقساطك بكل سهولة عبر وسائل دفع متعددة، مع حماية كاملة لبياناتك.',
      buttonLabel: 'ابدأ الآن',
      icon: Icons.security,
      floatingElements: ['🔒', '🌟', '💫'],
      imagePath: 'assets/animations/onboarding3.json',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1 && !_isAnimating) {
      setState(() {
        _isAnimating = true;
        _currentPage++;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _isAnimating = false);
      });
    } else if (_currentPage == onboardingData.length - 1) {
      context.go('/login');
    }
  }

  void _prevPage() {
    if (_currentPage > 0 && !_isAnimating) {
      setState(() {
        _isAnimating = true;
        _currentPage--;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _isAnimating = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryBg,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            _buildFloatingElements(),
            _buildGeometricShapes(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildContent()),
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_rotationController.value * 2 * math.pi) * 0.5,
                math.cos(_rotationController.value * 2 * math.pi) * 0.5,
              ),
              radius: 1.5,
              colors: [
                neonCyan.withValues(alpha: 0.2),
                accentBlue.withValues(alpha: 0.15),
                primaryBg,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingElements() {
    final currentData = onboardingData[_currentPage];
    return Stack(
      children: currentData.floatingElements.take(2).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final element = entry.value;
        return AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            final offset = math.sin((_floatingController.value + index * 0.5) * math.pi) * 10;
            return Positioned(
              left: 80.0 + index * 120,
              top: 180.0 + offset,
              child: AnimatedOpacity(
                opacity: _isAnimating ? 0.2 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  element,
                  style: const TextStyle(
                    fontSize: 20,
                    shadows: [Shadow(color: neonCyan, blurRadius: 5)],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildGeometricShapes() {
    return Stack(
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Positioned(
              left: (index * 80.0) % MediaQuery.of(context).size.width,
              top: (index * 120.0) % MediaQuery.of(context).size.height,
              child: AnimatedOpacity(
                opacity: 0.2 + _pulseController.value * 0.2,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? neonCyan : accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (_currentPage > 0)
                GestureDetector(
                  onTap: _prevPage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
              const SizedBox(width: 16),
              _buildProgressIndicator(),
            ],
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'تخطي',
              style: GoogleFonts.tajawal(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(onboardingData.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          margin: const EdgeInsets.only(left: 4),
          height: 4,
          width: index == _currentPage ? 32 : 16,
          decoration: BoxDecoration(
            color: index <= _currentPage
                ? neonCyan
                : Colors.white.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(2),
            boxShadow: index == _currentPage
                ? [
                    BoxShadow(
                      color: neonCyan.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildContent() {
    final currentData = onboardingData[_currentPage];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _build3DCard(currentData),
        const SizedBox(height: 40),
        _buildTextContent(currentData),
      ],
    );
  }

  Widget _build3DCard(OnboardingItem data) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return AnimatedScale(
          scale: _isAnimating ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentBlue.withValues(alpha: 0.3),
                  neonCyan.withValues(alpha: 0.2),
                  secondaryBg.withValues(alpha: 0.9),
                ],
              ),
              border: Border.all(
                color: neonCyan.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: neonCyan.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner glow
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                // Main Lottie animation
                Lottie.asset(
                  data.imagePath,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: neonCyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(data.icon, size: 40, color: neonCyan),
                          const SizedBox(height: 16),
                          Text(
                            data.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Orbiting particles
                ...List.generate(2, (index) {
                  return AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      final angle = (_rotationController.value + index * 0.5) * math.pi;
                      final radius = 60.0;
                      return Positioned(
                        left: 140 + math.cos(angle) * radius - 2,
                        top: 140 + math.sin(angle) * radius - 2,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: neonCyan.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextContent(OnboardingItem data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              data.title,
              key: ValueKey(data.title),
              style: GoogleFonts.tajawal(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Colors.white, neonCyan],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                shadows: [
                  Shadow(
                    color: neonCyan.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              data.desc,
              key: ValueKey(data.desc),
              style: GoogleFonts.tajawal(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.6,
                shadows: [
                  Shadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 5,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
              AnimatedOpacity(
                opacity: _currentPage > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _buildBackButton(),
              ),
              const SizedBox(width: 16),
              // Next button
              Expanded(child: _buildNextButton()),
              const SizedBox(width: 16),
              // Counter
              _buildCounter(),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© qasetha',
            style: GoogleFonts.tajawal(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _prevPage,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: neonCyan.withValues(alpha: 0.3), width: 1),
        ),
        child: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildNextButton() {
    final currentData = onboardingData[_currentPage];
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [neonCyan, accentBlue]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: neonCyan.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shine effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: const Alignment(-1, -1),
                    end: const Alignment(1, 1),
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentData.buttonLabel,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentPage == onboardingData.length - 1
                        ? Icons.arrow_back
                        : Icons.chevron_left,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '${_currentPage + 1}/${onboardingData.length}',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: neonCyan,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
