import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/dentora_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tcController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isDoctorRole = false;
  bool _obscurePassword = true;
  bool _kvkkAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tcController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;
    final isStrong = AppValidators.isPasswordStrong(pass);
    final isMatch = pass.isNotEmpty && pass == confirmPass;

    if (!isFormValid || !isStrong || !isMatch || !_kvkkAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !_kvkkAccepted
                ? 'Lütfen KVKK metnini onaylayın.'
                : 'Lütfen tüm alanları ve şifre kurallarını tamamlayın.',
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

    if (_isDoctorRole) {
      context.go('/doctor/agenda');
    } else {
      context.go('/patient/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text;
    final tc = _tcController.text.trim();
    final phone = _phoneController.text;
    final email = _emailController.text;
    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;

    final isNameValid = AppValidators.isValidFullName(name);
    final isTcValid = AppValidators.isValidTc(tc);
    final isPhoneValid = AppValidators.isValidPhone(phone);
    final isEmailValid = AppValidators.isValidEmail(email);

    final hasMinLen = AppValidators.hasMinLength(pass);
    final hasUpper = AppValidators.hasUppercase(pass);
    final hasLower = AppValidators.hasLowercase(pass);
    final hasDigit = AppValidators.hasDigit(pass);
    final hasSpecial = AppValidators.hasSpecialChar(pass);
    final isPassMatch = pass.isNotEmpty && pass == confirmPass;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 1. Minimal Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => context.go('/login'),
                          icon: const Icon(
                            Symbols.arrow_back,
                            size: 20,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Row(
                          children: [
                            DentoraLogo(size: 32),
                            SizedBox(width: 8),
                            Text(
                              'Dentora',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 2. Main Registration Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Yeni Hesap Oluştur',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Role Switcher
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
                                    icon: Symbols.person_add,
                                    selected: !_isDoctorRole,
                                    onTap: () =>
                                        setState(() => _isDoctorRole = false),
                                  ),
                                ),
                                Expanded(
                                  child: _buildRoleTab(
                                    label: 'Doktor',
                                    icon: Symbols.medical_services,
                                    selected: _isDoctorRole,
                                    onTap: () =>
                                        setState(() => _isDoctorRole = true),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Ad Soyad
                          _buildLabel('AD SOYAD'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _nameController,
                            validator: AppValidators.validateFullName,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _buildInputDecoration(
                              hint: 'Adınız Soyadınız',
                              prefixIcon: Symbols.badge,
                              isValid: isNameValid,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // TC Kimlik No
                          _buildLabel('TC KİMLİK NO'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _tcController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: AppValidators.validateTc,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _buildInputDecoration(
                              hint: '11 haneli TC Kimlik No',
                              prefixIcon: Symbols.id_card,
                              isValid: isTcValid,
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.topCenter,
                            child: tc.isEmpty
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: _buildCriteriaItem(
                                      label: '11 Haneli TC (${tc.length}/11)',
                                      passed: isTcValid,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 10),

                          // Telefon
                          _buildLabel('CEP TELEFONU'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: AppValidators.validatePhone,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _buildInputDecoration(
                              hint: '05XX XXX XX XX',
                              prefixIcon: Symbols.call,
                              isValid: isPhoneValid,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // E-Posta
                          _buildLabel('E-POSTA'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: AppValidators.validateEmail,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _buildInputDecoration(
                              hint: 'ornek@eposta.com',
                              prefixIcon: Symbols.mail,
                              isValid: isEmailValid,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Şifre
                          _buildLabel('ŞİFRE'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: AppValidators.validatePassword,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration:
                                _buildInputDecoration(
                                  hint: 'Şifre oluşturun',
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

                          // Şifre yazdıkça altta açılan validasyon kriterleri
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.topCenter,
                            child: pass.isEmpty
                                ? const SizedBox.shrink()
                                : Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(top: 8),
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
                          const SizedBox(height: 10),

                          // Şifre Tekrar
                          _buildLabel('ŞİFRE TEKRAR'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscurePassword,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Şifrenizi tekrar giriniz.';
                              }
                              if (val != _passwordController.text) {
                                return 'Şifreler eşleşmiyor.';
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _buildInputDecoration(
                              hint: 'Şifrenizi tekrar giriniz',
                              prefixIcon: Symbols.verified_user,
                              isValid: isPassMatch,
                            ),
                          ),
                          // Şifre tekrar yazdıkça altta açılan eşleşme kontrolü
                          AnimatedSize(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.topCenter,
                            child: confirmPass.isEmpty
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: _buildCriteriaItem(
                                      label: isPassMatch
                                          ? 'Şifreler eşleşti'
                                          : 'Şifreler eşleşmiyor',
                                      passed: isPassMatch,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 12),

                          // KVKK Onayı
                          GestureDetector(
                            onTap: () =>
                                setState(() => _kvkkAccepted = !_kvkkAccepted),
                            child: Row(
                              children: [
                                Icon(
                                  _kvkkAccepted
                                      ? Symbols.check_box
                                      : Symbols.check_box_outline_blank,
                                  size: 20,
                                  fill: _kvkkAccepted ? 1 : 0,
                                  color: _kvkkAccepted
                                      ? AppColors.primary
                                      : AppColors.outline,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'KVKK ve Kullanıcı Sözleşmesini kabul ediyorum.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Kayıt Ol Butonu
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
                                onPressed: _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Kayıt Ol',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Zaten hesabınız var mı? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Giriş Yap',
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
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
      ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isValid
              ? AppColors.emeraldOnline.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
        padding: const EdgeInsets.symmetric(vertical: 9),
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
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
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
