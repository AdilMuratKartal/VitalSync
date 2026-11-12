import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../widgets/dentora_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isDoctorRole = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleValidatedLogin() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final pass = _passwordController.text;
    final email = _emailController.text.trim();

    if (!isFormValid ||
        !AppValidators.isValidEmail(email) ||
        !AppValidators.isPasswordStrong(pass)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Lütfen geçerli bir e-posta adresi ve şifre kurallarını eksiksiz tamamlayın.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final authCubit = context.read<AuthCubit>();
    authCubit.clearMessages();
    authCubit.signIn(
      email: email,
      password: pass,
    );
  }

  void _handleDemoLogin({bool? forceDoctorRole}) {
    final targetDoctor = forceDoctorRole ?? _isDoctorRole;
    setState(() {
      _isDoctorRole = targetDoctor;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          targetDoctor
              ? 'Demo önizleme modu (Doktor) açıldı. Gerçek Firebase oturumu oluşturulmadı.'
              : 'Demo önizleme modu (Hasta) açıldı. Gerçek Firebase oturumu oluşturulmadı.',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    if (targetDoctor) {
      context.go('/doctor/agenda');
    } else {
      context.go('/patient/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pass = _passwordController.text;
    final email = _emailController.text.trim();
    final isEmailValid = AppValidators.isValidEmail(email);

    final hasMinLen = AppValidators.hasMinLength(pass);
    final hasUpper = AppValidators.hasUppercase(pass);
    final hasLower = AppValidators.hasLowercase(pass);
    final hasDigit = AppValidators.hasDigit(pass);
    final hasSpecial = AppValidators.hasSpecialChar(pass);

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus ||
          previous.sessionStatus != current.sessionStatus,
      listener: (context, state) {
        if (state.actionStatus.isSucceeded && state.isAuthenticated) {
          final userName = state.user?.fullName ?? '';
          final roleMismatch =
              (_isDoctorRole && state.isPatient) ||
              (!_isDoctorRole && state.isDoctor);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                roleMismatch
                    ? 'Giriş başarılı. Doğrulanmış hesap rolünüze (${state.isDoctor ? "Doktor" : "Hasta"}) göre yönlendiriliyorsunuz.'
                    : 'Hoş geldiniz${userName.isNotEmpty ? ", $userName" : ""}!',
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          context.read<AuthCubit>().clearMessages();
          if (state.isDoctor) {
            context.go('/doctor/agenda');
          } else {
            context.go('/patient/home');
          }
          return;
        }

        if (state.actionStatus.isFailed ||
            state.sessionStatus.isProfileUnavailable) {
          final message =
              state.errorMessage ?? 'Giriş işlemi sırasında bir hata oluştu.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.read<AuthCubit>().clearMessages();
        }
      },
      builder: (context, authState) {
        final isSubmitting = authState.actionStatus.isSubmitting;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 1. Minimal Brand Header
                        const DentoraLogo(size: 56),
                        const SizedBox(height: 10),
                        const Text(
                          'Dentora',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 2. Main Auth Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.surfaceContainerHigh,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D151D23),
                                blurRadius: 24,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Segmented Role Switcher
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildRoleTab(
                                        label: 'Hasta',
                                        icon: Symbols.person,
                                        selected: !_isDoctorRole,
                                        onTap: () => setState(
                                          () => _isDoctorRole = false,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildRoleTab(
                                        label: 'Doktor',
                                        icon: Symbols.stethoscope,
                                        selected: _isDoctorRole,
                                        onTap: () => setState(
                                          () => _isDoctorRole = true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Field 1: E-Posta Adresi (project.md gereği gerçek Firebase e-posta girişi)
                              const Text(
                                'E-POSTA ADRESİ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: AppValidators.validateEmail,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                                decoration: _buildInputDecoration(
                                  hint: 'ornek@eposta.com',
                                  prefixIcon: Symbols.mail,
                                  isValid: isEmailValid,
                                ),
                              ),
                              // E-posta yazdıkça altta çıkan validasyon satırı
                              AnimatedSize(
                                duration: const Duration(milliseconds: 180),
                                alignment: Alignment.topCenter,
                                child: email.isEmpty
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: _buildCriteriaItem(
                                          label: 'Geçerli E-posta Formatı',
                                          passed: isEmailValid,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 14),

                          // Field 2: Şifre
                          const Text(
                            'ŞİFRE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: AppValidators.validatePassword,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                            decoration:
                                _buildInputDecoration(
                                  hint: 'Şifrenizi giriniz',
                                  prefixIcon: Symbols.lock,
                                  isValid: AppValidators.isPasswordStrong(pass),
                                ).copyWith(
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
                                      size: 18,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ),
                          ),

                          // Şifre yazdıkça altta dinamik olarak açılan validasyon kutusu
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.topCenter,
                            child: pass.isEmpty
                                ? const SizedBox.shrink()
                                : Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 6,
                                      children: [
                                        _buildCriteriaItem(
                                          label: '8+ Karakter',
                                          passed: hasMinLen,
                                        ),
                                        _buildCriteriaItem(
                                          label: 'Büyük Harf',
                                          passed: hasUpper,
                                        ),
                                        _buildCriteriaItem(
                                          label: 'Küçük Harf',
                                          passed: hasLower,
                                        ),
                                        _buildCriteriaItem(
                                          label: 'Rakam',
                                          passed: hasDigit,
                                        ),
                                        _buildCriteriaItem(
                                          label: 'Özel Karakter',
                                          passed: hasSpecial,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 12),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _rememberMe = !_rememberMe),
                                child: Row(
                                  children: [
                                    Icon(
                                      _rememberMe
                                          ? Symbols.check_box
                                          : Symbols.check_box_outline_blank,
                                      size: 18,
                                      fill: _rememberMe ? 1 : 0,
                                      color: _rememberMe
                                          ? AppColors.primary
                                          : AppColors.outline,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Beni Hatırla',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.push('/forgot-password'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Şifremi Unuttum',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Primary CTA: Giriş Yap
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : _handleValidatedLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: isSubmitting
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Giriş Yapılıyor...',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'Giriş Yap',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Hızlı Demo Giriş Butonu (Seçili Role Göre Hasta veya Doktor)
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : () => _handleDemoLogin(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                backgroundColor: AppColors.secondaryFixed
                                    .withValues(alpha: 0.4),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Symbols.bolt, size: 18, fill: 1),
                              label: Text(
                                _isDoctorRole
                                    ? 'Hızlı Demo (Doktor)'
                                    : 'Hızlı Demo (Hasta)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Register CTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Hesabınız yok mu? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: const Text(
                            'Kayıt Ol',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildCriteriaItem({required String label, required bool passed}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          passed ? Symbols.check_circle : Symbols.radio_button_unchecked,
          size: 14,
          fill: passed ? 1 : 0,
          color: passed ? AppColors.emeraldOnline : AppColors.outline,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: passed ? FontWeight.w700 : FontWeight.w500,
            color: passed
                ? const Color(0xFF047857)
                : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    required bool isValid,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        prefixIcon,
        size: 18,
        color: isValid ? AppColors.emeraldOnline : AppColors.outline,
      ),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isValid
              ? AppColors.emeraldOnline.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isValid ? AppColors.emeraldOnline : AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              fill: selected ? 1 : 0,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
