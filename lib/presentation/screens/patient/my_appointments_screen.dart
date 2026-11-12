import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/dentora_state_view.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/datasources/clinic_mock_data.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/appointment/appointment_cubit.dart';
import '../../widgets/dentora_logo.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  String _selectedFilter = 'all'; // 'all', 'upcoming', 'past', 'cancelled'
  int _selectedDayIndex = 3; // 19 Per

  static const List<Map<String, dynamic>> _stripDays = [
    {'day': 'Pzt', 'num': '16', 'hasDot': false},
    {'day': 'Sal', 'num': '17', 'hasDot': false},
    {'day': 'Çar', 'num': '18', 'hasDot': true},
    {'day': 'Per', 'num': '19', 'hasDot': true},
    {'day': 'Cum', 'num': '20', 'hasDot': false},
    {'day': 'Cmt', 'num': '21', 'hasDot': true},
    {'day': 'Paz', 'num': '22', 'hasDot': false},
  ];

  static const List<Map<String, String>> _pastAppointments = [
    {
      'title': 'Alt Çene İmplant Cerrahisi (1. Aşama)',
      'doctor': 'Prof. Dr. Kerem Aydın • Çene Cerrahisi',
      'date': '12 Şubat 2026 • 11:00',
      'price': '14.500 ₺',
    },
    {
      'title': 'Panoramik & 3D Dental Tomografi',
      'doctor': 'Uzm. Dt. Selin Yılmaz • Radyoloji Birimi',
      'date': '05 Ocak 2026 • 15:45',
      'price': '950 ₺',
    },
    {
      'title': 'Kompozit Estetik Dolgu (26 Nolu Diş)',
      'doctor': 'Dt. Emre Karahan • Restoratif Diş Tedavisi',
      'date': '18 Kasım 2025 • 10:15',
      'price': '2.100 ₺',
    },
    {
      'title': 'Yıllık Genel Muayene & Flor Uygulaması',
      'doctor': 'Uzm. Dt. Selin Yılmaz • Klinik 2',
      'date': '02 Eylül 2025 • 16:00',
      'price': '800 ₺',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser = context.read<AuthCubit>().state.user;
      final patientId = authUser?.id ?? ClinicMockData.samplePatient.id;
      context.read<AppointmentCubit>().watchPatientAppointments(patientId);
    });
  }

  void _confirmCancelAppointment(AppointmentModel appointment) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Randevuyu İptal Et'),
        content: Text(
          '${appointment.serviceName} randevunuzu iptal etmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<AppointmentCubit>().cancelAppointment(appointment.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = context.watch<AppointmentCubit>().state;
    final realAppointments = appointmentState.appointments;
    final upcomingList = appointmentState.upcomingAppointments;
    final pastList = appointmentState.pastAppointments;
    final cancelledList = appointmentState.cancelledAppointments;

    final allCount = realAppointments.isNotEmpty ? realAppointments.length.toString() : '6';
    final upcomingCount = realAppointments.isNotEmpty ? upcomingList.length.toString() : '2';
    final pastCount = realAppointments.isNotEmpty ? pastList.length.toString() : '4';
    final cancelledCount = realAppointments.isNotEmpty ? cancelledList.length.toString() : '0';

    final showUpcoming =
        _selectedFilter == 'all' || _selectedFilter == 'upcoming';
    final showPast = _selectedFilter == 'all' || _selectedFilter == 'past';
    final showCancelled = _selectedFilter == 'cancelled';

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
                    // Page Title & Quick Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KLİNİK TAKVİMİM',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Randevularım',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/patient/book'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Symbols.add,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Randevu Al',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Mini Calendar Strip (Mart 2026)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh.withValues(
                            alpha: 0.8,
                          ),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Symbols.event_note,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Mart 2026',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryFixed,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Aktif Dönem',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSecondaryFixed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildMiniNavBtn(Symbols.chevron_left),
                                  const SizedBox(width: 4),
                                  _buildMiniNavBtn(Symbols.chevron_right),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: List.generate(_stripDays.length, (index) {
                              final d = _stripDays[index];
                              final isSelected = _selectedDayIndex == index;
                              final hasDot = d['hasDot'] as bool;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDayIndex = index;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: [
                                                AppColors.primary,
                                                AppColors.primaryContainer,
                                              ],
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : (hasDot
                                                ? AppColors.surfaceContainerLow
                                                : Colors.transparent),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          d['day'] as String,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white.withValues(
                                                    alpha: 0.85,
                                                  )
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          d['num'] as String,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: hasDot
                                                ? (isSelected
                                                      ? AppColors
                                                            .secondaryContainer
                                                      : AppColors.primary)
                                                : Colors.transparent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'Tümü', allCount),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'upcoming',
                            'Yaklaşan',
                            upcomingCount,
                            dotColor: AppColors.secondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip('past', 'Geçmiş', pastCount),
                          const SizedBox(width: 8),
                          _buildFilterChip('cancelled', 'İptal Edilen', cancelledCount),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (appointmentState.listStatus.isLoading && realAppointments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: DentoraStateView(
                          icon: Symbols.schedule,
                          title: 'Randevularınız Yükleniyor...',
                          subtitle: 'Klinik takviminiz güncelleniyor',
                          isLoading: true,
                        ),
                      ),

                    if (appointmentState.listStatus.isError && realAppointments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: DentoraStateView(
                          icon: Symbols.error,
                          title: 'Randevular Alınamadı',
                          subtitle: appointmentState.listError ?? 'Bağlantı hatası oluştu',
                          onRetry: () {
                            final authUser = context.read<AuthCubit>().state.user;
                            final patientId = authUser?.id ?? ClinicMockData.samplePatient.id;
                            context.read<AppointmentCubit>().watchPatientAppointments(patientId);
                          },
                        ),
                      ),

                    // SECTION 1: YAKLAŞAN RANDEVULAR
                    if (showUpcoming) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Yaklaşan Randevular',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$upcomingCount Kayıt',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (realAppointments.isNotEmpty) ...[
                        if (upcomingList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: DentoraStateView(
                              icon: Symbols.event_available,
                              title: 'Yaklaşan Randevunuz Yok',
                              subtitle: 'Yeni bir randevu almak için yukarıdaki butonu kullanabilirsiniz.',
                            ),
                          )
                        else
                          for (final apt in upcomingList) ...[
                            _buildUpcomingCard(
                              badgeText: apt.status == 'approved' ? 'Onaylandı' : 'Planlandı',
                              badgeBg: apt.status == 'approved' ? AppColors.tertiaryFixed : AppColors.secondaryFixed,
                              badgeFg: apt.status == 'approved' ? AppColors.onTertiaryFixedVariant : AppColors.onSecondaryFixed,
                              price: '${apt.price} ₺',
                              icon: Symbols.dentistry,
                              title: apt.serviceName,
                              subtitle: '${apt.doctorName} • Klinik',
                              date: apt.date,
                              time: apt.time,
                              primaryBtnLabel: 'Detay & Hazırlık',
                              onCancel: () => _confirmCancelAppointment(apt),
                            ),
                            const SizedBox(height: 14),
                          ],
                      ] else ...[
                        // Upcoming Card 1 (Demo)
                        _buildUpcomingCard(
                          badgeText: 'Planlandı • Yarın',
                          badgeBg: AppColors.secondaryFixed,
                          badgeFg: AppColors.onSecondaryFixed,
                          price: '3.200 ₺',
                          icon: Symbols.dentistry,
                          title: 'Kanal Tedavisi & Kompozit Dolgu',
                          subtitle:
                              'Uzm. Dt. Selin Yılmaz • Endodonti Kliniği (Oda 3)',
                          date: '19 Mart 2026, Per',
                          time: '14:30 - 15:15',
                          primaryBtnLabel: 'Detay & Hazırlık',
                        ),
                        const SizedBox(height: 14),

                        // Upcoming Card 2 (Demo)
                        _buildUpcomingCard(
                          badgeText: 'Onaylandı',
                          badgeBg: AppColors.tertiaryFixed,
                          badgeFg: AppColors.onTertiaryFixedVariant,
                          price: '1.450 ₺',
                          icon: Symbols.clean_hands,
                          title: 'Ultrasonik Diş Taşı Temizliği (Detartraj)',
                          subtitle:
                              'Dt. Emre Karahan • Periodontoloji (Oda 1)',
                          date: '21 Mart 2026, Cmt',
                          time: '10:00 - 10:30',
                          primaryBtnLabel: 'Takvime Ekle',
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],

                    // SECTION 2: GEÇMİŞ RANDEVULAR
                    if (showPast) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.outline,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Geçmiş Randevular',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$pastCount Tamamlanan',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (realAppointments.isNotEmpty && pastList.isNotEmpty) ...[
                        for (final apt in pastList) ...[
                          _buildPastCard({
                            'title': apt.serviceName,
                            'doctor': apt.doctorName,
                            'date': '${apt.date} • ${apt.time}',
                            'price': '${apt.price} ₺',
                          }),
                          const SizedBox(height: 12),
                        ],
                      ] else ...[
                        for (final item in _pastAppointments) ...[
                          _buildPastCard(item),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ],

                    // SECTION 3: İPTAL EDİLEN RANDEVULAR
                    if (showCancelled) ...[
                      if (realAppointments.isNotEmpty && cancelledList.isNotEmpty) ...[
                        for (final apt in cancelledList) ...[
                          _buildPastCard({
                            'title': apt.serviceName,
                            'doctor': apt.doctorName,
                            'date': '${apt.date} • ${apt.time}',
                            'price': 'İptal Edildi',
                          }),
                          const SizedBox(height: 12),
                        ],
                      ] else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.surfaceContainerHigh,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Symbols.event_busy,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'İptal Edilen Randevunuz Yok',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tüm randevularınıza düzenli katılım sağladığınız için teşekkür ederiz.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
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

  Widget _buildMiniNavBtn(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
    );
  }

  Widget _buildFilterChip(
    String key,
    String label,
    String count, {
    Color? dotColor,
  }) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = key;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                )
              : null,
          color: isSelected ? null : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Row(
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard({
    required String badgeText,
    required Color badgeBg,
    required Color badgeFg,
    required String price,
    required IconData icon,
    required String title,
    required String subtitle,
    required String date,
    required String time,
    required String primaryBtnLabel,
    VoidCallback? onCancel,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Symbols.schedule,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeFg,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.calendar_today,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TARİH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 12,
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
                Container(
                  width: 1,
                  height: 28,
                  color: AppColors.surfaceContainerHigh,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.alarm,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SAAT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 12,
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/patient/book-calendar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    primaryBtnLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onCancel ?? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Erteleme / İptal talebiniz için klinik sekreterliği bilgilendirildi.',
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  backgroundColor: AppColors.errorContainer.withValues(
                    alpha: 0.35,
                  ),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ertele / İptal',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastCard(Map<String, String> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Symbols.check_circle,
                      size: 13,
                      fill: 1,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Tamamlandı',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item['date']!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item['title']!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item['doctor']!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.surfaceContainerLow, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ödenen: ${item['price']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              InkWell(
                onTap: () => context.go('/patient/results'),
                child: const Row(
                  children: [
                    Text(
                      'Rapor & Reçete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Symbols.arrow_forward,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

