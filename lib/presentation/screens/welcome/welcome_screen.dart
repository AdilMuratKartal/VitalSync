import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _dragProgress = 0.0;
  bool _isCompleted = false;

  void _completeSlide() {
    if (_isCompleted) return;
    setState(() {
      _isCompleted = true;
      _dragProgress = 1.0;
    });
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Üst: Sadece Logo
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DentoraLogo(size: 42),
                  SizedBox(width: 10),
                  Text(
                    'Dentora',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // 2. Orta: Yatay Doktor & Hasta Görsel Kartı + Kısa Başlık
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHorizontalHeroBanner(),
                  const SizedBox(height: 32),
                  const Text(
                    'Hoş Geldiniz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Randevu ve diş sağlığı takibi tek ekranda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // 3. Alt: Sağa Kaydırmalı (Slide-to-Start) Buton
              _buildSlideToStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalHeroBanner() {
    return Container(
      width: double.infinity,
      height: 185,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1C30),
            AppColors.primary,
            AppColors.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildRoleCard(
                    icon: Symbols.stethoscope,
                    label: 'Doktor',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    child: const Icon(
                      Symbols.dentistry,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildRoleCard(
                    icon: Symbols.sentiment_satisfied,
                    label: 'Hasta',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideToStartButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        const thumbSize = 52.0;
        const padding = 5.0;
        final maxDrag = (maxWidth - thumbSize - (padding * 2)).clamp(
          1.0,
          1000.0,
        );
        final currentOffset = _dragProgress * maxDrag;

        return GestureDetector(
          onTap: _completeSlide,
          onHorizontalDragUpdate: (details) {
            if (_isCompleted) return;
            setState(() {
              _dragProgress =
                  ((currentOffset + details.delta.dx) / maxDrag).clamp(
                    0.0,
                    1.0,
                  );
            });
            if (_dragProgress >= 0.82) {
              _completeSlide();
            }
          },
          onHorizontalDragEnd: (_) {
            if (!_isCompleted) {
              if (_dragProgress >= 0.65) {
                _completeSlide();
              } else {
                setState(() => _dragProgress = 0.0);
              }
            }
          },
          child: Container(
            height: thumbSize + (padding * 2),
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: Opacity(
                    opacity: (1.0 - (_dragProgress * 1.2)).clamp(0.0, 1.0),
                    child: const Text(
                      'Başla  ››',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: currentOffset,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                      ),
                    ),
                    child: Icon(
                      _isCompleted ? Symbols.check : Symbols.arrow_forward,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
