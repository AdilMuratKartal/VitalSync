import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _elevationAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.35, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_entranceController);

    _opacityAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _elevationAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    );

    _entranceController.forward();

    // Navigate to welcome screen after ~2.7 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2700), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final shortestSide = math.min(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final logoSize = (shortestSide * 0.62).clamp(210.0, 290.0);

          return AnimatedBuilder(
            animation: Listenable.merge([
              _entranceController,
              _pulseController,
              _shimmerController,
            ]),
            builder: (context, _) {
              final pulseValue = _pulseController.value;
              final shimmerValue = _shimmerController.value;

              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.08),
                    radius: 1.15,
                    colors: [
                      Color(0xFF008092),
                      Color(0xFF004E5A),
                      Color(0xFF00262E),
                      Color(0xFF06131F),
                    ],
                    stops: [0.0, 0.38, 0.72, 1.0],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ambient top-left clinical cyan aura
                    Positioned(
                      top: -shortestSide * 0.25,
                      left: -shortestSide * 0.2,
                      child: Transform.scale(
                        scale: 1.0 + (pulseValue * 0.12),
                        child: Container(
                          width: shortestSide * 0.9,
                          height: shortestSide * 0.9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.secondaryContainer.withValues(
                                  alpha: 0.24 * _elevationAnimation.value,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Ambient bottom-right deep teal glow
                    Positioned(
                      bottom: -shortestSide * 0.25,
                      right: -shortestSide * 0.2,
                      child: Transform.scale(
                        scale: 1.08 - (pulseValue * 0.08),
                        child: Container(
                          width: shortestSide * 0.95,
                          height: shortestSide * 0.95,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryFixed.withValues(
                                  alpha: 0.18 * _elevationAnimation.value,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Outer expanding halo ring 1
                    Opacity(
                      opacity: (1.0 - shimmerValue) *
                          0.35 *
                          _elevationAnimation.value,
                      child: Transform.scale(
                        scale: 0.85 + (shimmerValue * 0.65),
                        child: Container(
                          width: logoSize * 1.15,
                          height: logoSize * 1.15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondaryContainer.withValues(
                                alpha: 0.55,
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Outer pulsing halo backdrop behind the giant logo
                    Transform.scale(
                      scale: 0.96 + (pulseValue * 0.10),
                      child: Container(
                        width: logoSize * 1.24,
                        height: logoSize * 1.24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF4EE0FD).withValues(
                                alpha: 0.34 * _elevationAnimation.value,
                              ),
                              const Color(0xFF008092).withValues(
                                alpha: 0.14 * _elevationAnimation.value,
                              ),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Frosted glass pedestal frame around the giant logo
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: logoSize * 1.12,
                          height: logoSize * 1.12,
                          padding: EdgeInsets.all(logoSize * 0.06),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(logoSize * 0.34),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.04),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.25 + (pulseValue * 0.15),
                              ),
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00141A).withValues(
                                  alpha: 0.65 * _elevationAnimation.value,
                                ),
                                blurRadius: 60,
                                spreadRadius: 8,
                                offset: const Offset(0, 26),
                              ),
                              BoxShadow(
                                color: const Color(0xFF4EE0FD).withValues(
                                  alpha: (0.28 + pulseValue * 0.16) *
                                      _elevationAnimation.value,
                                ),
                                blurRadius: 70,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Main large Dentora Logo filling the frame
                              DentoraLogo(
                                size: logoSize,
                                showGlow: true,
                              ),

                              // Diagonal animated light sweep (shimmer) over the logo
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(logoSize * 0.28),
                                child: IgnorePointer(
                                  child: FractionalTranslation(
                                    translation: Offset(
                                      (shimmerValue * 2.6) - 1.3,
                                      (shimmerValue * 2.6) - 1.3,
                                    ),
                                    child: Transform.rotate(
                                      angle: -math.pi / 4,
                                      child: Container(
                                        width: logoSize * 0.45,
                                        height: logoSize * 1.8,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0.0),
                                              Colors.white.withValues(alpha: 0.28),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
