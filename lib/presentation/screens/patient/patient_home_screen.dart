import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/appointment/appointment_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/doctor_schedule/doctor_schedule_cubit.dart';
import '../../widgets/dentora_logo.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  bool _isPriceListExpanded = false;

  static const List<Map<String, String>> _tariffs = [
    {
      'title': 'Uzman Diş Hekimi Muayenesi',
      'subtitle': 'Genel ağız içi kontrol & tedavi planlaması',
      'price': '750 ₺',
    },
    {
      'title': 'Panoramik Diş Röntgeni',
      'subtitle': 'Dijital tüm çene görüntüleme',
      'price': '600 ₺',
    },
    {
      'title': 'Diş Taşı Temizliği (Detartraj)',
      'subtitle': 'Alt ve üst çene ultrasonik temizlik + polisaj',
      'price': '1.800 ₺',
    },
    {
      'title': 'Kompozit Diş Dolgusu',
      'subtitle': 'Tek yüzlü estetik ışınlı dolgu (Birim diş)',
      'price': '2.200 ₺',
    },
    {
      'title': 'Kanal Tedavisi (Endodonti)',
      'subtitle': 'Tek kanallı diş kök tedavisi (Dolgu hariç)',
      'price': '3.500 ₺',
    },
    {
      'title': 'Standart Diş Çekimi',
      'subtitle': 'Lokal anestezi altında basit çekim',
      'price': '1.500 ₺',
    },
    {
      'title': 'Gömülü 20 Yaş Dişi Çekimi',
      'subtitle': 'Cerrahi operasyon ile mukozal/kemik retansiyonlu',
      'price': '4.800 ₺',
    },
    {
      'title': 'Dental İmplant Uygulaması',
      'subtitle': 'Yerli / İthal A Kalite Titanyum Vida (Tek diş)',
      'price': '14.500 ₺',
    },
    {
      'title': 'Zirkonyum Porselen Kuron',
      'subtitle': 'CAD/CAM dijital tasarım estetik kaplama (Üye başı)',
      'price': '6.200 ₺',
    },
    {
      'title': 'Lazerle Diş Beyazlatma (Bleaching)',
      'subtitle': 'Klinik tipi tek seans profesyonel beyazlatma',
      'price': '5.500 ₺',
    },
    {
      'title': 'Gece Plağı (Bruksizm)',
      'subtitle': 'Kişiye özel şeffaf diş sıkma apareyi',
      'price': '2.400 ₺',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final appointmentState = context.watch<AppointmentCubit>().state;
    final scheduleState = context.watch<DoctorScheduleCubit>().state;

    final userName = authState.user?.fullName.trim();
    final greetingName = (userName != null && userName.isNotEmpty)
        ? userName
        : 'Ahmet Bey';

    final nextAppointment = appointmentState.nextAppointment;
    final hasLiveAppointment = nextAppointment != null;
    final isAuthenticated = authState.isAuthenticated;

    final activeProcedures = scheduleState.activeProcedures;
    final displayedTariffs = activeProcedures.isNotEmpty
        ? activeProcedures
              .map(
                (p) => {
                  'title': p.title,
                  'subtitle': p.subtitle.isNotEmpty
                      ? p.subtitle
                      : (p.category.isNotEmpty
                            ? p.category
                            : '${p.durationMinutes} dk seans'),
                  'price': '${p.price} ₺',
                },
              )
              .toList(growable: false)
        : _tariffs;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PatientTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section
                    const Text(
                      'HOŞ GELDİNİZ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Merhaba, $greetingName',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ağız ve diş sağlığınız için bugün nasıl yardımcı olabiliriz?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CARD 1: Yaklaşan Randevu
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh.withValues(
                            alpha: 0.7,
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryFixed,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
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
                                    const SizedBox(width: 6),
                                    Text(
                                      appointmentState.listStatus.isLoading
                                          ? 'Randevular Yükleniyor...'
                                          : 'Yaklaşan Randevu',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSecondaryFixed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => context.go('/patient/appointments'),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Detaylar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Icon(
                                        Symbols.chevron_right,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (isAuthenticated &&
                              !hasLiveAppointment &&
                              !appointmentState.listStatus.isLoading) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Symbols.event_available,
                                    size: 22,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Henüz planlanmış yaklaşan bir randevunuz bulunmuyor. Aşağıdan yeni randevu oluşturabilirsiniz.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Doctor & Procedure Info
                            Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.asset(
                                        'assets/images/dr_selin_home.png',
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -4,
                                      right: -4,
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(7),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Icon(
                                          Symbols.verified,
                                          size: 13,
                                          fill: 1,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dt. Selin Yılmaz',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        hasLiveAppointment &&
                                                nextAppointment.title.isNotEmpty
                                            ? nextAppointment.title
                                            : 'Kanal Tedavisi & Genel Muayene',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Date & Time Bar
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Symbols.event,
                                            size: 20,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'TARİH',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              hasLiveAppointment
                                                  ? nextAppointment
                                                        .formattedDate
                                                  : '24 Ekim Perşembe',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 32,
                                    color: AppColors.surfaceContainerHighest,
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Symbols.schedule,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            hasLiveAppointment &&
                                                    nextAppointment
                                                        .timeSlot
                                                        .isNotEmpty
                                                ? nextAppointment.timeSlot
                                                : '14:30',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
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
                    ),
                    const SizedBox(height: 16),

                    // CARD 2: Randevu Al (Primary Action Card)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/patient/book'),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.16,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Symbols.add_circle,
                                          size: 14,
                                          color: AppColors.secondaryContainer,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'HIZLI İŞLEM',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Randevu Al',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Uzman hekimlerimizden size en uygun gün ve saat için hemen yerinizi ayırtın.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: Colors.white.withValues(
                                        alpha: 0.88,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Symbols.calendar_add_on,
                                size: 26,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CARD 3: Collapsible "Şeffaf Tedavi & Muayene Ücret Tarifesi"
                    Container(
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
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                _isPriceListExpanded = !_isPriceListExpanded;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Symbols.receipt_long,
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
                                        Row(
                                          children: [
                                            const Flexible(
                                              child: Text(
                                                'Muayene & İşlem Ücretleri',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .surfaceContainerLow,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                '2026 Güncel',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        const Text(
                                          'Şeffaf klinik fiyat listesini görüntülemek için dokunun',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isPriceListExpanded
                                          ? Symbols.expand_less
                                          : Symbols.expand_more,
                                      size: 20,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_isPriceListExpanded)
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                12,
                                20,
                                20,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.surfaceContainerLow,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Info Note
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow
                                          .withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Symbols.info,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Belirtilen tutarlar Türk Dişhekimleri Birliği (TDB) rehber tarifesi baz alınarak hazırlanmış standart klinik işlem ücretleridir.',
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
                                  const SizedBox(height: 8),
                                  for (int i = 0; i < _tariffs.length; i++) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _tariffs[i]['title']!,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _tariffs[i]['subtitle']!,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.surfaceContainerLow,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _tariffs[i]['price']!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (i < _tariffs.length - 1)
                                      const Divider(
                                        color: AppColors.surfaceContainerLow,
                                        height: 1,
                                      ),
                                  ],
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryFixed
                                          .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'Özel sağlık sigortası anlaşmalarımız mevcuttur.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.onSecondaryFixed,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () =>
                                              context.go('/patient/chat'),
                                          child: const Text(
                                            'Bize Sorun →',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

