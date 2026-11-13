import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _selectedServiceIndex = 1; // Diş Temizliği default selected
  int _selectedDateIndex = 0; // 14 Cum default selected
  int _selectedTimeIndex = 4; // 14:30 default selected
  final TextEditingController _noteController = TextEditingController();

  static const List<Map<String, dynamic>> _services = [
    {'title': 'Genel Muayene', 'icon': Symbols.stethoscope},
    {'title': 'Diş Temizliği', 'icon': Symbols.dentistry},
    {'title': 'Dolgu Tedavisi', 'icon': Symbols.healing},
    {'title': 'Kanal Tedavisi', 'icon': Symbols.medical_services},
    {'title': 'Diş Çekimi', 'icon': Symbols.surgical},
    {'title': 'İmplant', 'icon': Symbols.biotech},
    {'title': 'Diş Beyazlatma', 'icon': Symbols.auto_awesome},
    {'title': 'Zirkonyum', 'icon': Symbols.diamond},
    {'title': 'Ortodonti (Tel)', 'icon': Symbols.grid_on},
    {'title': '20 Yaş Çekimi', 'icon': Symbols.vaccines},
    {'title': 'Çocuk Diş', 'icon': Symbols.child_care},
    {'title': 'Panoramik Röntgen', 'icon': Symbols.radiology},
  ];

  static const List<Map<String, String>> _dates = [
    {'dayName': 'Cum', 'dayNumber': '14', 'fullText': '14 Mart'},
    {'dayName': 'Cmt', 'dayNumber': '15', 'fullText': '15 Mart'},
    {'dayName': 'Pzt', 'dayNumber': '17', 'fullText': '17 Mart'},
    {'dayName': 'Sal', 'dayNumber': '18', 'fullText': '18 Mart'},
    {'dayName': 'Çar', 'dayNumber': '19', 'fullText': '19 Mart'},
    {'dayName': 'Per', 'dayNumber': '20', 'fullText': '20 Mart'},
  ];

  static const List<Map<String, dynamic>> _timeSlots = [
    {'time': '09:30', 'busy': false},
    {'time': '10:15', 'busy': false},
    {'time': '11:00', 'busy': true},
    {'time': '13:30', 'busy': false},
    {'time': '14:30', 'busy': false},
    {'time': '15:15', 'busy': false},
    {'time': '16:00', 'busy': true},
    {'time': '16:45', 'busy': false},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedService = _services[_selectedServiceIndex]['title'] as String;
    final selectedDate = _dates[_selectedDateIndex]['fullText']!;
    final selectedTime = _timeSlots[_selectedTimeIndex]['time'] as String;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PatientTopAppBar(
              showBackButton: true,
              subtitle: 'Hızlı Randevu Planlama',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Randevu Oluştur',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'İşlem, tarih ve uygun saati seçerek randevunuzu tamamlayın.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              context.push('/patient/book-calendar'),
                          icon: const Icon(
                            Symbols.calendar_month,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Detaylı Takvim',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // STEP 1: İŞLEM / HİZMET SEÇİMİ (12 Services 3-Col Grid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildStepCircle('1'),
                            const SizedBox(width: 8),
                            const Text(
                              'Hizmet / İşlem Seçin',
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
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '12 Hizmet',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
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
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.02,
                          ),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final item = _services[index];
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.surfaceContainerLow
                                  : AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceContainerHigh,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A131B2E),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (isSelected)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Symbols.check,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        item['icon'] as IconData,
                                        size: 20,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['title'] as String,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.15,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // STEP 2: TARİH SEÇİMİ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildStepCircle('2'),
                            const SizedBox(width: 8),
                            const Text(
                              'Tarih Seçin',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(
                              Symbols.calendar_today,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Mart 2025',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 82,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: _dates.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final d = _dates[index];
                          final isSelected = _selectedDateIndex == index;
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                _selectedDateIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 64,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryContainer,
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: AppColors.surfaceContainerHigh,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.25,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    d['dayName']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    d['dayNumber']!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.secondaryContainer
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // STEP 3: SAAT SEÇİMİ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildStepCircle('3'),
                            const SizedBox(width: 8),
                            const Text(
                              'Saat Seçin',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Dt. Selin Yılmaz',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
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
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.0,
                          ),
                      itemCount: _timeSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _timeSlots[index];
                        final busy = slot['busy'] as bool;
                        final isSelected = _selectedTimeIndex == index && !busy;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: busy
                              ? null
                              : () {
                                  setState(() {
                                    _selectedTimeIndex = index;
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryContainer,
                                      ],
                                    )
                                  : null,
                              color: busy
                                  ? AppColors.surfaceContainerLow.withValues(
                                      alpha: 0.6,
                                    )
                                  : (isSelected
                                        ? null
                                        : AppColors.surfaceContainerLowest),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: AppColors.surfaceContainerHigh,
                                    ),
                            ),
                            child: Text(
                              slot['time'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                decoration: busy
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: busy
                                    ? AppColors.outline.withValues(alpha: 0.6)
                                    : (isSelected
                                          ? Colors.white
                                          : AppColors.onSurface),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // STEP 4: EK NOT (OPSİYONEL)
                    const Row(
                      children: [
                        Icon(
                          Symbols.edit_note,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Hekime Not / Şikayetiniz ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '(İsteğe Bağlı)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Örn: Sol alt azı dişimde sıcak-soğuk hassasiyeti var...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppColors.outline.withValues(alpha: 0.7),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceContainerHigh,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceContainerHigh,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Summary Action Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.96),
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceContainerHigh),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'SEÇİLEN RANDEVU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$selectedService • $selectedDate, $selectedTime',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  DecoratedBox(
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
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$selectedService ($selectedDate $selectedTime) randevunuz onaylandı!',
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Symbols.event_available,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Randevu Al',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(String step) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.secondaryFixed,
        shape: BoxShape.circle,
      ),
      child: Text(
        step,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.onSecondaryFixedVariant,
        ),
      ),
    );
  }
}
