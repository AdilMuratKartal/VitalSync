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
                              Stack(
                                clipBehavior: Clip.none,
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
                                  Positioned(
                                    bottom: -4,
                                    right: -4,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Symbols.photo_camera,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
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
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Symbols.bloodtype,
                                                size: 14,
                                                color: AppColors.primary,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'A Rh+',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Symbols.warning,
                                                size: 14,
                                                color: AppColors.error,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Penisilin Alerjisi',
                                                style: TextStyle(
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
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Symbols.call,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'TELEFON',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              '+90 532 418 90 12',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
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
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Symbols.mail,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'E-POSTA',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              'zeynep.demir@eposta.com',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
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
                          ),
                          const Divider(
                            color: AppColors.surfaceContainerLow,
                            height: 1,
                          ),
                          _buildMenuRow(
                            icon: Symbols.lock_reset,
                            title: 'Şifre ve Giriş Güvenliği',
                            subtitle: 'Son şifre değişikliği: 3 ay önce',
                            trailingText: '2FA Aktif',
                          ),
                          const Divider(
                            color: AppColors.surfaceContainerLow,
                            height: 1,
                          ),
                          _buildMenuRow(
                            icon: Symbols.health_and_safety,
                            title: 'Özel Sağlık Sigortası & Kurum',
                            subtitle:
                                'Allianz Sigorta • Türk Dişhekimleri Birliği (TDB)',
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
  }) {
    return InkWell(
      onTap: () {},
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
}

