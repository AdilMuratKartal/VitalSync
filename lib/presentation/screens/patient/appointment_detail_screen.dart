import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/appointment_reschedule_sheet.dart';
import '../../widgets/dentora_logo.dart';

/// Hasta Randevu Detay ve Hazırlık Ekranı.
/// Aktif, geçmiş ve iptal edilen randevular için dinamik durum ve detayları sunar.
class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;
  final Map<String, dynamic>? initialData;

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
    this.initialData,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Map<String, dynamic> _data;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.initialData ?? {});
    _resolveAppointmentData();
  }

  void _resolveAppointmentData() async {
    // Eğer temel veriler zaten verilmişse başlangıçta kullan
    if (_data.isEmpty) {
      _data = _getFallbackAppointmentById(widget.appointmentId);
    }

    // Firestore'da güncel bir kayıt varsa oku
    if (widget.appointmentId.isNotEmpty &&
        ServiceLocator.isRegistered<FirestoreService>()) {
      setState(() => _isLoading = true);
      try {
        final firestoreService = ServiceLocator.get<FirestoreService>();
        final doc =
            await firestoreService.getAppointment(widget.appointmentId);
        if (doc != null && mounted) {
          setState(() {
            _data = {
              ..._data,
              ...doc,
              'id': doc['id'] ?? widget.appointmentId,
              'title': doc['serviceName'] ?? _data['title'],
              'date': doc['date'] ?? _data['date'],
              'time': doc['time'] ?? _data['time'],
              'price': doc['price'] != null ? '${doc['price']} ₺' : _data['price'],
              'status': doc['status'] ?? _data['status'],
              'doctor': doc['doctorName'] ?? _data['doctor'] ?? _data['subtitle'],
            };
          });
        }
      } catch (_) {
        // Fallback to memory data
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Map<String, dynamic> _getFallbackAppointmentById(String id) {
    const defaultCatalog = <String, Map<String, dynamic>>{
      'apt-up-1': {
        'id': 'apt-up-1',
        'title': 'Kanal Tedavisi & Kompozit Dolgu',
        'subtitle': 'Uzm. Dt. Selin Yılmaz • Endodonti Kliniği (Oda 3)',
        'doctor': 'Uzm. Dt. Selin Yılmaz',
        'specialty': 'Ağız, Diş ve Çene Cerrahisi & Endodonti',
        'doctorAvatar': 'assets/images/dr_selin_home.png',
        'room': 'Poliklinik 3 • Kat 2',
        'date': '19 Mart 2026, Per',
        'time': '14:30 - 15:15',
        'price': '3.200 ₺',
        'status': 'upcoming',
        'badgeText': 'Planlandı • Yaklaşan',
        'prescriptionId': 'rec-89412',
        'prescriptionCode': '#REC-2026-89412',
      },
      'apt-up-2': {
        'id': 'apt-up-2',
        'title': 'Ultrasonik Diş Taşı Temizliği (Detartraj)',
        'subtitle': 'Dt. Emre Karahan • Periodontoloji (Oda 1)',
        'doctor': 'Dt. Emre Karahan',
        'specialty': 'Periodontoloji & Diş Eti Hastalıkları',
        'doctorAvatar': 'assets/images/avatar_profile_header.png',
        'room': 'Poliklinik 1 • Zemin Kat',
        'date': '21 Mart 2026, Cmt',
        'time': '10:00 - 10:30',
        'price': '1.450 ₺',
        'status': 'upcoming',
        'badgeText': 'Onaylandı',
      },
      'apt-past-1': {
        'id': 'apt-past-1',
        'title': 'Alt Çene İmplant Cerrahisi (1. Aşama)',
        'doctor': 'Prof. Dr. Kerem Aydın • Çene Cerrahisi',
        'specialty': 'Ağız, Diş ve Çene Cerrahisi Anabilim Dalı',
        'doctorAvatar': 'assets/images/avatar_profile_header.png',
        'room': 'Ameliyathane A • Kat 3',
        'date': '12 Şubat 2026',
        'time': '11:00 - 12:15',
        'price': '14.500 ₺',
        'status': 'completed',
        'badgeText': 'Tamamlandı',
        'prescriptionId': 'rec-44109',
        'prescriptionCode': '#REC-2025-44109',
      },
      'apt-past-2': {
        'id': 'apt-past-2',
        'title': 'Panoramik & 3D Dental Tomografi',
        'doctor': 'Uzm. Dt. Selin Yılmaz • Radyoloji Birimi',
        'specialty': 'Ağız ve Çene Radyolojisi',
        'doctorAvatar': 'assets/images/dr_selin_home.png',
        'room': 'Radyoloji Ünitesi • Kat -1',
        'date': '05 Ocak 2026',
        'time': '15:45 - 16:15',
        'price': '950 ₺',
        'status': 'completed',
        'badgeText': 'Tamamlandı',
      },
      'apt-past-3': {
        'id': 'apt-past-3',
        'title': 'Kompozit Estetik Dolgu (26 Nolu Diş)',
        'doctor': 'Dt. Emre Karahan • Restoratif Diş Tedavisi',
        'specialty': 'Restoratif Diş Tedavisi',
        'doctorAvatar': 'assets/images/avatar_profile_header.png',
        'room': 'Poliklinik 2 • Kat 1',
        'date': '18 Kasım 2025',
        'time': '10:15 - 11:00',
        'price': '2.100 ₺',
        'status': 'completed',
        'badgeText': 'Tamamlandı',
      },
      'apt-past-4': {
        'id': 'apt-past-4',
        'title': 'Yıllık Genel Muayene & Flor Uygulaması',
        'doctor': 'Uzm. Dt. Selin Yılmaz • Klinik 2',
        'specialty': 'Genel Diş Hekimliği & Koruyucu Tedavi',
        'doctorAvatar': 'assets/images/dr_selin_home.png',
        'room': 'Poliklinik 2 • Kat 1',
        'date': '02 Eylül 2025',
        'time': '16:00 - 16:30',
        'price': '800 ₺',
        'status': 'completed',
        'badgeText': 'Tamamlandı',
      },
    };

    return defaultCatalog[id] ??
        {
          'id': id,
          'title': 'Klinik Diş Randevusu',
          'doctor': 'Dt. Selin Yılmaz',
          'specialty': 'Ağız ve Diş Sağlığı Kliniği',
          'doctorAvatar': 'assets/images/dr_selin_home.png',
          'room': 'Poliklinik 3 • Kat 2',
          'date': 'Planlanan Tarih',
          'time': 'Saat Belirtilmedi',
          'price': 'Standart Tarife',
          'status': 'upcoming',
          'badgeText': 'Planlandı',
        };
  }

  bool get _isPast {
    final s = (_data['status'] ?? '').toString().toLowerCase();
    return s == 'past' || s == 'completed' || s == 'tamamlandı';
  }

  bool get _isCancelled {
    final s = (_data['status'] ?? '').toString().toLowerCase();
    return s == 'cancelled' || s == 'iptal' || s == 'iptal edildi';
  }

  void _openRescheduleModal() {
    AppointmentRescheduleSheet.show(
      context: context,
      appointment: _data,
      onRescheduled: (newDateDisplay, newTime, newIsoDate) {
        setState(() {
          _data['date'] = newDateDisplay;
          _data['time'] = newTime;
          _data['status'] = 'upcoming';
          _data['badgeText'] = 'Ertelendi • Planlandı';
        });
      },
    );
  }

  Future<void> _cancelAppointment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Symbols.event_busy, color: AppColors.error),
            SizedBox(width: 8),
            Text(
              'Randevuyu İptal Et',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'Bu randevuyu iptal etmek istediğinizden emin misiniz? Randevu geçmiş kayıtlarınızda saklanacaktır.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Evet, İptal Et'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final aptId = _data['id']?.toString() ?? widget.appointmentId;
    try {
      if (ServiceLocator.isRegistered<FirestoreService>() &&
          aptId.isNotEmpty) {
        final firestoreService = ServiceLocator.get<FirestoreService>();
        await firestoreService.updateAppointmentStatus(aptId, 'cancelled');
      }
    } catch (_) {
      // Local fallback
    }

    if (!mounted) return;

    setState(() {
      _data['status'] = 'cancelled';
      _data['badgeText'] = 'İptal Edildi';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevunuz iptal edildi ve geçmişe taşındı.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _data['title']?.toString() ?? 'Kanal Tedavisi';
    final doctor = _data['doctor']?.toString() ??
        _data['subtitle']?.toString() ??
        'Dt. Selin Yılmaz';
    final specialty = _data['specialty']?.toString() ??
        'Ağız, Diş ve Çene Cerrahisi';
    final doctorAvatar = _data['doctorAvatar']?.toString() ??
        'assets/images/dr_selin_home.png';
    final room = _data['room']?.toString() ?? 'Poliklinik 3 • Kat 2';
    final date = _data['date']?.toString() ?? '24 Ekim 2026';
    final time = _data['time']?.toString() ?? '14:30';
    final price = _data['price']?.toString() ?? '3.200 ₺';
    final rawRxId = _data['prescriptionId']?.toString().trim();
    final hasValidRxId = rawRxId != null &&
        rawRxId.isNotEmpty &&
        rawRxId.toLowerCase() != 'null';
    final prescriptionId = hasValidRxId ? rawRxId : null;
    final rawRxCode = _data['prescriptionCode']?.toString().trim();
    final prescriptionCode = (rawRxCode != null &&
            rawRxCode.isNotEmpty &&
            rawRxCode.toLowerCase() != 'null')
        ? rawRxCode
        : (prescriptionId != null ? '#REC-${prescriptionId.toUpperCase()}' : '');

    Color statusBg;
    Color statusFg;
    String statusText;

    if (_isCancelled) {
      statusBg = AppColors.errorContainer;
      statusFg = AppColors.error;
      statusText = 'İptal Edildi';
    } else if (_isPast) {
      statusBg = AppColors.surfaceContainerLow;
      statusFg = AppColors.onSurfaceVariant;
      statusText = 'Tamamlandı';
    } else {
      statusBg = AppColors.secondaryFixed;
      statusFg = AppColors.onSecondaryFixed;
      statusText = _data['badgeText']?.toString() ?? 'Planlandı • Onaylı';
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PatientTopAppBar(
              showBackButton: true,
              subtitle: 'Randevu Detayı',
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. STATUS BADGE & PRICE HEADER
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.surfaceContainerHigh,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D131B2E),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _isCancelled
                                                  ? Symbols.cancel
                                                : (_isPast
                                                    ? Symbols.check_circle
                                                    : Symbols.schedule),
                                            size: 13,
                                            color: statusFg,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: statusFg,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    price,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _isCancelled
                                            ? AppColors.onSurfaceVariant
                                            : AppColors.primary,
                                        decoration: _isCancelled
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Symbols.meeting_room,
                                      size: 15,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        room,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. DATE & TIME HIGHLIGHT CARD
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.surfaceContainerHigh,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Symbols.event_upcoming,
                                    size: 24,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'RANDEVU ZAMANI',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurfaceVariant,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        date,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'Saat: $time',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3. DOCTOR PROFILE CARD
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.surfaceContainerHigh,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    doctorAvatar,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 52,
                                      height: 52,
                                      color: AppColors.surfaceContainerLow,
                                      child: const Icon(
                                        Symbols.person,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        specialty,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      context.push('/patient/chat'),
                                  tooltip: 'Hekime Mesaj Gönder',
                                  icon: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondaryFixed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Symbols.chat_bubble,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 4. PREPARATION INSTRUCTIONS (GEREKLİ HAZIRLIK BİLGİLERİ)
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'GEREKLİ HAZIRLIK BİLGİLERİ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.surfaceContainerHigh,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildPrepItem(
                                  icon: Symbols.restaurant,
                                  title: 'Beslenme & Randevu Öncesi Yemek',
                                  desc:
                                      'Lokal anestezi uygulanacağı için işlemden 1-2 saat önce hafif bir şeyler atıştırınız. Randevu sonrası 2 saat boyunca çiğneme yapılmamalıdır.',
                                ),
                                const Divider(
                                  color: AppColors.surfaceContainerLow,
                                  height: 20,
                                ),
                                _buildPrepItem(
                                  icon: Symbols.medication,
                                  title: 'Düzenli İlaç Kullanımı & Uyarı',
                                  desc:
                                      'Tansiyon veya şeker ilaçlarınızı aksatmayınız. Kan sulandırıcı (Aspirin vb.) kullanıyorsanız hekiminizi önceden bilgilendiriniz.',
                                ),
                                const Divider(
                                  color: AppColors.surfaceContainerLow,
                                  height: 20,
                                ),
                                _buildPrepItem(
                                  icon: Symbols.dentistry,
                                  title: 'Ağız Hijyeni & Hazırlık',
                                  desc:
                                      'Kliniğimize gelmeden önce dişlerinizi fırçalayınız ve antiseptik gargaranızı uygulayınız.',
                                ),
                                const Divider(
                                  color: AppColors.surfaceContainerLow,
                                  height: 20,
                                ),
                                _buildPrepItem(
                                  icon: Symbols.clinical_notes,
                                  title: 'Röntgen & Önceki Tetkikler',
                                  desc:
                                      'Varsa son 6 ay içinde çekilmiş panoramik röntgen veya tomografi sonuçlarınızı yanınızda bulundurunuz.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 5. LINKED PRESCRIPTION CARD (IF APPLICABLE)
                          if (prescriptionId != null) ...[
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'İLİŞKİLİ E-REÇETE BİLGİSİ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryFixed,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Symbols.receipt_long,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prescriptionCode,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Tedavi Reçetesi & İlaç Dozajı',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (prescriptionId.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Bu randevuya ait tanımlanmış bir e-reçete bulunamadı.',
                                            ),
                                            behavior:
                                                SnackBarBehavior.floating,
                                            backgroundColor:
                                                AppColors.primary,
                                          ),
                                        );
                                        return;
                                      }
                                      context.go(
                                        '/patient/results?prescriptionId=$prescriptionId',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Symbols.visibility,
                                      size: 15,
                                    ),
                                    label: const Text(
                                      'Özeti Gör',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 6. ACTION BUTTONS (Dinamik: Aktif vs Geçmiş)
                          if (!_isPast && !_isCancelled) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _openRescheduleModal,
                                    icon: const Icon(
                                      Symbols.edit_calendar,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Randevuyu Ertele',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: _cancelAppointment,
                                  icon: const Icon(
                                    Symbols.cancel,
                                    size: 18,
                                  ),
                                  label: const Text('İptal Et'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    backgroundColor: AppColors.errorContainer
                                        .withValues(alpha: 0.35),
                                    side: BorderSide.none,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (_isPast) ...[
                            // Geçmiş randevularda erteleme/iptal gösterilmez, sonuçlara yönlendirilir
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    context.go('/patient/results'),
                                icon: const Icon(
                                  Symbols.lab_profile,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Sonuçlarım & E-Reçetelerim',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ] else if (_isCancelled) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Symbols.info,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Bu randevu iptal edilmiş olup arşiv kayıtlarınızda tutulmaktadır.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    context.push('/patient/book'),
                                icon: const Icon(Symbols.add, size: 18),
                                label: const Text('Yeni Randevu Al'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrepItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
