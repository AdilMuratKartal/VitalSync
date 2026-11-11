import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_colors.dart';

/// Custom vector clinical tooth + cross/spark emblem representing the Dentora logo.
class DentoraLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final Color? backgroundColor;

  const DentoraLogo({
    super.key,
    this.size = 40,
    this.showGlow = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: backgroundColor == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF004E5A),
                  Color(0xFF006574),
                  Color(0xFF088395),
                  Color(0xFF4EE0FD),
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              )
            : null,
        color: backgroundColor,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF008092).withValues(alpha: 0.45),
                  blurRadius: size * 0.45,
                  spreadRadius: size * 0.06,
                  offset: Offset(0, size * 0.12),
                ),
                BoxShadow(
                  color: const Color(0xFF4EE0FD).withValues(alpha: 0.30),
                  blurRadius: size * 0.8,
                  spreadRadius: size * 0.02,
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: size * 0.22,
                  offset: Offset(0, size * 0.08),
                ),
              ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner glass highlight
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.32),
                  width: math.max(1.0, size * 0.025),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Custom painted molar tooth & clinical star
          CustomPaint(
            size: Size(size * 0.62, size * 0.62),
            painter: _DentoraToothPainter(),
          ),
        ],
      ),
    );
  }
}

class _DentoraToothPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft drop shadow behind tooth
    final shadowPaint = Paint()
      ..color = const Color(0xFF001F25).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final toothPath = _buildToothPath(w, h);
    canvas.save();
    canvas.translate(0, h * 0.04);
    canvas.drawPath(toothPath, shadowPaint);
    canvas.restore();

    // Main tooth body fill
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFE8FAFF),
          Color(0xFFC3F0FF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(toothPath, fillPaint);

    // Tooth crown smile / contour accent line in teal
    final accentPaint = Paint()
      ..color = const Color(0xFF006574)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round;

    final smilePath = Path()
      ..moveTo(w * 0.30, h * 0.28)
      ..quadraticBezierTo(w * 0.50, h * 0.40, w * 0.70, h * 0.28);
    canvas.drawPath(smilePath, accentPaint);

    // Clinical sparkle/star on top-right
    final sparkPaint = Paint()
      ..color = const Color(0xFFA7EEFF)
      ..style = PaintingStyle.fill;

    final cx = w * 0.84;
    final cy = h * 0.14;
    final r = w * 0.13;
    final sparkPath = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx, cy, cx + r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + r)
      ..quadraticBezierTo(cx, cy, cx - r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - r)
      ..close();
    canvas.drawPath(sparkPath, sparkPaint);
  }

  Path _buildToothPath(double w, double h) {
    final path = Path();
    // Start at top center valley of crown
    path.moveTo(w * 0.50, h * 0.14);
    // Top-right cusp
    path.cubicTo(w * 0.65, h * 0.04, w * 0.92, h * 0.08, w * 0.92, h * 0.32);
    // Right side tapering down to right root
    path.cubicTo(w * 0.92, h * 0.52, w * 0.80, h * 0.66, w * 0.74, h * 0.88);
    // Right root tip
    path.cubicTo(w * 0.71, h * 0.97, w * 0.61, h * 0.97, w * 0.58, h * 0.84);
    // Inner root arch
    path.cubicTo(w * 0.55, h * 0.70, w * 0.53, h * 0.64, w * 0.50, h * 0.64);
    path.cubicTo(w * 0.47, h * 0.64, w * 0.45, h * 0.70, w * 0.42, h * 0.84);
    // Left root tip
    path.cubicTo(w * 0.39, h * 0.97, w * 0.29, h * 0.97, w * 0.26, h * 0.88);
    // Left side going up to top-left cusp
    path.cubicTo(w * 0.20, h * 0.66, w * 0.08, h * 0.52, w * 0.08, h * 0.32);
    // Top-left cusp back to center valley
    path.cubicTo(w * 0.08, h * 0.08, w * 0.35, h * 0.04, w * 0.50, h * 0.14);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Shared Top App Bar for the Patient Portal matching Stitch's sticky glass header.
class PatientTopAppBar extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBack;
  final String subtitle;

  const PatientTopAppBar({
    super.key,
    this.showBackButton = false,
    this.onBack,
    this.subtitle = 'Hasta Portalı',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A131B2E),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showBackButton) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onBack ?? () => context.pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Symbols.arrow_back_ios_new,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              const DentoraLogo(size: 38),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dentora',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppColors.primary,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Quick Notification Button
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Yeni bildiriminiz bulunmuyor.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Symbols.notifications,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Profile Avatar -> Navigates to Profile & Settings
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push('/patient/profile'),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryContainer.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/avatar_profile_header.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared Top App Bar for the Doctor Portal matching Stitch's clinical header.
class DoctorTopAppBar extends StatelessWidget {
  const DoctorTopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.doctorSurface.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: AppColors.doctorSurfaceContainerHigh.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0B1C30),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const DentoraLogo(size: 40),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Dr. Selin Yılmaz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixedDoctor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Nöbetçi',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSecondaryFixedVariantDoctor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ağız, Diş ve Çene Cerrahisi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Klinik bildirimleri güncel.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.doctorSurfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Symbols.notifications,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                tooltip: 'Hekim Menüsü',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) {
                  if (value == 'patient') {
                    context.go('/patient/home');
                  } else if (value == 'logout') {
                    context.go('/login');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'patient',
                    child: Row(
                      children: [
                        Icon(Symbols.switch_account, size: 18, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text('Hasta Portalına Geç', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Symbols.logout, size: 18, color: AppColors.error),
                        SizedBox(width: 10),
                        Text('Giriş Ekranına Dön', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.doctorSurfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Symbols.account_circle,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Centers a mobile-proportioned viewport (430px max width) when viewed on wide desktop Chrome
/// so that the mobile Stitch designs look 1:1 with the reference screenshots without stretching.
class MobileViewportFrame extends StatelessWidget {
  final Widget child;

  const MobileViewportFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 500) {
          return child;
        }
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B1C30),
                Color(0xFF0F293A),
                Color(0xFF132238),
              ],
            ),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 48,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: const Color(0xFF4EE0FD).withValues(alpha: 0.12),
                    blurRadius: 80,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRect(child: child),
            ),
          ),
        );
      },
    );
  }
}

