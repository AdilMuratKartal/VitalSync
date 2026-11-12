import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/clinic_mock_data.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/doctor_schedule/doctor_schedule_cubit.dart';
import '../../widgets/dentora_logo.dart';

class SchedulePricingScreen extends StatefulWidget {
  const SchedulePricingScreen({super.key});

  @override
  State<SchedulePricingScreen> createState() => _SchedulePricingScreenState();
}

class _SchedulePricingScreenState extends State<SchedulePricingScreen> {
  bool _isScheduleTab = false;
  int _selectedDayIndex = 0; // Pzt
  int _slotDurationMinutes = 30;
  bool _isProcedureSectionOpen = true;
  final Set<int> _expandedProcedureIndices = {0, 1};

  final List<bool> _workingDays = [true, true, true, true, true, true, false];
  final List<String> _workStartByDay = [
    '09:00',
    '09:00',
    '09:00',
    '09:00',
    '09:00',
    '10:00',
    'Kapalı',
  ];
  final List<String> _workEndByDay = [
    '18:00',
    '18:00',
    '18:00',
    '18:00',
    '18:00',
    '16:00',
    'Kapalı',
  ];
  final List<String> _breakRangeByDay = [
    '12:30 - 13:30',
    '12:30 - 13:30',
    '12:30 - 13:30',
    '12:30 - 13:30',
    '12:30 - 13:30',
    '13:00 - 13:30',
    'Mola Yok',
  ];

  // 'open' = Randevuya Açık, 'break' = Öğle/Klinik Molası, 'closed' = Kapalı Slot
  final Map<String, String> _timeSlots = {
    '09:00': 'open',
    '09:30': 'open',
    '10:00': 'open',
    '10:30': 'open',
    '11:00': 'open',
    '11:30': 'open',
    '12:00': 'open',
    '12:30': 'break',
    '13:00': 'break',
    '13:30': 'open',
    '14:00': 'open',
    '14:30': 'open',
    '15:00': 'open',
    '15:30': 'open',
    '16:00': 'open',
    '16:30': 'open',
    '17:00': 'open',
    '17:30': 'closed',
  };

  final List<Map<String, dynamic>> _procedures = [
    {
      'title': '1. Genel Diş Muayenesi & Konsültasyon',
      'subtitle': 'Süre: 30 dk • Panoramik Röntgen Dahil',
      'category': 'Tanı & Muayene',
      'icon': Symbols.dentistry,
      'price': 850,
      'active': true,
    },
    {
      'title': '2. Diş Taşı Temizliği (Detartraj & Polisaj)',
      'subtitle': 'Süre: 45 dk • Alt & Üst Çene Ultrasonik',
      'category': 'Periodontoloji',
      'icon': Symbols.clean_hands,
      'price': 2200,
      'active': true,
    },
    {
      'title': '3. Kompozit (Estetik) Diş Dolgusu',
      'subtitle': 'Süre: 45 dk • Tek Yüzlü / Kalan Diş Dokusu',
      'category': 'Restoratif',
      'icon': Symbols.healing,
      'price': 2750,
      'active': true,
    },
    {
      'title': '4. Kanal Tedavisi (Endodonti - Tek Kanal)',
      'subtitle': 'Süre: 60 dk • Dijital Apeks Bulucu & Döner Eğe',
      'category': 'Endodonti',
      'icon': Symbols.medical_services,
      'price': 4500,
      'active': true,
    },
    {
      'title': '5. Standart Diş Çekimi (Lokal Anestezi)',
      'subtitle': 'Süre: 30 dk • Sütür & Kanama Kontrolü Dahil',
      'category': 'Cerrahi',
      'icon': Symbols.vaccines,
      'price': 1900,
      'active': true,
    },
    {
      'title': '6. Gömülü 20 Yaş Dişi Cerrahi Çekimi',
      'subtitle': 'Süre: 60 dk • Kemik Retansiyonlu / Cerrahi',
      'category': 'Cerrahi',
      'icon': Symbols.surgical,
      'price': 5800,
      'active': true,
    },
    {
      'title': '7. Dental İmplant Uygulaması (Titanyum)',
      'subtitle': 'Süre: 60 dk • Tek İmplant Cerrahi Yerleştirme',
      'category': 'İmplantoloji',
      'icon': Symbols.biotech,
      'price': 16500,
      'active': true,
    },
    {
      'title': '8. Zirkonyum Porselen Kron (Tek Üye)',
      'subtitle': 'Süre: 45 dk • CAD/CAM Dijital Tasarım',
      'category': 'Protez & Estetik',
      'icon': Symbols.auto_awesome,
      'price': 7200,
      'active': true,
    },
    {
      'title': '9. Ofis Tipi Lazer Diş Beyazlatma (Bleaching)',
      'subtitle': 'Süre: 60 dk • Tek Seans Klinik Uygulama',
      'category': 'Protez & Estetik',
      'icon': Symbols.wb_sunny,
      'price': 6400,
      'active': true,
    },
    {
      'title': '10. Şeffaf Plak (Telsiz Ortodonti) Muayenesi',
      'subtitle': 'Süre: 45 dk • 3D Ağız İçi Tarama & Simülasyon',
      'category': 'Ortodonti',
      'icon': Symbols.sentiment_satisfied,
      'price': 3000,
      'active': true,
    },
    {
      'title': '11. Çocuk Diş (Pedodonti) Fissür Örtücü & Flor',
      'subtitle': 'Süre: 30 dk • Koruyucu Pediatrik Uygulama',
      'category': 'Pedodonti',
      'icon': Symbols.child_care,
      'price': 1600,
      'active': true,
    },
    {
      'title': '12. Gece Plağı (Bruksizm / Diş Sıkma Apareyi)',
      'subtitle': 'Süre: 30 dk • Kişiye Özel Sert/Yumuşak Plak',
      'category': 'Koruyucu Aparey',
      'icon': Symbols.bedtime,
      'price': 3400,
      'active': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorId = context.read<AuthCubit>().state.user?.id ?? ClinicMockData.sampleDoctor.id;
      context.read<DoctorScheduleCubit>().watchDoctorSchedule(doctorId);
    });
  }

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

  void _toggleAllProcedures() {
    setState(() {
      if (_expandedProcedureIndices.length == _procedures.length) {
        _expandedProcedureIndices.clear();
      } else {
        for (int i = 0; i < _procedures.length; i++) {
          _expandedProcedureIndices.add(i);
        }
      }
    });
  }

  void _cycleSlotStatus(String slotKey) {
    setState(() {
      final current = _timeSlots[slotKey] ?? 'open';
      if (current == 'open') {
        _timeSlots[slotKey] = 'break';
      } else if (current == 'break') {
        _timeSlots[slotKey] = 'closed';
      } else {
        _timeSlots[slotKey] = 'open';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _procedures
        .where((element) => element['active'] == true)
        .length;
    final openSlotsCount = _timeSlots.values.where((v) => v == 'open').length;
    final breakSlotsCount = _timeSlots.values.where((v) => v == 'break').length;

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

                    if (!_isScheduleTab)
                      _buildPricingTabContent(activeCount)
                    else
                      _buildScheduleTabContent(
                        openSlotsCount: openSlotsCount,
                        breakSlotsCount: breakSlotsCount,
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
                          content: Text(
                            _isScheduleTab
                                ? 'Çalışma saatleri, mola aralıkları ve randevu slotları güncellendi!'
                                : 'Tüm 12 işlem ücreti hasta randevu sisteminde güncellendi!',
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
                    label: Text(
                      _isScheduleTab
                          ? 'Çalışma & Mola Planını Kaydet'
                          : 'Fiyat Tarifesi Değişikliklerini Kaydet',
                      style: const TextStyle(
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

  Widget _buildPricingTabContent(int activeCount) {
    final allExpanded = _expandedProcedureIndices.length == _procedures.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Banner Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
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
                      'Ücret güncellemeleri hasta ekranına anında yansır.',
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
                      '$activeCount/12',
                      style: const TextStyle(
                        fontSize: 18,
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

        // Collapsible Master Accordion Header for Procedures
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
          ),
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  setState(() {
                    _isProcedureSectionOpen = !_isProcedureSectionOpen;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixedDoctor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Symbols.medical_information,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'İşlem & Muayene Ücretleri',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceDoctor,
                              ),
                            ),
                            Text(
                              _isProcedureSectionOpen
                                  ? '12 işlem kalemi (${_expandedProcedureIndices.length} açık)'
                                  : 'Listeyi görmek için dokunun',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isProcedureSectionOpen
                            ? Symbols.keyboard_arrow_up
                            : Symbols.keyboard_arrow_down,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isProcedureSectionOpen) ...[
                const Divider(
                  height: 1,
                  color: AppColors.doctorSurfaceContainerHigh,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _toggleAllProcedures,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(
                          allExpanded
                              ? Symbols.unfold_less
                              : Symbols.unfold_more,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          allExpanded ? 'Tümünü Daralt' : 'Tümünü Genişlet',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
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
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
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
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Column(
                    children: [
                      for (int i = 0; i < _procedures.length; i++) ...[
                        _buildCollapsibleProcedureTile(i, _procedures[i]),
                        if (i < _procedures.length - 1)
                          const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Info Notice Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.doctorSurfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Symbols.info, size: 18, color: AppColors.primary),
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
    );
  }

  Widget _buildCollapsibleProcedureTile(int index, Map<String, dynamic> item) {
    final isActive = item['active'] as bool;
    final price = item['price'] as int;
    final isExpanded = _expandedProcedureIndices.contains(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isExpanded
            ? AppColors.doctorSurface
            : AppColors.doctorSurfaceContainerLow.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.doctorSurfaceContainerHigh,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedProcedureIndices.remove(index);
                } else {
                  _expandedProcedureIndices.add(index);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.secondaryFixedDoctor
                          : AppColors.doctorSurfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppColors.onSurfaceDoctor
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item['category']} • ${isActive ? "Aktif" : "Pasif"}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.doctorSurfaceContainerHigh,
                      ),
                    ),
                    child: Text(
                      '${_formatPrice(price)} ₺',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? Symbols.expand_less : Symbols.expand_more,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(
              height: 1,
              color: AppColors.doctorSurfaceContainerHigh,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            isActive ? 'Randevuya Açık' : 'Pasif',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
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
                    ],
                  ),
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
                          _buildPriceStepBtn(
                            '-100',
                            () => _adjustPrice(index, -100),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.doctorSurfaceContainerHigh,
                              ),
                            ),
                            child: Text(
                              '${_formatPrice(price)} ₺',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildPriceStepBtn(
                            '+100',
                            () => _adjustPrice(index, 100),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleTabContent({
    required int openSlotsCount,
    required int breakSlotsCount,
  }) {
    const dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    const fullDayNames = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    final isSelectedDayOpen = _workingDays[_selectedDayIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Schedule Banner Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0B1C30), AppColors.primary],
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
                      'DİNAMİK TAKVİM & MOLA YÖNETİMİ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Çalışma Saatleri & Molalar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Günlük çalışma saatlerinizi, öğle molanızı ve hastaların seçebileceği açık randevu slotlarını yönetin.',
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
                      '$openSlotsCount',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Açık Slot',
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

        // Weekly Working Days & Shift Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${fullDayNames[_selectedDayIndex]} Mesai Planı',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceDoctor,
                                ),
                              ),
                              Text(
                                ' $_slotDurationMinutes dk Randevu Periyodu • $breakSlotsCount Mola Slotu',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _workingDays[_selectedDayIndex] =
                            !_workingDays[_selectedDayIndex];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelectedDayOpen
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isSelectedDayOpen ? 'Mesai Açık' : 'Tatil / Kapalı',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isSelectedDayOpen
                              ? const Color(0xFF047857)
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Day Pills
              Row(
                children: [
                  for (int i = 0; i < 7; i++) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDayIndex = i),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedDayIndex == i
                                ? AppColors.primary
                                : (_workingDays[i]
                                      ? AppColors.doctorSurfaceContainerLow
                                      : AppColors.doctorSurfaceContainerLow
                                            .withValues(alpha: 0.45)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dayNames[i],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedDayIndex == i
                                      ? Colors.white
                                      : (_workingDays[i]
                                            ? AppColors.primary
                                            : AppColors.outline),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedDayIndex == i
                                      ? Colors.white
                                      : (_workingDays[i]
                                            ? const Color(0xFF10B981)
                                            : AppColors.outlineVariant),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Working hours & Lunch break interactive boxes
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          final current = _workStartByDay[_selectedDayIndex];
                          _workStartByDay[_selectedDayIndex] =
                              current == '09:00' ? '08:30' : '09:00';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.doctorSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MESAİ SAATLERİ',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isSelectedDayOpen
                                      ? '${_workStartByDay[_selectedDayIndex]} - ${_workEndByDay[_selectedDayIndex]}'
                                      : 'Tam Gün Kapalı',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurfaceDoctor,
                                  ),
                                ),
                                const Icon(
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
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          final current = _breakRangeByDay[_selectedDayIndex];
                          _breakRangeByDay[_selectedDayIndex] =
                              current == '12:30 - 13:30'
                              ? '12:00 - 13:00'
                              : '12:30 - 13:30';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.doctorSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ÖĞLE MOLASI',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isSelectedDayOpen
                                      ? _breakRangeByDay[_selectedDayIndex]
                                      : 'Mola Yok',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurfaceDoctor,
                                  ),
                                ),
                                const Icon(
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
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Slot duration selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Randevu Periyodu:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceDoctor,
                      ),
                    ),
                  ),
                  Row(
                    children: [30, 45, 60].map((mins) {
                      final selected = _slotDurationMinutes == mins;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _slotDurationMinutes = mins),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.doctorSurfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$mins dk',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : AppColors.onSurfaceDoctor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Interactive Time Slots & Break Grid Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Günlük Saat Dilimleri & Mola Düzeni',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceDoctor,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Bir saate dokunarak durumunu (Açık → Mola → Kapalı) değiştirebilirsiniz.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.entries.map((entry) {
                  final status = entry.value;
                  Color bg;
                  Color fg;
                  IconData icon;
                  String statusLabel;

                  if (status == 'open') {
                    bg = const Color(0xFFECFDF5);
                    fg = const Color(0xFF047857);
                    icon = Symbols.check_circle;
                    statusLabel = 'Açık';
                  } else if (status == 'break') {
                    bg = const Color(0xFFFFFBEB);
                    fg = const Color(0xFFB45309);
                    icon = Symbols.coffee;
                    statusLabel = 'Mola';
                  } else {
                    bg = AppColors.doctorSurfaceContainerLow;
                    fg = AppColors.onSurfaceVariant;
                    icon = Symbols.block;
                    statusLabel = 'Kapalı';
                  }

                  return GestureDetector(
                    onTap: () => _cycleSlotStatus(entry.key),
                    child: Container(
                      width: 98,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: fg.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: fg,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, size: 12, color: fg),
                              const SizedBox(width: 3),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: fg,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
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
