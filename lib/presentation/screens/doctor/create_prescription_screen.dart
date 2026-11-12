import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/prescription_model.dart';
import '../../../data/datasources/clinic_mock_data.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/medical_records/medical_records_cubit.dart';
import '../../widgets/dentora_logo.dart';

class CreatePrescriptionScreen extends StatefulWidget {
  const CreatePrescriptionScreen({super.key});

  @override
  State<CreatePrescriptionScreen> createState() =>
      _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  final TextEditingController _patientSearchController = TextEditingController(
    text: 'Ahmet Arslan',
  );
  late final TextEditingController _doctorNoteController;

  final List<Map<String, String>> _medications = [
    {
      'name': 'Augmentin-BID 1000 mg Film Tablet',
      'barcode': 'Barkod: 8699522090529 • 1 Kutu (14 Tablet)',
      'freq': '2x1',
      'period': '12 Saatte Bir',
      'meal': 'Tok Karnına',
      'days': '7 Gün',
      'type': 'pill',
    },
    {
      'name': 'Arveles 25 mg Film Kaplı Tablet',
      'barcode': 'Barkod: 8699540090422 • 1 Kutu (20 Tablet)',
      'freq': '2x1',
      'period': 'Lüzumu Halinde',
      'meal': 'Tok Karnına',
      'days': '5 Gün',
      'type': 'analgesic',
    },
    {
      'name': 'Kloroben %0.12 Oral Sprey / Gargara',
      'barcode': 'Barkod: 8699578510018 • 1 Adet (200 ml)',
      'freq': '3x1',
      'period': 'Yemek Sonrası',
      'meal': 'Haricen Gargara',
      'days': '7 Gün',
      'type': 'spray',
    },
  ];

  @override
  void initState() {
    super.initState();
    _doctorNoteController = TextEditingController(
      text:
          'Sol alt 1. büyük azı (#36) kanal tedavisi sonrası antibiyotik profilaksisi. İlk 2 saat sıcak yiyecek/içecek tüketilmemeli. Şiddetli ödem veya ağrı durumunda kliniğimizle iletişime geçiniz.',
    );
  }

  @override
  void dispose() {
    _patientSearchController.dispose();
    _doctorNoteController.dispose();
    super.dispose();
  }

  void _addMedication(
    String name,
    String barcode,
    String freq,
    String period,
    String meal,
    String days,
  ) {
    setState(() {
      _medications.add({
        'name': name,
        'barcode': barcode,
        'freq': freq,
        'period': period,
        'meal': meal,
        'days': days,
        'type': 'pill',
      });
    });
  }

  void _appendMacro(String macro) {
    final current = _doctorNoteController.text.trim();
    setState(() {
      _doctorNoteController.text = current.isEmpty ? macro : '$current $macro';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.doctorSurface,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Screen Title & E-Reçete Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'E-REÇETE SİSTEMİ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: AppColors.secondaryDoctor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Reçete Oluştur',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: AppColors.onSurfaceDoctor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.doctorSurfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.doctorSurfaceContainerHigh,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.emeraldOnline,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Medula Aktif',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // SECTION 1: PATIENT SELECTION & SNAPSHOT CARD
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1. HASTA SEÇİMİ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Koltuktaki Hasta Seçili',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Search Bar
                    TextField(
                      controller: _patientSearchController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceDoctor,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Hasta adı veya TC Kimlik No ile arayın...',
                        prefixIcon: const Icon(
                          Symbols.person_search,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => _patientSearchController.clear(),
                          icon: const Icon(
                            Symbols.close,
                            size: 18,
                            color: AppColors.outline,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.doctorSurfaceContainerHigh,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.doctorSurfaceContainerHigh,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Selected Patient Clinical Snapshot Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.asset(
                                        'assets/images/patient_ahmet_rx.png',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Flexible(
                                                child: Text(
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
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .secondaryFixedDoctor,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  '34 Yaş • E',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors
                                                        .onSecondaryFixedVariantDoctor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'TC: 428••••••14 • Protokol: #DN-2603',
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
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Symbols.check_circle,
                                      size: 13,
                                      fill: 1,
                                      color: Color(0xFF047857),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Alerji Yok',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF047857),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                            color: AppColors.doctorSurfaceContainerLow,
                            height: 1,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Symbols.dentistry,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'İşlem: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '#36 Akut Apikal Periodontitis & Kanal',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurfaceDoctor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.doctorSurfaceContainerLow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ICD-10: K04.4',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondaryDoctor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 2: TANI / ICD-10 KODU
                    const Text(
                      '2. TANI & ENDİKASYON (ICD-10)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.doctorSurfaceContainerHigh,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.doctorSurfaceContainerLow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Symbols.medical_information,
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
                                        'K04.0 - Pulpitis & Periapikal Abse',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurfaceDoctor,
                                        ),
                                      ),
                                      Text(
                                        'Cerrahi / Endodontik işlem sonrası profilaksi',
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
                          const Text(
                            'Değiştir',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 3: HIZLI DENTAL İLAÇ ŞABLONLARI
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '3. HIZLI DENTAL İLAÇ ŞABLONLARI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Tek dokunuşla ekle',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPresetPill(
                            label: 'Augmentin 1000mg',
                            onTap: () => _addMedication(
                              'Augmentin-BID 1000 mg Film Tablet',
                              'Barkod: 8699522090529 • 1 Kutu (14 Tablet)',
                              '2x1',
                              '12 Saatte Bir',
                              'Tok Karnına',
                              '7 Gün',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPresetPill(
                            label: 'Apranax Fort 550mg',
                            onTap: () => _addMedication(
                              'Apranax Fort 550 mg Film Tablet',
                              'Barkod: 8699514090052 • 1 Kutu (10 Tablet)',
                              '2x1',
                              '12 Saatte Bir',
                              'Tok Karnına',
                              '5 Gün',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPresetPill(
                            label: 'Klorhex %0.2 Gargara',
                            onTap: () => _addMedication(
                              'Klorhex %0.2 Antiseptik Gargara',
                              'Barkod: 8699578510025 • 1 Adet (200 ml)',
                              '3x1',
                              '8 Saatte Bir',
                              'Haricen Gargara',
                              '7 Gün',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 4: REÇETEDEKİ İLAÇLAR & DOZAJ PLANI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '4. EKLENEN İLAÇLAR & DOZAJ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${_medications.length} Kalem',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_medications.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _medications.clear()),
                            child: const Text(
                              'Tümünü Temizle',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    for (int i = 0; i < _medications.length; i++) ...[
                      _buildMedicationItemCard(i, _medications[i]),
                      const SizedBox(height: 10),
                    ],

                    // Manual Medication Add Button
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _addMedication(
                        'Parol 500 mg Tablet',
                        'Barkod: 8699525010018 • 1 Kutu (20 Tablet)',
                        '3x1',
                        '8 Saatte Bir',
                        'Tok Karnına',
                        '5 Gün',
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.doctorSurfaceContainerLow.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Symbols.add_circle,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'İlaç Rehberinden Yeni İlaç Ekle',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 5: HEKİM NOTU & KULLANIM TALİMATI
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        const Text(
                          '5. HEKİM NOTU & KULLANIM TALİMATI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMacroChip(
                              '+ Sıcak/Soğuk Uyarısı',
                              'Sıcak yiyecek ve içeceklerden 24 saat kaçınılmalıdır.',
                            ),
                            const SizedBox(width: 6),
                            _buildMacroChip(
                              '+ Buz Kompresi',
                              'Operasyon bölgesine dışarıdan 10 dk aralıklarla buz kompresi uygulanmalıdır.',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.doctorSurfaceContainerHigh,
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _doctorNoteController,
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: AppColors.onSurfaceDoctor,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                          const Divider(
                            color: AppColors.doctorSurfaceContainerLow,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Symbols.sms,
                                      size: 15,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        'Hasta SMS bilgilendirmesine dahil edilir',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'E-İmza Hazır',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SECTION 6: E-REÇETE ÖZET & ONAY KARTI
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.doctorSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.doctorSurfaceContainerHigh,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Symbols.verified_user,
                              size: 20,
                              fill: 1,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sağlık Bakanlığı Renkli Reçete & Medula Onayı',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurfaceDoctor,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Reçete onaylandığında hastanın cep telefonuna 8 haneli E-Reçete kodu gönderilir.',
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
                    const SizedBox(height: 18),

                    // Primary Submit Button
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
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final patientName = _patientSearchController.text.trim();
                            if (patientName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Lütfen geçerli bir hasta seçimi yapınız.'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              return;
                            }

                            if (_medications.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Reçeteye en az 1 ilaç kalemi eklenmelidir.'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              return;
                            }

                            final medicines = _medications.map((m) => MedicineItem(
                              name: m['name'] ?? '',
                              dosage: m['barcode'] ?? '',
                              frequency: m['freq'] ?? '1x1',
                              duration: m['days'] ?? '5 Gün',
                              instructions: m['meal'] ?? 'Tok karnına',
                            )).toList();

                            final doctorUser = context.read<AuthCubit>().state.user;
                            final doctorId = doctorUser?.id ?? ClinicMockData.sampleDoctor.id;
                            final doctorName = doctorUser?.fullName ?? ClinicMockData.sampleDoctor.fullName;
                            final rxId = 'ERX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

                            final prescription = PrescriptionModel(
                              id: rxId,
                              patientId: ClinicMockData.samplePatient.id,
                              patientName: patientName,
                              doctorId: doctorId,
                              doctorName: doctorName,
                              diagnosis: 'K04.0 Pulpitis - Akut Apikal Periodontitis',
                              medicines: medicines,
                              doctorNote: _doctorNoteController.text.trim(),
                              isApproved: true,
                              createdAt: DateTime.now(),
                            );

                            final cubit = context.read<MedicalRecordsCubit>();
                            await cubit.createPrescription(prescription);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'E-Reçete (#$rxId) başarıyla onaylandı ve hastaya SMS ile gönderildi!',
                                  ),
                                  backgroundColor: AppColors.emeraldOnline,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Symbols.send,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'E-Reçete Oluştur & SMS ile Gönder',
                            style: TextStyle(
                              fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetPill({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
        ),
        child: Row(
          children: [
            const Icon(Symbols.add_circle, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceDoctor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItemCard(int index, Map<String, String> med) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixedDoctor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Symbols.pill,
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
                            med['name']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceDoctor,
                            ),
                          ),
                          Text(
                            med['barcode']!,
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
              InkWell(
                onTap: () => setState(() => _medications.removeAt(index)),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Symbols.delete,
                    size: 18,
                    color: AppColors.outline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDosageBox('DOZ SIKLIĞI', med['freq']!, med['period']!),
              const SizedBox(width: 6),
              _buildDosageBox('KULLANIM', med['meal']!, 'Ağız Yoluyla'),
              const SizedBox(width: 6),
              _buildDosageBox('TEDAVİ SÜRESİ', med['days']!, 'Tam Kür'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDosageBox(String label, String val, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.doctorSurfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, String textToInsert) {
    return GestureDetector(
      onTap: () => _appendMacro(textToInsert),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.secondaryFixedDoctor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.onSecondaryFixedVariantDoctor,
          ),
        ),
      ),
    );
  }
}
