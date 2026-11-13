import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/clinic_mock_data.dart';
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
  bool _isSearching = false;

  static final List<Map<String, dynamic>> _patientsList = [
    {
      'name': 'Ahmet Arslan',
      'tc': '428••••••14',
      'fullTc': '42819204914',
      'ageGender': '34 Yaş • E',
      'protocol': '#DN-2603',
      'allergy': 'Alerji Yok',
      'hasAllergy': false,
      'procedure': '#36 Akut Apikal Periodontitis & Kanal',
      'icdCode': 'K04.0 - Pulpitis & Periapikal Abse',
      'icdSub': 'Cerrahi / Endodontik işlem sonrası profilaksi',
      'avatar': 'assets/images/patient_ahmet_rx.png',
    },
    {
      'name': 'Canan Demir',
      'tc': '298••••••19',
      'fullTc': '29810482019',
      'ageGender': '34 Yaş • K',
      'protocol': '#DN-2591',
      'allergy': 'Penisilin Alerjisi',
      'hasAllergy': true,
      'procedure': '#14 Zirkonyum Kaplama Prova',
      'icdCode': 'K02.1 - Dentin Çürüğü & Restorasyon',
      'icdSub': 'Kron hazırlığı ve daimi simantasyon',
      'avatar': 'assets/images/patient_canan_past.png',
    },
    {
      'name': 'Zeynep Kaya',
      'tc': '348••••••29',
      'fullTc': '34891204829',
      'ageGender': '25 Yaş • K',
      'protocol': '#DN-2574',
      'allergy': 'Alerji Yok',
      'hasAllergy': false,
      'procedure': 'Gülüş Tasarımı & Zirkonyum Ön Değerlendirme',
      'icdCode': 'K05.3 - Kronik Periodontitis',
      'icdSub': 'Diş eti tedavisi ve estetik protokol',
      'avatar': 'assets/images/patient_zeynep_chat.png',
    },
    {
      'name': 'Burak Yılmaz',
      'tc': '512••••••12',
      'fullTc': '51290384712',
      'ageGender': '41 Yaş • E',
      'protocol': '#DN-2560',
      'allergy': 'Alerji Yok',
      'hasAllergy': false,
      'procedure': 'Üst Çene İmplant Kontrol & Sütür Alımı',
      'icdCode': 'K08.1 - Diş Kaybı & Osseointegrasyon',
      'icdSub': 'Post-implant cerrahi iyileşme takibi',
      'avatar': 'assets/images/patient_burak_chat.png',
    },
    {
      'name': 'Mehmet Öztürk',
      'tc': '619••••••29',
      'fullTc': '61928471029',
      'ageGender': '52 Yaş • E',
      'protocol': '#DN-2544',
      'allergy': 'Tip 2 Diyabet Takibi',
      'hasAllergy': true,
      'procedure': '#48 Sağ Alt Gömülü 20 Yaş Çekimi',
      'icdCode': 'K01.1 - Gömülü Yirmi Yaş Dişi',
      'icdSub': 'Cerrahi çekim sonrası antibiyotik profilaksisi',
      'avatar': 'assets/images/patient_mehmet_past.png',
    },
  ];

  late Map<String, dynamic> _selectedPatient;

  final List<Map<String, String>> _medications = [
    {
      'name': 'Augmentin-BID 1000 mg Film Tablet',
      'barcode': 'Barkod: 8699522090529 • 1 Kutu (14 Tablet)',
      'freq': '2x1',
      'meal': 'Tok Karnına',
      'days': '7 Gün',
      'type': 'pill',
    },
    {
      'name': 'Arveles 25 mg Film Kaplı Tablet',
      'barcode': 'Barkod: 8699540090422 • 1 Kutu (20 Tablet)',
      'freq': '2x1',
      'meal': 'Tok Karnına',
      'days': '5 Gün',
      'type': 'analgesic',
    },
    {
      'name': 'Kloroben %0.12 Oral Sprey / Gargara',
      'barcode': 'Barkod: 8699578510018 • 1 Adet (200 ml)',
      'freq': '3x1',
      'meal': 'Haricen Gargara',
      'days': '7 Gün',
      'type': 'spray',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPatient = _patientsList.first;
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

  List<Map<String, dynamic>> get _matchingPatients {
    final q = _patientSearchController.text.trim().toLowerCase();
    if (q.isEmpty) return _patientsList;
    return _patientsList.where((p) {
      final name = (p['name'] as String).toLowerCase();
      final tc = (p['fullTc'] as String? ?? '').toLowerCase();
      return name.contains(q) || tc.contains(q);
    }).toList();
  }

  void _addMedication(
    String name,
    String barcode,
    String freq,
    String meal,
    String days,
  ) {
    setState(() {
      _medications.add({
        'name': name,
        'barcode': barcode,
        'freq': freq,
        'meal': meal,
        'days': days,
        'type': 'pill',
      });
    });
  }

  void _showAddMedicationSheet() {
    final catalog = [
      {
        'name': 'Augmentin-BID 1000 mg Film Tablet',
        'barcode': 'Barkod: 8699522090529 • 1 Kutu (14 Tablet)',
        'freq': '2x1',
        'meal': 'Tok Karnına',
        'days': '7 Gün',
        'desc': 'Geniş Spektrumlu Antibiyotik',
      },
      {
        'name': 'Amoklavin-BID 1000 mg Film Tablet',
        'barcode': 'Barkod: 8699546090123 • 1 Kutu (14 Tablet)',
        'freq': '2x1',
        'meal': 'Tok Karnına',
        'days': '7 Gün',
        'desc': 'Amoksisilin + Klavulanik Asit',
      },
      {
        'name': 'Flagyl 500 mg Film Tablet',
        'barcode': 'Barkod: 8699525090102 • 1 Kutu (20 Tablet)',
        'freq': '3x1',
        'meal': 'Tok Karnına',
        'days': '5 Gün',
        'desc': 'Anaerobik Dental Enfeksiyonlar',
      },
      {
        'name': 'Arveles 25 mg Film Kaplı Tablet',
        'barcode': 'Barkod: 8699540090422 • 1 Kutu (20 Tablet)',
        'freq': '2x1',
        'meal': 'Tok Karnına',
        'days': '5 Gün',
        'desc': 'Akut Dental Ağrı & Antienflamatuar',
      },
      {
        'name': 'Apranax Fort 550 mg Film Tablet',
        'barcode': 'Barkod: 8699514090052 • 1 Kutu (10 Tablet)',
        'freq': '2x1',
        'meal': 'Tok Karnına',
        'days': '5 Gün',
        'desc': 'Naproksen Sodyum Güçlü Analjezik',
      },
      {
        'name': 'Parol 500 mg Tablet',
        'barcode': 'Barkod: 8699525010018 • 1 Kutu (20 Tablet)',
        'freq': '3x1',
        'meal': 'Tok Karnına',
        'days': '5 Gün',
        'desc': 'Parasetamol Ağrı Kesici',
      },
      {
        'name': 'Klorhex %0.2 Antiseptik Gargara',
        'barcode': 'Barkod: 8699578510025 • 1 Adet (200 ml)',
        'freq': '3x1',
        'meal': 'Haricen Gargara',
        'days': '7 Gün',
        'desc': 'Klorheksidin Glukonat Ağız Bakımı',
      },
      {
        'name': 'Majezik %0.25 Oral Sprey',
        'barcode': 'Barkod: 8699514510017 • 1 Şişe (30 ml)',
        'freq': '3x1',
        'meal': 'Lokal Püskürtme',
        'days': '7 Gün',
        'desc': 'Flurbiprofen Lokal Antiseptik Sprey',
      },
      {
        'name': 'Buscopan Plus Film Tablet',
        'barcode': 'Barkod: 8699569090116 • 1 Kutu (20 Tablet)',
        'freq': '2x1',
        'meal': 'Tok Karnına',
        'days': '5 Gün',
        'desc': 'Spazmolitik + Parasetamol Kombinasyonu',
      },
    ];

    String filter = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final filtered = catalog
              .where((m) =>
                  m['name']!.toLowerCase().contains(filter.toLowerCase()) ||
                  m['desc']!.toLowerCase().contains(filter.toLowerCase()))
              .toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: const BoxDecoration(
              color: AppColors.doctorSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Symbols.medication, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Klinik İlaç Rehberi',
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (v) => setSheetState(() => filter = v),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'İlaç adı, etken madde veya endikasyon ara...',
                      prefixIcon: const Icon(Symbols.search, size: 18, color: AppColors.outline),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.doctorSurfaceContainerHigh),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final m = filtered[i];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
                          ),
                          child: ListTile(
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixedDoctor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Symbols.pill, color: AppColors.primary, size: 20),
                          ),
                          title: Text(m['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          subtitle: Text('${m['desc']} • ${m['freq']} (${m['meal']})', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          trailing: const Icon(Symbols.add_circle, color: AppColors.primary),
                          onTap: () {
                            Navigator.pop(ctx);
                            _addMedication(m['name']!, m['barcode']!, m['freq']!, m['meal']!, m['days']!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${m['name']} reçeteye eklendi.'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _applyPrescriptionTemplate(String templateName) {
    setState(() {
      _medications.clear();
      if (templateName == 'implant') {
        _medications.addAll([
          {
            'name': 'Augmentin-BID 1000 mg Film Tablet',
            'barcode': 'Barkod: 8699522090529 • 1 Kutu (14 Tablet)',
            'freq': '2x1',
            'meal': 'Tok Karnına',
            'days': '7 Gün',
            'type': 'pill',
          },
          {
            'name': 'Arveles 25 mg Film Kaplı Tablet',
            'barcode': 'Barkod: 8699540090422 • 1 Kutu (20 Tablet)',
            'freq': '2x1',
            'meal': 'Tok Karnına',
            'days': '5 Gün',
            'type': 'analgesic',
          },
          {
            'name': 'Kloroben %0.12 Oral Sprey / Gargara',
            'barcode': 'Barkod: 8699578510018 • 1 Adet (200 ml)',
            'freq': '3x1',
            'meal': 'Haricen Gargara',
            'days': '7 Gün',
            'type': 'spray',
          },
        ]);
      } else if (templateName == 'extraction') {
        _medications.addAll([
          {
            'name': 'Apranax Fort 550 mg Film Tablet',
            'barcode': 'Barkod: 8699514090052 • 1 Kutu (10 Tablet)',
            'freq': '2x1',
            'meal': 'Tok Karnına',
            'days': '5 Gün',
            'type': 'analgesic',
          },
          {
            'name': 'Klorhex %0.2 Antiseptik Gargara',
            'barcode': 'Barkod: 8699578510025 • 1 Adet (200 ml)',
            'freq': '3x1',
            'meal': 'Haricen Gargara',
            'days': '7 Gün',
            'type': 'spray',
          },
        ]);
      } else if (templateName == 'pain') {
        _medications.addAll([
          {
            'name': 'Arveles 25 mg Film Kaplı Tablet',
            'barcode': 'Barkod: 8699540090422 • 1 Kutu (20 Tablet)',
            'freq': '2x1',
            'meal': 'Tok Karnına',
            'days': '5 Gün',
            'type': 'analgesic',
          },
          {
            'name': 'Parol 500 mg Tablet',
            'barcode': 'Barkod: 8699525010018 • 1 Kutu (20 Tablet)',
            'freq': '3x1',
            'meal': 'Tok Karnına',
            'days': '5 Gün',
            'type': 'pill',
          },
        ]);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Klinik reçete şablonu uygulandı.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _appendMacro(String macro) {
    final current = _doctorNoteController.text.trim();
    setState(() {
      _doctorNoteController.text = current.isEmpty ? macro : '$current $macro';
    });
  }

  void _submitPrescription() {
    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen en az bir ilaç ekleyin.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final code = '#REC-2026-${(10000 + DateTime.now().millisecond * 7).toString()}';
    final patientName = _selectedPatient['name'] as String;

    ClinicMockData.addPrescription({
      'id': code.replaceAll('#', ''),
      'code': code,
      'statusBadge': 'Aktif Tedavi',
      'dateText': '18 Mart 2026',
      'title': '${_selectedPatient['procedure']}',
      'subtitle': 'Dr. Selin Yılmaz • ${_medications.length} Kalem İlaç',
      'patientName': patientName,
      'doctorName': 'Dr. Selin Yılmaz',
      'medications': _medications.map((m) => {
        'name': m['name'] ?? '',
        'sub': m['barcode'] ?? '',
        'freq': 'Günde ${m['freq'] ?? '2x1'}',
        'usage': 'Sabah / Akşam',
        'meal': '${m['meal'] ?? 'Tok Karnına'} • ${m['days'] ?? '7 Gün'}',
      }).toList(),
      'note': _doctorNoteController.text.trim().isNotEmpty
          ? _doctorNoteController.text.trim()
          : null,
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Symbols.check_circle, color: Color(0xFF047857), size: 26),
            SizedBox(width: 10),
            Text('Reçete Oluşturuldu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$code numaralı reçete başarıyla oluşturuldu ve $patientName dosyasına eklendi.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.doctorSurfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hasta: $patientName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  Text('Tanı: ${_selectedPatient['icdCode']}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  Text('İlaç Sayısı: ${_medications.length} Kalem', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Oluşturulan reçete hasta portalında "Sonuçlarım & Reçetelerim" sekmesinde anında görüntülenmektedir.',
              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
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
                    // Screen Title & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DENTAL KLİNİK REÇETESİ',
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
                                'Sistem Aktif',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '1. HASTA SEÇİMİ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${_selectedPatient['name']} Seçili',
                          style: const TextStyle(
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
                      onChanged: (val) {
                        setState(() {
                          _isSearching = val.trim().isNotEmpty;
                        });
                      },
                      onTap: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceDoctor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Hasta adı veya TC Kimlik No ile arayın...',
                        prefixIcon: const Icon(
                          Symbols.person_search,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        suffixIcon: _patientSearchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _patientSearchController.clear();
                                  setState(() => _isSearching = false);
                                },
                                icon: const Icon(
                                  Symbols.close,
                                  size: 18,
                                  color: AppColors.outline,
                                ),
                              )
                            : null,
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

                    // Compact suggestions list (Max 2 items, scrollable, keyboard safe)
                    if (_isSearching && _matchingPatients.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 124),
                        margin: const EdgeInsets.only(top: 6, bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x10006574), blurRadius: 16, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,
                          child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          itemCount: _matchingPatients.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final p = _matchingPatients[i];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(p['avatar'] as String, width: 32, height: 32, fit: BoxFit.cover),
                              ),
                              title: Text(p['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              subtitle: Text('TC: ${p['tc']} • ${p['ageGender']}', style: const TextStyle(fontSize: 11)),
                              trailing: const Icon(Symbols.arrow_forward, size: 16, color: AppColors.primary),
                              onTap: () {
                                setState(() {
                                  _selectedPatient = p;
                                  _patientSearchController.text = p['name'] as String;
                                  _isSearching = false;
                                });
                                FocusScope.of(context).unfocus();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Selected Patient Clinical Snapshot Card (Dynamic!)
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
                                        _selectedPatient['avatar'] as String,
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
                                              Flexible(
                                                child: Text(
                                                  _selectedPatient['name'] as String,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
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
                                                child: Text(
                                                  _selectedPatient['ageGender'] as String,
                                                  style: const TextStyle(
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
                                          Text(
                                            'TC: ${_selectedPatient['tc']} • Protokol: ${_selectedPatient['protocol']}',
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
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (_selectedPatient['hasAllergy'] as bool)
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      (_selectedPatient['hasAllergy'] as bool)
                                          ? Symbols.warning
                                          : Symbols.check_circle,
                                      size: 13,
                                      fill: 1,
                                      color: (_selectedPatient['hasAllergy'] as bool)
                                          ? AppColors.error
                                          : const Color(0xFF047857),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedPatient['allergy'] as String,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: (_selectedPatient['hasAllergy'] as bool)
                                            ? AppColors.error
                                            : const Color(0xFF047857),
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
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Symbols.dentistry,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'İşlem: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _selectedPatient['procedure'] as String,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
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
                                  'ICD-10 Onaylı',
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedPatient['icdCode'] as String,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurfaceDoctor,
                                        ),
                                      ),
                                      Text(
                                        _selectedPatient['icdSub'] as String,
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
                          'Hazır Reçete Paketleri',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Template cards that scroll smoothly horizontally
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTemplateCard(
                            title: 'İmplant Profilaksisi',
                            desc: 'Augmentin + Arveles + Kloroben',
                            icon: Symbols.dentistry,
                            onTap: () => _applyPrescriptionTemplate('implant'),
                          ),
                          const SizedBox(width: 8),
                          _buildTemplateCard(
                            title: '20 Yaş Çekim Sonrası',
                            desc: 'Apranax Fort + Klorhex Gargara',
                            icon: Symbols.healing,
                            onTap: () => _applyPrescriptionTemplate('extraction'),
                          ),
                          const SizedBox(width: 8),
                          _buildTemplateCard(
                            title: 'Akut Ağrı & Pulpitis',
                            desc: 'Arveles 25mg + Parol 500mg',
                            icon: Symbols.medication,
                            onTap: () => _applyPrescriptionTemplate('pain'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Individual Quick Drug Pills
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
                      onTap: _showAddMedicationSheet,
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
                              Row(
                                children: [
                                  Icon(
                                    Symbols.verified,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Reçete hasta profiline anında işlenir',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Klinik Arşive Kaydedilir',
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
                    const SizedBox(height: 24),

                    // Primary Submit Button: Reçete Oluştur
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
                          onPressed: _submitPrescription,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(
                            Symbols.prescriptions,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Reçete Oluştur',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 175,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
          boxShadow: const [
            BoxShadow(color: Color(0x060B1C30), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceDoctor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
        ),
        child: Row(
          children: [
            const Icon(Symbols.add_circle, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
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
          // Clean dosage boxes WITHOUT the problematic hour/saat text
          Row(
            children: [
              _buildDosageBox('DOZ SIKLIĞI', med['freq']!),
              const SizedBox(width: 6),
              _buildDosageBox('KULLANIM', med['meal']!),
              const SizedBox(width: 6),
              _buildDosageBox('TEDAVİ SÜRESİ', med['days']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDosageBox(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            const SizedBox(height: 3),
            Text(
              val,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
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
