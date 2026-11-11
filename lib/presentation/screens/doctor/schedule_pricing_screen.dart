import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class SchedulePricingScreen extends StatefulWidget {
  const SchedulePricingScreen({super.key});

  @override
  State<SchedulePricingScreen> createState() => _SchedulePricingScreenState();
}

class _SchedulePricingScreenState extends State<SchedulePricingScreen> {
  bool _isScheduleTab = false;
  int _selectedDayIndex = 0; // Pzt

  final List<Map<String, dynamic>> _procedures = [
    {
      'title': '1. Genel Diş Muayenesi & Konsültasyon',
      'subtitle': 'Süre: 30 dk • Panoramik Röntgen Dahil',
      'icon': Symbols.dentistry,
      'price': 850,
      'active': true,
    },
    {
      'title': '2. Diş Taşı Temizliği (Detartraj & Polisaj)',
      'subtitle': 'Süre: 45 dk • Alt & Üst Çene Ultrasonik',
      'icon': Symbols.clean_hands,
      'price': 2200,
      'active': true,
    },
    {
      'title': '3. Kompozit (Estetik) Diş Dolgusu',
      'subtitle': 'Süre: 45 dk • Tek Yüzlü / Kalan Diş Dokusu',
      'icon': Symbols.healing,
      'price': 2750,
      'active': true,
    },
    {
      'title': '4. Kanal Tedavisi (Endodonti - Tek Kanal)',
      'subtitle': 'Süre: 60 dk • Dijital Apeks Bulucu & Döner Eğe',
      'icon': Symbols.medical_services,
      'price': 4500,
      'active': true,
    },
    {
      'title': '5. Standart Diş Çekimi (Lokal Anestezi)',
      'subtitle': 'Süre: 30 dk • Sütür & Kanama Kontrolü Dahil',
      'icon': Symbols.vaccines,
      'price': 1900,
      'active': true,
    },
    {
      'title': '6. Gömülü 20 Yaş Dişi Cerrahi Çekimi',
      'subtitle': 'Süre: 60 dk • Kemik Retansiyonlu / Cerrahi',
      'icon': Symbols.surgical,
      'price': 5800,
      'active': true,
    },
    {
      'title': '7. Dental İmplant Uygulaması (Titanyum)',
      'subtitle': 'Süre: 60 dk • Tek İmplant Cerrahi Yerleştirme',
      'icon': Symbols.biotech,
      'price': 16500,
      'active': true,
    },
    {
      'title': '8. Zirkonyum Porselen Kron (Tek Üye)',
      'subtitle': 'Süre: 45 dk • CAD/CAM Dijital Tasarım',
      'icon': Symbols.auto_awesome,
      'price': 7200,
      'active': true,
    },
    {
      'title': '9. Ofis Tipi Lazer Diş Beyazlatma (Bleaching)',
      'subtitle': 'Süre: 60 dk • Tek Seans Klinik Uygulama',
      'icon': Symbols.wb_sunny,
      'price': 6400,
      'active': true,
    },
    {
      'title': '10. Şeffaf Plak (Telsiz Ortodonti) Muayenesi',
      'subtitle': 'Süre: 45 dk • 3D Ağız İçi Tarama & Simülasyon',
      'icon': Symbols.sentiment_satisfied,
      'price': 3000,
      'active': true,
    },
    {
      'title': '11. Çocuk Diş (Pedodonti) Fissür Örtücü & Flor',
      'subtitle': 'Süre: 30 dk • Koruyucu Pediatrik Uygulama',
      'icon': Symbols.child_care,
      'price': 1600,
      'active': true,
    },
    {
      'title': '12. Gece Plağı (Bruksizm / Diş Sıkma Apareyi)',
      'subtitle': 'Süre: 30 dk • Kişiye Özel Sert/Yumuşak Plak',
      'icon': Symbols.bedtime,
      'price': 3400,
      'active': true,
    },
  ];

  String _formatPrice(int val) {
    final s = val.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}';
  }

  void _adjustPrice(int index, int delta) {
    setState(() {
      final current = _procedures[index]['price'] as int;
      final next = (current + delta).clamp(100, 99900);
      _procedures[index]['price'] = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _procedures
        .where((element) => element['active'] == true)
        .length;

    return Scaffold(
      backgroundColor: AppColors.doctorSurface,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Tab Switcher
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.doctorSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.doctorSurfaceContainerHigh,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _isScheduleTab = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isScheduleTab
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Symbols.payments,
                                      size: 16,
                                      color: !_isScheduleTab
                                          ? Colors.white
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Fiyatlandırma (12)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: !_isScheduleTab
                                            ? Colors.white
                                            : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _isScheduleTab = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _isScheduleTab
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Symbols.schedule,
                                      size: 16,
                                      color: _isScheduleTab
                                          ? Colors.white
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Çalışma & Mola',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _isScheduleTab
                                            ? Colors.white
                                            : AppColors.onSurfaceVariant,
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

                    // Summary Banner Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F006574),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HASTA RANDEVU EKRANI SENKRONİZE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Tedavi & Hizmet Tarifesi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Burada güncellediğiniz ücretler ve aktiflik durumu hastaların "Randevu Al" ekranına anında yansır.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.35,
                                    color: Colors.white.withValues(alpha: 0.88),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$activeCount',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Aktif İşlem',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Compact Working Hours & Shift Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.doctorSurfaceContainerHigh,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryFixedDoctor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Symbols.calendar_clock,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Haftalık Çalışma & Nöbet',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurfaceDoctor,
                                            ),
                                          ),
                                          Text(
                                            'Pzt - Cum • 30 dk Randevu Periyodu',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Randevuya Açık',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Day Pills
                          Row(
                            children: [
                              for (int i = 0; i < 7; i++) ...[
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedDayIndex = i),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 7,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _selectedDayIndex == i
                                            ? AppColors.primary
                                            : (i == 6
                                                  ? AppColors
                                                        .doctorSurfaceContainerLow
                                                        .withValues(alpha: 0.5)
                                                  : AppColors
                                                        .doctorSurfaceContainerLow),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        const [
                                          'Pzt',
                                          'Sal',
                                          'Çar',
                                          'Per',
                                          'Cum',
                                          'Cmt',
                                          'Paz',
                                        ][i],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _selectedDayIndex == i
                                              ? Colors.white
                                              : (i == 6
                                                    ? AppColors.outline
                                                    : AppColors.primary),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.doctorSurfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'MESAİ SAATLERİ',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '09:00 - 18:00',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurfaceDoctor,
                                            ),
                                          ),
                                          Icon(
                                            Symbols.edit,
                                            size: 15,
                                            color: AppColors.primary,
                                          ),
                                        ],
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
                                    color: AppColors.doctorSurfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ÖĞLE MOLASI',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '12:30 - 13:30',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurfaceDoctor,
                                            ),
                                          ),
                                          Icon(
                                            Symbols.coffee,
                                            size: 15,
                                            color: AppColors.primary,
                                          ),
                                        ],
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
                    const SizedBox(height: 18),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'İşlem & Muayene Ücretleri',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceDoctor,
                                ),
                              ),
                              Text(
                                'Randevu ekranındaki tüm 12 dental işlem kalemi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Türk Dişhekimleri Birliği (TDB) 2026 rehber tarifesi baz alındı.',
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Symbols.restart_alt,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'TDB Baz Al',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 12 Procedure Cards
                    for (int i = 0; i < _procedures.length; i++) ...[
                      _buildProcedureCard(i, _procedures[i]),
                      const SizedBox(height: 10),
                    ],

                    // Info Notice Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.doctorSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.doctorSurfaceContainerHigh,
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Symbols.info,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Belirlediğiniz muayene ve işlem ücretlerine %10 KDV dahildir. Hastalar randevu oluştururken tahmini tedavi bedelini şeffaf olarak görüntüler.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.4,
                                color: AppColors.onSurfaceVariant,
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

            // Sticky Save Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                color: AppColors.doctorSurface.withValues(alpha: 0.96),
                border: const Border(
                  top: BorderSide(color: AppColors.doctorSurfaceContainerHigh),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Tüm 12 işlem ücreti ve çalışma saatleri hasta randevu sisteminde güncellendi!',
                          ),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Symbols.check_circle,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Fiyat & Program Değişikliklerini Kaydet',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureCard(int index, Map<String, dynamic> item) {
    final isActive = item['active'] as bool;
    final price = item['price'] as int;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0B1C30),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.doctorSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceDoctor,
                            ),
                          ),
                          Text(
                            item['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    item['active'] = !isActive;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 22,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: isActive
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.doctorSurfaceContainerLow, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BİRİM İŞLEM ÜCRETİ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  _buildPriceStepBtn('-100', () => _adjustPrice(index, -100)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.doctorSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _formatPrice(price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          '₺',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildPriceStepBtn('+100', () => _adjustPrice(index, 100)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceStepBtn(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.doctorSurfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
