import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vital_model.dart';
import '../../../data/datasources/clinic_mock_data.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/vital/vital_cubit.dart';
import '../../widgets/dentora_logo.dart';

class MyVitalsScreen extends StatefulWidget {
  const MyVitalsScreen({super.key});

  @override
  State<MyVitalsScreen> createState() => _MyVitalsScreenState();
}

class _MyVitalsScreenState extends State<MyVitalsScreen> {
  String _sysValue = '120';
  String _diaValue = '80';
  String _sugarValue = '95';
  String _pulseValue = '72';

  bool _isMonthlyPeriod = false;
  int _selectedChartMetric = 0; // 0: Tansiyon, 1: Şeker, 2: Nabız

  late final TextEditingController _sysController;
  late final TextEditingController _diaController;
  late final TextEditingController _sugarController;
  late final TextEditingController _pulseController;

  @override
  void initState() {
    super.initState();
    _sysController = TextEditingController(text: _sysValue);
    _diaController = TextEditingController(text: _diaValue);
    _sugarController = TextEditingController(text: _sugarValue);
    _pulseController = TextEditingController(text: _pulseValue);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authUser = context.read<AuthCubit>().state.user;
      final patientId = authUser?.id ?? ClinicMockData.samplePatient.id;
      context.read<VitalCubit>().watchPatientVitals(patientId);
    });
  }

  @override
  void dispose() {
    _sysController.dispose();
    _diaController.dispose();
    _sugarController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveVitals() async {
    final sys = int.tryParse(_sysController.text.trim());
    final dia = int.tryParse(_diaController.text.trim());
    final sugar = int.tryParse(_sugarController.text.trim());
    final pulse = int.tryParse(_pulseController.text.trim());

    if (sys == null || dia == null || sys <= 0 || dia <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Geçerli tansiyon değerleri giriniz (Örn: 120/80).'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (sys <= dia) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Büyük tansiyon, küçük tansiyondan yüksek olmalıdır.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (sugar == null || sugar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Geçerli bir kan şekeri değeri giriniz.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (pulse == null || pulse <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Geçerli bir nabız değeri giriniz.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final authUser = context.read<AuthCubit>().state.user;
    final patientId = authUser?.id ?? ClinicMockData.samplePatient.id;

    final vital = VitalModel(
      id: 'VTL-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      systolic: sys,
      diastolic: dia,
      bloodSugar: sugar,
      pulse: pulse,
      oxygen: 98,
      createdAt: DateTime.now(),
    );

    setState(() {
      _sysValue = sys.toString();
      _diaValue = dia.toString();
      _sugarValue = sugar.toString();
      _pulseValue = pulse.toString();
    });

    final vitalCubit = context.read<VitalCubit>();
    await vitalCubit.createVital(vital);

    if (mounted) {
      if (vitalCubit.state.actionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vitalCubit.state.actionError!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vital.isCritical
                ? 'Vital değer kaydedildi. DİKKAT: Kritik eşik aşıldı!'
                : 'Yeni vital ölçüm değerleriniz başarıyla kaydedildi!'),
            backgroundColor: vital.isCritical ? AppColors.error : AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vitalState = context.watch<VitalCubit>().state;
    final latestVital = vitalState.latestVital;

    final sysDisplay = latestVital != null ? latestVital.systolic.toString() : _sysValue;
    final diaDisplay = latestVital != null ? latestVital.diastolic.toString() : _diaValue;
    final sugarDisplay = latestVital != null ? latestVital.bloodSugar.toString() : _sugarValue;
    final pulseDisplay = latestVital != null ? latestVital.pulse.toString() : _pulseValue;
    final oxygenDisplay = latestVital != null ? '%${latestVital.oxygen}' : '%98';

    final isCritical = vitalState.isLatestVitalCritical || (latestVital?.isCritical ?? false);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PatientTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vitalState.dataStatus.isLoading && vitalState.vitals.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),

                    // Hero Greeting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Symbols.verified_user,
                                size: 13,
                                fill: 1,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Pre-Operatif Takip Aktif',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSecondaryFixed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          latestVital != null
                              ? 'Son: ${latestVital.createdAt.hour.toString().padLeft(2, '0')}:${latestVital.createdAt.minute.toString().padLeft(2, '0')}'
                              : 'Son Güncelleme: Bugün, 09:40',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Günlük Sağlık Verilerim',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Diş tedavisi ve cerrahi işlemler öncesi hekiminizin izlediği anlık vital değerleriniz.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Critical Vital Warning Banner
                    if (isCritical) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Symbols.warning, color: AppColors.error, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Kritik Değer Uyarısı',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Son ölçülen değerleriniz klinik eşiğin dışındadır. Doktorunuz bilgilendirildi.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // BENTO VITAL GRID (2x2)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.08,
                      children: [
                        // Card 1: Tansiyon
                        _buildVitalBentoCard(
                          icon: Symbols.blood_pressure,
                          badgeText: (int.tryParse(sysDisplay) ?? 120) >= 140 ? 'Yüksek' : 'İdeal',
                          label: 'Tansiyon (KB)',
                          value: '$sysDisplay/$diaDisplay',
                          unit: 'mmHg',
                          subText: 'Sistolik / Diyastolik',
                        ),
                        // Card 2: Açlık Şekeri
                        _buildVitalBentoCard(
                          icon: Symbols.glucose,
                          badgeText: (int.tryParse(sugarDisplay) ?? 95) >= 180 ? 'Yüksek' : 'Normal',
                          label: 'Açlık Şekeri',
                          value: sugarDisplay,
                          unit: 'mg/dL',
                          subText: 'Hedef: 70 - 100 mg/dL',
                        ),
                        // Card 3: Nabız
                        _buildVitalBentoCard(
                          icon: Symbols.favorite,
                          badgeText: (int.tryParse(pulseDisplay) ?? 72) > 100 ? 'Hızlı' : 'Düzenli',
                          label: 'Kalp Atışı (Nabız)',
                          value: pulseDisplay,
                          unit: 'bpm',
                          subText: 'Dinlenme Hızı',
                          fillIcon: true,
                        ),
                        // Card 4: SpO2 & Ateş
                        _buildVitalBentoCard(
                          icon: Symbols.spo2,
                          badgeText: 'Optimal',
                          label: 'Oksijen & Ateş',
                          value: oxygenDisplay,
                          unit: '36.6°C',
                          subText: 'SpO₂ Satürasyon',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // INTERACTIVE VITAL ENTRY PANEL
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Symbols.edit_note,
                                      size: 20,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hızlı Ölçüm Güncelle',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'Yeni ölçümünüzü girip kaydedin',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Canlı Kayıt',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildVitalInputBox(
                                  label: 'BÜYÜK / KÜÇÜK TANSİYON',
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildCompactTextField(
                                          _sysController,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          '/',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.outline,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildCompactTextField(
                                          _diaController,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildVitalInputBox(
                                  label: 'KAN ŞEKERİ (MG/DL)',
                                  child: _buildCompactTextField(
                                    _sugarController,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: _buildVitalInputBox(
                                  label: 'NABIZ (BPM)',
                                  child: _buildCompactTextField(
                                    _pulseController,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryContainer,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: _saveVitals,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Symbols.check_circle,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Değerleri Kaydet',
                                        style: TextStyle(
                                          fontSize: 12,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // SECTION: SAĞLIK PARAMETRE TRENDİ (Wave Chart Card)
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sağlık Parametre Trendi',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Haftalık değişim ve klinik stabilite eğrisi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Period Toggle (7 Gün / Aylık)
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(
                                        () => _isMonthlyPeriod = false,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: !_isMonthlyPeriod
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '7 Gün',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: !_isMonthlyPeriod
                                                ? Colors.white
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(
                                        () => _isMonthlyPeriod = true,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _isMonthlyPeriod
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Aylık',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _isMonthlyPeriod
                                                ? Colors.white
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Parameter Selector Pills
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildChartMetricPill(0, 'Tansiyon (mmHg)'),
                                const SizedBox(width: 8),
                                _buildChartMetricPill(1, 'Şeker (mg/dL)'),
                                const SizedBox(width: 8),
                                _buildChartMetricPill(2, 'Nabız (bpm)'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Custom Painted Smooth Line Chart
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow.withValues(
                                alpha: 0.65,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                _selectedChartMetric == 0
                                                    ? 'Sistolik (Büyük)'
                                                    : (_selectedChartMetric == 1
                                                          ? 'Açlık Glikoz'
                                                          : 'Dinlenme Nabzı'),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_selectedChartMetric == 0)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: AppColors
                                                            .secondaryContainer,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                                const SizedBox(width: 5),
                                                const Text(
                                                  'Diyastolik (Küçük)',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedChartMetric == 0
                                          ? 'Ort: 119/79 mmHg'
                                          : (_selectedChartMetric == 1
                                                ? 'Ort: 94 mg/dL'
                                                : 'Ort: 73 bpm'),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: _VitalTrendChartPainter(
                                      metricIndex: _selectedChartMetric,
                                      isMonthly: _isMonthlyPeriod,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pzt',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'Sal',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'Çar',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'Per',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'Cum',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'Cmt',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'Bugün',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Clinical Note Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Symbols.stethoscope,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Hekim Değerlendirmesi: Son 7 günlük kan basıncı ve glikoz değerleriniz lokal anestezi ve dental cerrahi işlem için ideal sınırlar içerisindedir.',
                                    style: TextStyle(
                                      fontSize: 12,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalBentoCard({
    required IconData icon,
    required String badgeText,
    required String label,
    required String value,
    required String unit,
    required String subText,
    bool fillIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A131B2E),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  fill: fillIcon ? 1 : 0,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSecondaryFixed,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            subText,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalInputBox({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  Widget _buildCompactTextField(TextEditingController controller) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.surfaceContainerHigh),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.surfaceContainerHigh),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildChartMetricPill(int index, String label) {
    final isSelected = _selectedChartMetric == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartMetric = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryFixed
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? AppColors.onSecondaryFixed
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _VitalTrendChartPainter extends CustomPainter {
  final int metricIndex;
  final bool isMonthly;

  _VitalTrendChartPainter({required this.metricIndex, required this.isMonthly});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Horizontal dashed grid lines
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    for (final yRatio in [0.18, 0.50, 0.82]) {
      final y = h * yRatio;
      double startX = 0;
      while (startX < w) {
        canvas.drawLine(Offset(startX, y), Offset(startX + 4, y), gridPaint);
        startX += 8;
      }
    }

    // Points based on metric & period
    final List<double> yRatios = metricIndex == 0
        ? (isMonthly
              ? [0.40, 0.32, 0.44, 0.36, 0.30, 0.38, 0.34]
              : [0.38, 0.34, 0.42, 0.31, 0.36, 0.39, 0.35])
        : (metricIndex == 1
              ? [0.48, 0.42, 0.50, 0.44, 0.39, 0.46, 0.41]
              : [0.55, 0.48, 0.52, 0.46, 0.50, 0.54, 0.49]);

    final points = <Offset>[];
    for (int i = 0; i < yRatios.length; i++) {
      final x = (w / (yRatios.length - 1)) * i;
      final y = h * yRatios[i];
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Area fill under primary curve
    final areaPath = Path.from(linePath)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(areaPath, areaPaint);

    // Primary stroke
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, strokePaint);

    // Secondary Diastolic line if metricIndex == 0
    if (metricIndex == 0) {
      final diaRatios = [0.74, 0.71, 0.76, 0.69, 0.72, 0.75, 0.72];
      final diaPoints = <Offset>[];
      for (int i = 0; i < diaRatios.length; i++) {
        diaPoints.add(
          Offset((w / (diaRatios.length - 1)) * i, h * diaRatios[i]),
        );
      }
      final diaPath = Path()..moveTo(diaPoints.first.dx, diaPoints.first.dy);
      for (int i = 0; i < diaPoints.length - 1; i++) {
        final p0 = diaPoints[i];
        final p1 = diaPoints[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        diaPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }
      final diaPaint = Paint()
        ..color = AppColors.secondaryContainer
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(diaPath, diaPaint);
    }

    // Draw nodes
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isLast = i == points.length - 1;
      canvas.drawCircle(
        pt,
        isLast ? 5.5 : 4.0,
        Paint()..color = isLast ? AppColors.primary : Colors.white,
      );
      canvas.drawCircle(
        pt,
        isLast ? 5.5 : 4.0,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VitalTrendChartPainter oldDelegate) {
    return oldDelegate.metricIndex != metricIndex ||
        oldDelegate.isMonthly != isMonthly;
  }
}
