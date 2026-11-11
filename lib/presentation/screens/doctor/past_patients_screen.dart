import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class PastPatientsScreen extends StatefulWidget {
  const PastPatientsScreen({super.key});

  @override
  State<PastPatientsScreen> createState() => _PastPatientsScreenState();
}

class _PastPatientsScreenState extends State<PastPatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  final Set<int> _expandedIndices = {0}; // First card expanded by default

  static const List<Map<String, dynamic>> _patients = [
    {
      'name': 'Ahmet Arslan',
      'tc': '348•••••912',
      'ageGender': '38 Yaş, E',
      'lastDate': '14 Mart 2026',
      'badge': 'İmplant & Kanal',
      'category': 'implant',
      'month': true,
      'avatar': 'assets/images/patient_ahmet_past.png',
      'history': [
        {
          'proc': '#36 Osseointegre İmplant Yerleştirilmesi',
          'date': '14 Mart 2026',
          'note':
              'Sol alt 1. molar bölgeye 4.1x10mm Straumann BLT implant 35 Ncm tork ile yerleştirildi. Primer stabilite yüksek.',
          'tags': [
            'Panoramik Röntgen',
            'Augmentin 1000mg 2x1',
            '4.500 ₺ Ödendi',
          ],
          'primary': true,
        },
        {
          'proc': '#24 Kompozit Restorasyon & Detartraj',
          'date': '02 Şubat 2026',
          'note':
              'Üst sol premolar диstal çürük temizlendi, 3M Filtek A2 kompozit dolgu uygulandı. Tüm ağız ultrasonik diş taşı temizliği yapıldı.',
          'tags': [],
          'primary': false,
        },
      ],
    },
    {
      'name': 'Selin Yılmaz',
      'tc': '192•••••408',
      'ageGender': '29 Yaş, K',
      'lastDate': '11 Mart 2026',
      'badge': 'Estetik & Zirkonyum',
      'category': 'all',
      'month': true,
      'avatar': 'assets/images/patient_selin_past.png',
      'history': [
        {
          'proc': '#13-#23 Anterior Monolitik Zirkonyum Simantasyonu',
          'date': '11 Mart 2026',
          'note':
              'Üst ön 6 üye B1 renk zirkonyum kronların daimi simantasyonu Panavia V5 ile tamamlandı. Oklüzyon ve fonasyon kontrol edildi.',
          'tags': ['3D Dijital Ölçü', '28.000 ₺ Tamamlandı'],
          'primary': true,
        },
      ],
    },
    {
      'name': 'Mehmet Demir',
      'tc': '514•••••776',
      'ageGender': '45 Yaş, E',
      'lastDate': '28 Şubat 2026',
      'badge': 'Gömülü 20 Yaş Cerrahisi',
      'category': 'cerrahi',
      'month': false,
      'avatar': 'assets/images/patient_mehmet_past.png',
      'history': [
        {
          'proc': '#48 sağ Alt Gömülü Yirmi Yaş Dişi Çekimi (Odontektomi)',
          'date': '28 Şubat 2026',
          'note':
              'Horizontal pozisyonlu gömülü #48 diş mukoperiostal flep kaldırılarak osteotomi ve kuron-kök separasyonu ile atravmatik çekildi. 3/0 ipek sütür atıldı.',
          'tags': ['Penisilin Alerjisi (Klindan 300mg)', 'CBCT 3D Kesit'],
          'primary': true,
        },
      ],
    },
    {
      'name': 'Ayşe Öztürk',
      'tc': '286•••••134',
      'ageGender': '52 Yaş, K',
      'lastDate': '19 Şubat 2026',
      'badge': 'Periodontoloji (Küretaj)',
      'category': 'cerrahi',
      'month': false,
      'avatar': 'assets/images/patient_ayse_past.png',
      'history': [
        {
          'proc': 'Alt/Üst Çene Subgingival Küretaj & Kök Yüzeyi Düzleştirme',
          'date': '19 Şubat 2026',
          'note':
              'Lokal anestezi altında 4 kadran derin cep temizliği yapıldı. Klorheksidin gargara ve arayüz fırçası eğitimi verildi.',
          'tags': [],
          'primary': true,
        },
      ],
    },
    {
      'name': 'Canan Kaya',
      'tc': '609•••••850',
      'ageGender': '24 Yaş, K',
      'lastDate': '05 Şubat 2026',
      'badge': 'Şeffaf Plak (Ortodonti)',
      'category': 'implant',
      'month': false,
      'avatar': 'assets/images/patient_canan_past.png',
      'history': [
        {
          'proc': 'Şeffaf Plak (Invisalign) Ataşman Uygulaması - Plak #1-#4',
          'date': '05 Şubat 2026',
          'note':
              'Üst ve alt ark kompozit ataşmanlar yerleştirildi. IPR (0.2mm) #31-#41 arasına uygulandı. İlk 4 plak hastaya teslim edildi.',
          'tags': [],
          'primary': true,
        },
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPatients {
    final query = _searchController.text.trim().toLowerCase();
    return _patients.where((p) {
      final matchesCategory =
          _selectedFilter == 'all' ||
          (_selectedFilter == 'month' && p['month'] == true) ||
          p['category'] == _selectedFilter;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      final hay = '${p['name']} ${p['tc']} ${p['badge']}'.toLowerCase();
      return hay.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredPatients;

    return Scaffold(
      backgroundColor: AppColors.doctorSurface,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceDoctor,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Hasta adı, TC Kimlik No veya işlem ara (Örn: İmplant)...',
                        prefixIcon: const Icon(
                          Symbols.search,
                          size: 20,
                          color: AppColors.outline,
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
                    const SizedBox(height: 12),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'Tüm Hastalar (148)'),
                          const SizedBox(width: 8),
                          _buildFilterChip('month', 'Bu Ay (24)'),
                          const SizedBox(width: 8),
                          _buildFilterChip('implant', 'İmplant (18)'),
                          const SizedBox(width: 8),
                          _buildFilterChip('cerrahi', 'Cerrahi (12)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Clinical Archive Summary Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F006574),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Symbols.clinical_notes,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'KLİNİK ARŞİVİ AKTİF',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Tamamlanan Tedavi & Epikrizler',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                '148',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Kayıtlı Hasta',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SON MUAYENE EDİLEN HASTALAR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const Text(
                          'Detay için karta dokunun',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    for (int i = 0; i < list.length; i++) ...[
                      _buildPatientAccordionCard(i, list[i]),
                      const SizedBox(height: 12),
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
          borderRadius: BorderRadius.circular(10),
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

  Widget _buildPatientAccordionCard(int index, Map<String, dynamic> p) {
    final isExpanded = _expandedIndices.contains(index);
    final history = p['history'] as List<Map<String, dynamic>>;

    return Container(
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
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedIndices.remove(index);
                } else {
                  _expandedIndices.add(index);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          p['avatar'] as String,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: -3,
                        right: -3,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.emeraldOnline,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Symbols.check,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                              p['name'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceDoctor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.doctorSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'TC: ${p['tc']}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              p['ageGender'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const Text(
                              '•',
                              style: TextStyle(color: AppColors.outlineVariant),
                            ),
                            Text(
                              'Son: ${p['lastDate']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryFixedDoctor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                p['badge'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      AppColors.onSecondaryFixedVariantDoctor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.doctorSurfaceContainerLow.withValues(
                  alpha: 0.45,
                ),
                border: const Border(
                  top: BorderSide(color: AppColors.doctorSurfaceContainerLow),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Symbols.history_edu,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'GEÇMİŞ İŞLEM & KLİNİK NOTLAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final item in history) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.doctorSurfaceContainerHigh,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['proc'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurfaceDoctor,
                                  ),
                                ),
                              ),
                              Text(
                                item['date'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hekim Notu: ${item['note']}',
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          if ((item['tags'] as List).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final tag in (item['tags'] as List))
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors
                                          .doctorSurfaceContainerLow,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tag as String,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondaryDoctor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/doctor/prescription'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: AppColors.doctorSurfaceContainerHigh,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Symbols.prescriptions, size: 15),
                          label: const Text(
                            'Yeni Reçete Yaz',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/doctor/messages'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Symbols.chat, size: 15),
                          label: const Text(
                            'Hastaya Mesaj Gönder',
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

