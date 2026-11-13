import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../core/theme/app_colors.dart';

/// Hekim Bildirimler Paneli
void showDoctorNotificationsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      height: MediaQuery.of(ctx).size.height * 0.72,
      decoration: const BoxDecoration(
        color: AppColors.doctorSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Symbols.notifications_active, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Klinik Bildirimleri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceDoctor,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Tüm bildirimler okundu olarak işaretlendi.'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: const Text('Tümünü Oku', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.doctorSurfaceContainerHigh),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNotificationItem(
                  icon: Symbols.emergency,
                  iconColor: AppColors.error,
                  iconBg: const Color(0xFFFEE2E2),
                  title: 'Acil Ağrı Bildirimi',
                  patient: 'Ahmet Arslan',
                  message: 'Dün yapılan #46 implant sonrası hafif şişlik ve sızı olduğunu iletti.',
                  time: '10 dk önce',
                  isUnread: true,
                ),
                const SizedBox(height: 10),
                _buildNotificationItem(
                  icon: Symbols.calendar_month,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.secondaryFixedDoctor,
                  title: 'Randevu Teyidi',
                  patient: 'Canan Demir',
                  message: 'Yarın saat 14:30 Zirkonyum Kaplama Prova randevusunu onayladı.',
                  time: '25 dk önce',
                  isUnread: true,
                ),
                const SizedBox(height: 10),
                _buildNotificationItem(
                  icon: Symbols.radiology,
                  iconColor: const Color(0xFF0284C7),
                  iconBg: const Color(0xFFE0F2FE),
                  title: 'Radyoloji Sonucu Yüklendi',
                  patient: 'Zeynep Kaya',
                  message: 'Kanal tedavisi öncesi kontrol panoramik röntgen sisteme yüklendi.',
                  time: '1 saat önce',
                  isUnread: false,
                ),
                const SizedBox(height: 10),
                _buildNotificationItem(
                  icon: Symbols.prescriptions,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFD1FAE5),
                  title: 'Reçete Karşılandı',
                  patient: 'Burak Yılmaz',
                  message: 'Yazılan antibiyotik ve gargara eczane tarafından hastaya teslim edildi.',
                  time: '3 saat önce',
                  isUnread: false,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildNotificationItem({
  required IconData icon,
  required Color iconColor,
  required Color iconBg,
  required String title,
  required String patient,
  required String message,
  required String time,
  required bool isUnread,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isUnread ? Colors.white : AppColors.doctorSurfaceContainerLow.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isUnread ? AppColors.primary.withValues(alpha: 0.3) : AppColors.doctorSurfaceContainerHigh,
      ),
      boxShadow: isUnread
          ? const [BoxShadow(color: Color(0x080B1C30), blurRadius: 10, offset: Offset(0, 4))]
          : null,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isUnread ? AppColors.primary : AppColors.onSurfaceDoctor,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Hasta: $patient',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceDoctor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Doktor Profili Modalı
void showDoctorProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      height: MediaQuery.of(ctx).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.doctorSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hekim Profili',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceDoctor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Symbols.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.doctorSurfaceContainerHigh),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 2.5),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/dr_selin_home.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.emeraldOnline,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Symbols.verified, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dr. Selin Yılmaz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceDoctor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixedDoctor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Ağız, Diş ve Çene Cerrahisi Uzmanı',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSecondaryFixedVariantDoctor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
                    ),
                    child: const Column(
                      children: [
                        _ProfileInfoRow(label: 'Diploma / Tescil No', value: '#34-DNT-89421'),
                        Divider(height: 20),
                        _ProfileInfoRow(label: 'Klinik / Kurum', value: 'Dentora Diş Sağlığı Kliniği'),
                        Divider(height: 20),
                        _ProfileInfoRow(label: 'E-Posta', value: 'selin.yilmaz@dentora.com'),
                        Divider(height: 20),
                        _ProfileInfoRow(label: 'Telefon', value: '0 (533) 900 10 20'),
                        Divider(height: 20),
                        _ProfileInfoRow(label: 'Çalışma Üniti', value: 'Cerrahi Ünit 1'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Toplam Hasta', style: TextStyle(fontSize: 11, color: Color(0xFF166534))),
                              SizedBox(height: 4),
                              Text('1.420+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixedDoctor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.secondaryFixedDoctor),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Başarılı Cerrahi', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                              SizedBox(height: 4),
                              Text('860+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceDoctor)),
      ],
    );
  }
}

/// Doktor / Klinik Ayarları Modalı
void showDoctorSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        bool autoConfirm = true;
        bool smsAlerts = true;
        bool emergencyAlerts = true;

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.70,
          decoration: const BoxDecoration(
            color: AppColors.doctorSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Klinik & Hekim Ayarları',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceDoctor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Symbols.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.doctorSurfaceContainerHigh),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RANDEVU & SEANS POLİTİKASI',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.secondaryDoctor),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Varsayılan Randevu Süresi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('45 Dakika', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                          const Divider(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Maksimum Günlük Hasta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('12 Hasta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                          const Divider(height: 20),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Otomatik Randevu Onayı', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: const Text('Müsait seanslarda beklemeden onayla', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            value: autoConfirm,
                            activeThumbColor: AppColors.primary,
                            onChanged: (v) => setSheetState(() => autoConfirm = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BİLDİRİM & ACİL DURUM HESABI',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.secondaryDoctor),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Anlık Randevu SMS Bildirimleri', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            value: smsAlerts,
                            activeThumbColor: AppColors.primary,
                            onChanged: (v) => setSheetState(() => smsAlerts = v),
                          ),
                          const Divider(height: 16),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Acil Post-Op Nöbetçi Bildirimi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: const Text('Cerrahi hastalarının acil durum çağrıları', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            value: emergencyAlerts,
                            activeThumbColor: AppColors.primary,
                            onChanged: (v) => setSheetState(() => emergencyAlerts = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Klinik ve hekim ayarları başarıyla kaydedildi.'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Symbols.check_circle, size: 18),
                        label: const Text('Ayarları Kaydet', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
