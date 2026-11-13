import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _smsReminder = true;
  bool _rxAlerts = true;
  bool _checkupReminder = false;

  // Patient profile editable information
  String _phone = '+90 532 418 90 12';
  String _email = 'zeynep.demir@eposta.com';
  String _bloodType = 'A Rh+';
  String _allergy = 'Penisilin Alerjisi';
  String _address = 'Bağdat Caddesi No: 142/5 Kadıköy / İstanbul';
  String _emergencyContact = 'Ahmet Demir (Eşi) - 0533 111 22 33';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PatientTopAppBar(
              showBackButton: true,
              subtitle: 'Profilim & Ayarlar',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. PATIENT IDENTITY HERO CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 74,
                                height: 74,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/images/zeynep_demir_profile.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Flexible(
                                          child: Text(
                                            'Zeynep Demir',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryFixed,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Symbols.verified,
                                                size: 12,
                                                fill: 1,
                                                color: AppColors.primary,
                                              ),
                                              SizedBox(width: 3),
                                              Text(
                                                'Onaylı Hasta',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors
                                                      .onSecondaryFixed,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'TC: 348••••••92 • Hasta No: #DT-4829',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Symbols.bloodtype,
                                                size: 14,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _bloodType,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_allergy.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.errorContainer
                                                  .withValues(alpha: 0.55),
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Symbols.warning,
                                                  size: 14,
                                                  color: AppColors.error,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _allergy,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.onErrorContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(
                            color: AppColors.surfaceContainerHigh,
                            height: 1,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Symbols.call,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'TELEFON',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              _phone,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Symbols.mail,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'E-POSTA',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              _email,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.onSurface,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 2. BİLDİRİM & HATIRLATICI TERCİHLERİ
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'BİLDİRİMLER & HATIRLATICILAR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: Symbols.notifications_active,
                            title: 'Randevu Hatırlatıcıları (SMS & Push)',
                            subtitle: 'Randevudan 24 ve 2 saat önce bilgilendir',
                            value: _smsReminder,
                            onChanged: (v) => setState(() => _smsReminder = v),
                          ),
                          const Divider(
                            color: AppColors.surfaceContainerLow,
                            height: 1,
                          ),
                          _buildSwitchTile(
                            icon: Symbols.medication,
                            title: 'İlaç & Reçete Kullanım Saatleri',
                            subtitle:
                                'Antibiyotik ve gargara doz zamanı uyarıları',
                            value: _rxAlerts,
                            onChanged: (v) => setState(() => _rxAlerts = v),
                          ),
                          const Divider(
                            color: AppColors.surfaceContainerLow,
                            height: 1,
                          ),
                          _buildSwitchTile(
                            icon: Symbols.dentistry,
                            title: '6 Aylık Periyodik Diş Taşı & Kontrol',
                            subtitle:
                                'Rutin diş hekimi muayene zamanı geldiğinde',
                            value: _checkupReminder,
                            onChanged: (v) =>
                                setState(() => _checkupReminder = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 3. HESAP, GÜVENLİK & KLİNİK BİLGİLERİ
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'HESAP & GÜVENLİK',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildMenuRow(
                            icon: Symbols.badge,
                            title: 'Kişisel & Tıbbi Bilgilerimi Düzenle',
                            subtitle:
                                'Adres, acil durum kişisi ve sistemik hastalıklar',
                            onTap: _showEditProfileModal,
                          ),
                          const Divider(
                            color: AppColors.surfaceContainerLow,
                            height: 1,
                          ),
                          _buildMenuRow(
                            icon: Symbols.lock_reset,
                            title: 'Şifre ve Güvenlik',
                            subtitle: 'Son şifre değişikliği: 3 ay önce',
                            onTap: () => context.push('/forgot-password'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 4. UYGULAMA & YASAL
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'KLİNİK & YASAL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: _buildMenuRow(
                        icon: Symbols.policy,
                        title: 'KVKK Aydınlatma Metni & Hasta Hakları',
                        subtitle:
                            'Kişisel sağlık verilerinin korunması izinleri',
                        onTap: _showKvkkDialog,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. LOGOUT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          backgroundColor: AppColors.errorContainer.withValues(
                            alpha: 0.4,
                          ),
                          side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Symbols.logout, size: 20),
                        label: const Text(
                          'Güvenli Çıkış Yap',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Dentora Clinical Mobile • Versiyon 2.4.0 (Build 108)',
                        style: TextStyle(
                          fontSize: 11,
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
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trailingText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSecondaryFixed,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(
              Symbols.chevron_right,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileModal() {
    final phoneController = TextEditingController(text: _phone);
    final emailController = TextEditingController(text: _email);
    final bloodController = TextEditingController(text: _bloodType);
    final allergyController = TextEditingController(text: _allergy);
    final addressController = TextEditingController(text: _address);
    final emergencyController = TextEditingController(text: _emergencyContact);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 16,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bilgilerimi Düzenle',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kişisel ve tıbbi bilgilerinizi güncelleyin',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(
                        Symbols.close,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildModalTextField(
                  label: 'Telefon Numarası',
                  icon: Symbols.call,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildModalTextField(
                  label: 'E-Posta Adresi',
                  icon: Symbols.mail,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildModalTextField(
                        label: 'Kan Grubu',
                        icon: Symbols.bloodtype,
                        controller: bloodController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _buildModalTextField(
                        label: 'Alerjiler / Tıbbi Uyarı',
                        icon: Symbols.warning,
                        controller: allergyController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildModalTextField(
                  label: 'İkamet Adresi',
                  icon: Symbols.home_pin,
                  controller: addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _buildModalTextField(
                  label: 'Acil Durum İletişim Kişisi',
                  icon: Symbols.contact_emergency,
                  controller: emergencyController,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _phone = phoneController.text.trim();
                        _email = emailController.text.trim();
                        _bloodType = bloodController.text.trim();
                        _allergy = allergyController.text.trim();
                        _address = addressController.text.trim();
                        _emergencyContact = emergencyController.text.trim();
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bilgileriniz başarıyla güncellendi.'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Değişiklikleri Kaydet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildModalTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceContainerHigh),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showKvkkDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Symbols.policy, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'KVKK ve Hasta Hakları',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            '6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) uyarınca, Dentora Klinik olarak sağlık verileriniz ve kişisel kimlik bilgileriniz en yüksek güvenlik standartlarında korunmaktadır.\n\nTıbbi geçmişiniz, röntgenleriniz ve reçete kayıtlarınız yalnızca tedavi sürecinizi yürüten hekimleriniz ile paylaşılır. İzniniz olmadan üçüncü şahıslara aktarılmaz.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Anladım',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

