import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _kvkkAccepted = false;

  @override
  void dispose() {
    _tcController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  int get _passwordStrength {
    final val = _passwordController.text;
    if (val.isEmpty) return 0;
    int score = 0;
    if (val.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(val) && RegExp(r'[a-z]').hasMatch(val)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(val) ||
        RegExp(r'[^A-Za-z0-9]').hasMatch(val)) {
      score++;
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final tcLength = _tcController.text.length;
    final strength = _passwordStrength;

    String strengthLabel = 'En az 8 karakter, 1 büyük harf ve rakam';
    Color strengthTextColor = AppColors.outline;
    Color barColor = AppColors.surfaceContainerHighest;

    if (strength == 1) {
      strengthLabel = 'Zayıf Şifre';
      strengthTextColor = AppColors.error;
      barColor = AppColors.error;
    } else if (strength == 2) {
      strengthLabel = 'Orta Güvenlik';
      strengthTextColor = AppColors.tertiary;
      barColor = AppColors.tertiary;
    } else if (strength == 3) {
      strengthLabel = 'Güçlü Şifre';
      strengthTextColor = AppColors.primary;
      barColor = AppColors.primary;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header Bar
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.92),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.surfaceContainerHigh.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      DentoraLogo(size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Dentora',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.verified_user,
                            size: 14,
                            fill: 1,
                            color: AppColors.onSecondaryFixedVariant,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'HASTA PORTALI KAYDI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: AppColors.onSecondaryFixedVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Yeni Hesap Oluştur',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Randevularınızı yönetmek, röntgen ve reçetelerinize anında ulaşmak için bilgilerinizi eksiksiz giriniz.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Card 1: TC Kimlik Numarası
                    _buildFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'TC KİMLİK NUMARASI',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tcLength == 11
                                      ? AppColors.secondaryFixed
                                      : AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$tcLength/11 Hane',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: tcLength == 11
                                        ? AppColors.primary
                                        : AppColors.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _tcController,
                            hint: '11 haneli TC Kimlik Numaranız',
                            icon: Symbols.badge,
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              Icon(
                                Symbols.info,
                                size: 13,
                                color: AppColors.outline,
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'e-Nabız ve klinik protokol eşleşmesi için zorunludur.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 2: Ad Soyad
                    _buildFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AD SOYAD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _nameController,
                            hint: 'Örn. Zeynep Kaya',
                            icon: Symbols.person,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 3: İletişim Bilgileri (Telefon & E-posta)
                    _buildFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TELEFON NUMARASI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _phoneController,
                            hint: '05XX XXX XX XX',
                            icon: Symbols.call,
                            keyboardType: TextInputType.phone,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(
                              color: AppColors.surfaceContainerHigh,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'E-POSTA ADRESİ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _emailController,
                            hint: 'ornek@eposta.com',
                            icon: Symbols.mail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 4: Güvenlik & Şifre Belirleme
                    _buildFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ŞİFRE OLUŞTUR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _passwordController,
                            hint: 'En az 8 karakterli şifre',
                            icon: Symbols.lock,
                            obscureText: _obscurePassword,
                            onChanged: (_) => setState(() {}),
                            suffix: IconButton(
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
                          ),
                          const SizedBox(height: 10),
                          // 3-bar Strength Meter
                          Row(
                            children: [
                              for (int i = 1; i <= 3; i++) ...[
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: strength >= i
                                          ? barColor
                                          : AppColors.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                                if (i < 3) const SizedBox(width: 6),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  strengthLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: strengthTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '256-bit SSL',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(
                              color: AppColors.surfaceContainerHigh,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'ŞİFRE TEKRAR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: _passwordConfirmController,
                            hint: 'Şifrenizi tekrar giriniz',
                            icon: Symbols.enhanced_encryption,
                            obscureText: _obscureConfirm,
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                              icon: Icon(
                                _obscureConfirm
                                    ? Symbols.visibility
                                    : Symbols.visibility_off,
                                size: 20,
                                color: AppColors.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // KVKK Consent Checkbox Card
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _kvkkAccepted = !_kvkkAccepted;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _kvkkAccepted
                                ? AppColors.primary
                                : AppColors.surfaceContainerHigh,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: _kvkkAccepted
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _kvkkAccepted
                                      ? AppColors.primary
                                      : AppColors.outlineVariant,
                                ),
                              ),
                              child: _kvkkAccepted
                                  ? const Icon(
                                      Symbols.check,
                                      size: 15,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    height: 1.45,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'KVKK Aydınlatma Metni',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: '’ni ve '),
                                    TextSpan(
                                      text: 'Klinik Hasta Gizlilik Sözleşmesi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '’ni okudum, kişisel sağlık verilerimin işlenmesini onaylıyorum.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Primary CTA: Kayıt Oluştur
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Hasta kaydınız başarıyla oluşturuldu!',
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            context.go('/patient/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Kayıt Oluştur',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Symbols.arrow_forward,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Already Registered Link
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Zaten bir hesabınız var mı? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Giriş Yapın',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildFormCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A131B2E),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    bool obscureText = false,
    Widget? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      obscureText: obscureText,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.outline.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(icon, size: 20, color: AppColors.outline),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
