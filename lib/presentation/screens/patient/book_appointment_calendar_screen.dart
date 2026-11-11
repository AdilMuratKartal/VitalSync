import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class BookAppointmentCalendarScreen extends StatefulWidget {
  const BookAppointmentCalendarScreen({super.key});

  @override
  State<BookAppointmentCalendarScreen> createState() =>
      _BookAppointmentCalendarScreenState();
}

class _BookAppointmentCalendarScreenState
    extends State<BookAppointmentCalendarScreen> {
  int _selectedServiceIndex = 0;
  int _selectedDay = 24;
  int _selectedSlotIndex = 6; // 14:30 - 15:15

  static const List<Map<String, dynamic>> _services = [
    {'title': 'Genel Diş Muayenesi', 'icon': Symbols.dentistry},
    {'title': 'Diş Taşı Temizliği (Detartraj)', 'icon': Symbols.clean_hands},
    {'title': 'Estetik Kompozit Dolgu', 'icon': Symbols.healing},
    {'title': 'Kanal Tedavisi (Endodonti)', 'icon': Symbols.medical_services},
    {'title': 'Dental İmplant Uygulaması', 'icon': Symbols.biotech},
    {'title': '20 Yaş Dişi Cerrahi Çekimi', 'icon': Symbols.surgical},
    {'title': 'Lazer Diş Beyazlatma (Bleaching)', 'icon': Symbols.flare},
    {'title': 'Zirkonyum & Lamine Kaplama', 'icon': Symbols.diamond},
    {'title': 'Şeffaf Plak & Ortodonti', 'icon': Symbols.sentiment_satisfied},
    {'title': 'Diş Eti Tedavisi (Periodontoloji)', 'icon': Symbols.health_and_safety},
    {'title': 'Çocuk Diş Hekimliği (Pedodonti)', 'icon': Symbols.child_care},
    {'title': 'Panoramik Röntgen & 3D Tomografi', 'icon': Symbols.radiology},
  ];

  static const List<Map<String, dynamic>> _timeSlots = [
    {'time': '09:00 - 09:45', 'status': 'busy'},
    {'time': '09:45 - 10:30', 'status': 'available'},
    {'time': '10:30 - 11:15', 'status': 'available'},
    {'time': '11:15 - 12:00', 'status': 'busy'},
    {'time': '13:00 - 13:45', 'status': 'available'},
    {'time': '13:45 - 14:30', 'status': 'busy'},
    {'time': '14:30 - 15:15', 'status': 'available'},
    {'time': '15:15 - 16:00', 'status': 'available'},
    {'time': '16:00 - 16:45', 'status': 'busy'},
    {'time': '16:45 - 17:30', 'status': 'available'},
  ];

  static const Set<int> _busyDays = {1, 2, 6, 8, 9, 13, 15, 20, 22, 27};
  static const Set<int> _availableDotDays = {16, 17, 18, 19, 21, 23, 25, 26};

  @override
  Widget build(BuildContext context) {
    final selectedService = _services[_selectedServiceIndex]['title'] as String;
    final selectedSlot = _timeSlots[_selectedSlotIndex]['time'] as String;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PatientTopAppBar(
              showBackButton: true,
              subtitle: 'Muayene & Takvim Planlama',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RANDEVU DETAYI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tedavi & Zaman Planla',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Adım 1/3',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 1: 12 Horizontal Treatment Pills
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.medical_information,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Tedavi / Hizmet Seçimi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '12 Hizmet Mevcut',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _services.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final s = _services[index];
                          final isSelected = _selectedServiceIndex == index;
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _selectedServiceIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
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
                                    : AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(14),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: AppColors.surfaceContainerHigh,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.22,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    s['icon'] as IconData,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    s['title'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.onSurface,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Symbols.check_circle,
                                      size: 16,
                                      fill: 1,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Interactive Calendar Card (Ekim 2024)
                    Container(
                      padding: const EdgeInsets.all(20),
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
                            color: Color(0x0F131B2E),
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Calendar Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Symbols.calendar_month,
                                      size: 20,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ekim 2024',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'Müsait günler işaretlenmiştir',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildCalendarNavButton(Symbols.chevron_left),
                                  const SizedBox(width: 6),
                                  _buildCalendarNavButton(
                                    Symbols.chevron_right,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Weekday Headers
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _WeekdayLabel('PZT'),
                              _WeekdayLabel('SAL'),
                              _WeekdayLabel('ÇAR'),
                              _WeekdayLabel('PER'),
                              _WeekdayLabel('CUM'),
                              _WeekdayLabel('CMT'),
                              _WeekdayLabel('PAZ'),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Calendar Grid (Oct 2024 starts on Tuesday -> 1 offset day)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                ),
                            itemCount: 32,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return const Center(
                                  child: Text(
                                    '30',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0x666E797C),
                                    ),
                                  ),
                                );
                              }
                              final day = index;
                              final isBusy = _busyDays.contains(day);
                              final isSelected = _selectedDay == day;
                              final isToday = day == 14;
                              final hasDot = _availableDotDays.contains(day);

                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: isBusy
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedDay = day;
                                        });
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
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
                                        : (isToday
                                              ? AppColors.surfaceContainerLow
                                              : Colors.transparent),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isToday && !isSelected
                                        ? Border.all(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.4,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$day',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected || isToday
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          decoration: isBusy
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: isSelected
                                              ? Colors.white
                                              : (isBusy
                                                    ? AppColors.outline
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : (isToday
                                                          ? AppColors.primary
                                                          : AppColors
                                                                .onSurface)),
                                        ),
                                      ),
                                      if (isSelected || isToday || hasDot) ...[
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white
                                                : (isToday
                                                      ? AppColors.primary
                                                      : AppColors
                                                            .secondaryContainer),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: AppColors.surfaceContainerLow),
                          const SizedBox(height: 10),
                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLegendItem(
                                color: AppColors.primary,
                                label: 'Seçili Gün',
                              ),
                              _buildLegendItem(
                                color: AppColors.secondaryContainer,
                                label: 'Müsait Saat Var',
                              ),
                              _buildLegendItem(
                                color: AppColors.outlineVariant,
                                label: 'Dolu / Kapalı',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 3: Time Slots (2-col grid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Symbols.schedule,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Randevu Saati',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$_selectedDay Ekim Perşembe',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSecondaryFixed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.9,
                          ),
                      itemCount: _timeSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _timeSlots[index];
                        final isBusy = slot['status'] == 'busy';
                        final isSelected =
                            _selectedSlotIndex == index && !isBusy;

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: isBusy
                              ? null
                              : () {
                                  setState(() {
                                    _selectedSlotIndex = index;
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryContainer,
                                      ],
                                    )
                                  : null,
                              color: isBusy
                                  ? AppColors.surfaceContainerLow
                                  : (isSelected
                                        ? null
                                        : AppColors.surfaceContainerLowest),
                              borderRadius: BorderRadius.circular(14),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: AppColors.surfaceContainerHigh,
                                    ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isBusy
                                            ? Symbols.block
                                            : (isSelected
                                                  ? Symbols.check_circle
                                                  : Symbols.schedule),
                                        size: 15,
                                        fill: isSelected ? 1 : 0,
                                        color: isBusy
                                            ? AppColors.outline
                                            : (isSelected
                                                  ? Colors.white
                                                  : AppColors.primary),
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          slot['time'] as String,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            decoration: isBusy
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: isBusy
                                                ? AppColors.outline
                                                : (isSelected
                                                      ? Colors.white
                                                      : AppColors.onSurface),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isBusy
                                        ? AppColors.surfaceContainerHigh
                                        : (isSelected
                                              ? Colors.white.withValues(
                                                  alpha: 0.2,
                                                )
                                              : AppColors.secondaryFixed),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isBusy
                                        ? 'Dolu'
                                        : (isSelected ? 'Seçildi' : 'Müsait'),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isBusy
                                          ? AppColors.onSurfaceVariant
                                          : (isSelected
                                                ? Colors.white
                                                : AppColors.onSecondaryFixed),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section 4: Appointment Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Symbols.receipt_long,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Randevu Özeti',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  '45 Dakika',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildSummaryRow('Seçilen İşlem', selectedService),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(
                              color: AppColors.surfaceContainerHigh,
                              height: 1,
                            ),
                          ),
                          _buildSummaryRow(
                            'Tarih & Saat',
                            '$_selectedDay Ekim 2024 • $selectedSlot',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(
                              color: AppColors.surfaceContainerHigh,
                              height: 1,
                            ),
                          ),
                          _buildSummaryRow(
                            'İlgili Hekim',
                            'Dt. Selin Yılmaz (Protez & Estetik)',
                          ),
                          const SizedBox(height: 18),

                          // Primary CTA Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
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
                                        '$_selectedDay Ekim $selectedSlot randevunuz oluşturuldu!',
                                      ),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  context.go('/patient/appointments');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(
                                  Symbols.event_available,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Randevu Al',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Randevunuzdan 2 saat öncesine kadar ücretsiz iptal veya değişiklik yapabilirsiniz.',
                            textAlign: TextAlign.center,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarNavButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColors.onSurface),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
