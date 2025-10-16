import 'package:flutter/material.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _waveController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Scale animation with bounce
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for loading
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(_rotateController);

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scaleController.forward();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        PPages.wrapperPageUi,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A1B4B), // Deep Blue
              Color(0xFF4A148C), // Deep Purple
              Color(0xFF6A1B9A), // Purple
              Color(0xFF3949AB), // Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated wave patterns
            _buildWavePattern(),
            
            // Floating particles
            _buildFloatingParticles(),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animations
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: _buildLogo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Color(0xFF64B5F6),
                            Color(0xFF9C27B0),
                            Color(0xFFE1BEE7),
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        "Sociva",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 58,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: Offset(0, 8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      "Connect. Share. Inspire.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 70),

                  // Circular loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildLoadingIndicator(),
                  ),
                ],
              ),
            ),

            // Bottom section
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      "Made with ❤️ for creators",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.8,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      "v1.0.0",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWavePattern() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100 + (_waveAnimation.value * 50),
              right: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF7E57C2).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -200 + (_waveAnimation.value * -30),
              left: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF42A5F5).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return Stack(
      children: [
        _buildParticle(top: 120, left: 40, size: 8, delay: 0),
        _buildParticle(top: 250, right: 60, size: 6, delay: 500),
        _buildParticle(bottom: 200, left: 50, size: 10, delay: 1000),
        _buildParticle(bottom: 350, right: 40, size: 7, delay: 1500),
        _buildParticle(top: 450, left: 120, size: 5, delay: 800),
        _buildParticle(top: 180, right: 100, size: 9, delay: 1200),
      ],
    );
  }

  Widget _buildParticle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required int delay,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 2000 + delay),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, -value * 100),
            child: Opacity(
              opacity: (1 - value) * 0.8,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF64B5F6),
                      Color(0xFF9C27B0),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF64B5F6).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFF9C27B0),
            Color(0xFF673AB7),
            Color(0xFF3F51B5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF9C27B0).withOpacity(0.6),
            blurRadius: 50,
            offset: Offset(0, 20),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Color(0xFF3F51B5).withOpacity(0.4),
            blurRadius: 80,
            offset: Offset(0, 30),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Center(
            child: Icon(
              Icons.people_alt_rounded,
              size: 70,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return RotationTransition(
      turns: _rotateAnimation,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF64B5F6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}