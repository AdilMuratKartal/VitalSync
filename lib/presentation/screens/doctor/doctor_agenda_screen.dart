import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class DoctorAgendaScreen extends StatefulWidget {
  const DoctorAgendaScreen({super.key});

  @override
  State<DoctorAgendaScreen> createState() => _DoctorAgendaScreenState();
}

class _DoctorAgendaScreenState extends State<DoctorAgendaScreen> {
  String _selectedFilter = 'all'; // 'all', 'active', 'waiting', 'completed'
  bool _isEditingAnamnez = false;
  late final TextEditingController _anamnezController;

  @override
  void initState() {
    super.initState();
    _anamnezController = TextEditingController(
      text:
          'Panoramik röntgende kök ucu lezyonu izlendi. Lokal anestezi (Artikain) uygulandı, 3 kanallı ekstirpasyon devam ediyor.',
    );
  }

  @override
  void dispose() {
    _anamnezController.dispose();
    super.dispose();
  }

  void _openQuickNoteSheet() {
    final nameCtrl = TextEditingController(text: 'Ahmet Arslan (11:15)');
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
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
                      'KLİNİK KAYIT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Hızlı Randevu Notu Ekle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceDoctor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Symbols.close),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'HASTA / SAAT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.doctorSurfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'KLİNİK BULGU / NOT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Hastanın şikayeti, yapılan işlem veya kontrol notu...',
                filled: true,
                fillColor: AppColors.doctorSurfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (noteCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _anamnezController.text = noteCtrl.text.trim();
                    });
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Klinik randevu notu hasta dosyasına eklendi.',
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Symbols.save, size: 18),
                label: const Text(
                  'Notu Hasta Dosyasına Kaydet',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCompleted =
        _selectedFilter == 'all' || _selectedFilter == 'completed';
    final showActive = _selectedFilter == 'all' || _selectedFilter == 'active';
    final showWaiting =
        _selectedFilter == 'all' || _selectedFilter == 'waiting';

    return Scaffold(
      backgroundColor: AppColors.doctorSurface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const DoctorTopAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Selector & Summary Stats Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.doctorSurfaceContainerHigh,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D0B1C30),
                                blurRadius: 24,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'GÜNLÜK KLİNİK AJANDASI',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                            color: AppColors.secondaryDoctor,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '18 Mart 2026, Çarşamba',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      AppColors.onSurfaceDoctor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Symbols.expand_more,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      _buildDateBtn(Symbols.chevron_left),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.secondaryFixedDoctor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Bugün',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      _buildDateBtn(Symbols.chevron_right),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // 4 Summary Counter Boxes
                              Row(
                                children: [
                                  _buildCounterBox(
                                    count: '6',
                                    label: 'Toplam',
                                    bg: AppColors.doctorSurfaceContainerLow,
                                    countColor: AppColors.primary,
                                    labelColor: AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildCounterBox(
                                    count: '2',
                                    label: 'Tamamlandı',
                                    bg: const Color(0xFFECFDF5),
                                    countColor: const Color(0xFF047857),
                                    labelColor: const Color(0xFF065F46),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildCounterBox(
                                    count: '1',
                                    label: 'Koltukta',
                                    bg: AppColors.secondaryFixedDoctor
                                        .withValues(alpha: 0.7),
                                    countColor:
                                        AppColors.onSecondaryFixedVariantDoctor,
                                    labelColor:
                                        AppColors.onSecondaryFixedVariantDoctor,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildCounterBox(
                                    count: '3',
                                    label: 'Bekleyen',
                                    bg: const Color(0xFFFFFBEB),
                                    countColor: const Color(0xFFB45309),
                                    labelColor: const Color(0xFF92400E),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('all', 'Tüm Randevular (6)'),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'active',
                                'Aktif / Koltukta (1)',
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip('waiting', 'Bekleyenler (3)'),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'completed',
                                'Tamamlananlar (2)',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // PATIENT 1: COMPLETED (09:00)
                        if (showCompleted) ...[
                          _buildCompletedPatientCard(
                            time: '09:00',
                            duration: '45 dk',
                            name: 'Canan Demir',
                            info: '34 Yaş • Kadın • #HST-1042',
                            procedure: 'Diş Taşı Temizliği (Detartraj)',
                            note: 'Ultrasonik temizlik ve polisaj uygulandı.',
                          ),
                          const SizedBox(height: 12),

                          // PATIENT 2: COMPLETED (10:00)
                          _buildCompletedPatientCard(
                            time: '10:00',
                            duration: '60 dk',
                            name: 'Burak Yılmaz',
                            info: '41 Yaş • Erkek • #HST-0891',
                            procedure: 'Üst Çene İmplant Kontrol & Sütür Alımı',
                            note:
                                'İyileşme başlığı kontrol edildi, enfeksiyon bulgusu yok.',
                          ),
                          const SizedBox(height: 12),
                        ],

                        // PATIENT 3: ACTIVE / IN CHAIR (11:15) - Ahmet Arslan
                        if (showActive) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14006574),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Active Header Banner
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 9,
                                          height: 9,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'ŞU AN KOLTUKTA • ÜNİT 1',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryFixedDoctor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '11:15 - 12:15',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Patient Details + Allergy Alert
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.primaryContainer,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: const Text(
                                              'AA',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Ahmet Arslan',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors
                                                        .onSurfaceDoctor,
                                                  ),
                                                ),
                                                Text(
                                                  '29 Yaş • Erkek • Kan Grubu: A Rh+',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Symbols.warning,
                                            size: 13,
                                            color: AppColors.onErrorContainer,
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'Penisilin Alerjisi',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onErrorContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Procedure & Editable Anamnez Box
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.doctorSurfaceContainerLow,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Symbols.dentistry,
                                                  size: 17,
                                                  color: AppColors.primary,
                                                ),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Sol Alt #36 Kanal Tedavisi (1. Seans)',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .onSurfaceDoctor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            '3.500 ₺',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(
                                        color: AppColors
                                            .doctorSurfaceContainerHigh,
                                        height: 1,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'HEKİM MUAYENE NOTU:',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _isEditingAnamnez =
                                                    !_isEditingAnamnez;
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  _isEditingAnamnez
                                                      ? Symbols.check
                                                      : Symbols.edit_note,
                                                  size: 14,
                                                  color: AppColors.primary,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  _isEditingAnamnez
                                                      ? 'Kaydet'
                                                      : 'Notu Düzenle',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (_isEditingAnamnez)
                                        TextField(
                                          controller: _anamnezController,
                                          maxLines: 2,
                                          style: const TextStyle(fontSize: 12),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        )
                                      else
                                        Text(
                                          _anamnezController.text,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.4,
                                            color: AppColors.onSurfaceDoctor,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Ahmet Arslan muayene seansı tamamlandı olarak işaretlendi.',
                                              ),
                                              backgroundColor:
                                                  AppColors.primary,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 11,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Symbols.task_alt,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Seansı Tamamla',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          context.go('/doctor/prescription'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        backgroundColor:
                                            AppColors.secondaryFixedDoctor,
                                        side: BorderSide.none,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 11,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Symbols.prescriptions,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Reçete Yaz',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // LUNCH BREAK DIVIDER
                        if (_selectedFilter == 'all') ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color:
                                        AppColors.doctorSurfaceContainerHighest,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.doctorSurfaceContainerLow,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Symbols.restaurant,
                                        size: 14,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '12:30 - 13:30 Öğle Molası & Sterilizasyon',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color:
                                        AppColors.doctorSurfaceContainerHighest,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // WAITING PATIENTS (13:30, 14:30, 16:00)
                        if (showWaiting) ...[
                          _buildWaitingPatientCard(
                            time: '13:30',
                            duration: '45 dk',
                            name: 'Zeynep Kaya',
                            info: '25 Yaş • Kadın • İlk Muayene',
                            badgeText: 'Bekleme Salonunda',
                            badgeBg: const Color(0xFFFEF3C7),
                            badgeFg: const Color(0xFF92400E),
                            procedure:
                                'Gülüş Tasarımı & Zirkonyum Ön Değerlendirme',
                            note:
                                'Hasta Notu: "Ön iki dişimdeki ayrıklık ve renk tonu için bilgi almak istiyorum."',
                            primaryBtnLabel: 'Koltuğa Çağır',
                          ),
                          const SizedBox(height: 12),
                          _buildWaitingPatientCard(
                            time: '14:30',
                            duration: '60 dk',
                            name: 'Mehmet Öztürk',
                            info: '52 Yaş • Erkek • Diyabet Takibi',
                            badgeText: 'Onaylandı',
                            badgeBg: AppColors.doctorSurfaceContainer,
                            badgeFg: AppColors.secondaryDoctor,
                            procedure: 'Sağ Alt Gömülü 20 Yaş Dişi Çekimi',
                            note:
                                'Klinik Uyarı: Açlık kan şekeri 115 mg/dL ölçüldü. Antibiyotik profilaksisi başlandı.',
                            primaryBtnLabel: 'Röntgeni Gör',
                          ),
                          const SizedBox(height: 12),
                          _buildWaitingPatientCard(
                            time: '16:00',
                            duration: '30 dk',
                            name: 'Elif Şahin',
                            info: '19 Yaş • Kadın • Ortodonti',
                            badgeText: 'Onaylandı',
                            badgeBg: AppColors.doctorSurfaceContainer,
                            badgeFg: AppColors.secondaryDoctor,
                            procedure: 'Şeffaf Plak (Invisalign) 4. Ay Kontrolü',
                            note:
                                'Plak no #8 teslim edilecek, ataşman kontrolü yapılacak.',
                            primaryBtnLabel: 'Dosyayı Aç',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Quick Note Action Button
            Positioned(
              right: 16,
              bottom: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _openQuickNoteSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(
                    Symbols.add_notes,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Hızlı Randevu Notu Al',
                    style: TextStyle(
                      fontSize: 12,
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
    );
  }

  Widget _buildDateBtn(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.doctorSurfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
    );
  }

  Widget _buildCounterBox({
    required String count,
    required String label,
    required Color bg,
    required Color countColor,
    required Color labelColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: countColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? null
              : Border.all(color: AppColors.doctorSurfaceContainerHigh),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedPatientCard({
    required String time,
    required String duration,
    required String name,
    required String info,
    required String procedure,
    required String note,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Symbols.check,
                    size: 14,
                    color: Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceDoctor,
                          ),
                        ),
                        Text(
                          info,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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
                        'Tamamlandı',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.doctorSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Symbols.dentistry,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              procedure,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceDoctor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Klinik Not: $note',
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
        ],
      ),
    );
  }

  Widget _buildWaitingPatientCard({
    required String time,
    required String duration,
    required String name,
    required String info,
    required String badgeText,
    required Color badgeBg,
    required Color badgeFg,
    required String procedure,
    required String note,
    required String primaryBtnLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0B1C30),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceDoctor,
                  ),
                ),
                Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Symbols.schedule,
                    size: 14,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceDoctor,
                            ),
                          ),
                          Text(
                            info,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.doctorSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        procedure,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceDoctor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        note,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name: $primaryBtnLabel açıldı.'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.doctorSurfaceContainerLow,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          primaryBtnLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _openQuickNoteSheet,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                          backgroundColor: AppColors.doctorSurfaceContainerLow,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Not Ekle',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
