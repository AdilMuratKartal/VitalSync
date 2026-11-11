import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isDoctorRole = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _tcController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_isDoctorRole) {
      context.go('/doctor/agenda');
    } else {
      context.go('/patient/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tcLength = _tcController.text.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Top Subtle Ambient Radial Glow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 290,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -1.0),
                    radius: 1.1,
                    colors: [
                      const Color(0xFF008092).withValues(alpha: 0.14),
                      const Color(0xFF4EE0FD).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Identity & Clinical Header
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.surfaceContainerHigh,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F131B2E),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: DentoraLogo(size: 50),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Dentora',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ağız ve Diş Sağlığı Kliniği',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Segmented Control: Role Switcher (Hasta Girişi / Doktor Girişi)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.surfaceContainerHigh.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isDoctorRole = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: !_isDoctorRole
                                    ? AppColors.surfaceContainerLowest
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: !_isDoctorRole
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x14006574),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Symbols.person,
                                    size: 18,
                                    fill: !_isDoctorRole ? 1 : 0,
                                    color: !_isDoctorRole
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Hasta Girişi',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: !_isDoctorRole
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: !_isDoctorRole
                                            ? AppColors.primary
                                            : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isDoctorRole = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: _isDoctorRole
                                    ? AppColors.surfaceContainerLowest
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isDoctorRole
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x14006574),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Symbols.stethoscope,
                                    size: 18,
                                    fill: _isDoctorRole ? 1 : 0,
                                    color: _isDoctorRole
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Doktor Girişi',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _isDoctorRole
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: _isDoctorRole
                                            ? AppColors.primary
                                            : AppColors.onSurfaceVariant,
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
                  ),
                  const SizedBox(height: 16),

                  // Authentication Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.surfaceContainerHigh.withValues(
                          alpha: 0.9,
                        ),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F131B2E),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Title & Dynamic Portal Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isDoctorRole
                                        ? 'Hekim Paneline Giriş'
                                        : 'Hesabınıza Giriş Yapın',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _isDoctorRole
                                        ? 'Günlük ajanda, hasta kayıtları ve e-reçete yönetimi'
                                        : 'Randevu, tahlil ve tedavi planınıza erişin',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _isDoctorRole
                                    ? AppColors.tertiaryFixed
                                    : AppColors.primaryFixed.withValues(
                                        alpha: 0.7,
                                      ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _isDoctorRole
                                        ? 'Hekim Portalı'
                                        : 'Hasta Portalı',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onPrimaryFixedVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Field 1: TC Kimlik No
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isDoctorRole
                                  ? 'TC KİMLİK / HEKİM SİCİL NO'
                                  : 'TC KİMLİK NUMARASI',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '$tcLength / 11',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: tcLength == 11
                                    ? AppColors.primary
                                    : AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _tcController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: '11 haneli TC Kimlik No giriniz',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                              color: AppColors.outline.withValues(alpha: 0.7),
                            ),
                            prefixIcon: const Icon(
                              Symbols.badge,
                              size: 20,
                              color: AppColors.outline,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field 2: Password
                        const Text(
                          'ŞİFRE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: AppColors.outline.withValues(alpha: 0.7),
                            ),
                            prefixIcon: const Icon(
                              Symbols.lock,
                              size: 20,
                              color: AppColors.outline,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Symbols.visibility
                                    : Symbols.visibility_off,
                                size: 20,
                                color: AppColors.outline,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Utility Row: Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      width: 36,
                                      height: 20,
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: _rememberMe
                                            ? AppColors.primary
                                            : AppColors.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      alignment: _rememberMe
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Flexible(
                                      child: Text(
                                        'Beni Hatırla',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: TextButton(
                                onPressed: () =>
                                    context.push('/forgot-password'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Şifremi Unuttum?',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Primary CTA: Giriş Yap
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryContainer,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Giriş Yap',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Symbols.arrow_forward,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Bottom Secondary Action & Security Notice
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Henüz klinik kaydınız yok mu? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Symbols.chevron_right,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Clinical Encryption Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow.withValues(
                          alpha: 0.85,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.verified_user,
                            size: 16,
                            fill: 1,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'KVKK Uyumlu • 256-Bit SSL Klinik Veri Güvenliği',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
