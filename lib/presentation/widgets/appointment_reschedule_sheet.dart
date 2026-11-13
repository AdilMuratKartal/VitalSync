import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/doctor_schedule_model.dart';
import '../../data/services/firestore_service.dart';

/// Randevu erteleme modal alt sayfası.
/// Doktorun Firestore çalışma programını ve mevcut randevularını dinamik sorgular,
/// dolu saatleri filtreler ve mevcut randevu kaydını günceller.
class AppointmentRescheduleSheet extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final void Function(String newDateDisplay, String newTime, String newIsoDate)?
      onRescheduled;

  const AppointmentRescheduleSheet({
    super.key,
    required this.appointment,
    this.onRescheduled,
  });

  static Future<void> show({
    required BuildContext context,
    required Map<String, dynamic> appointment,
    void Function(String newDateDisplay, String newTime, String newIsoDate)?
        onRescheduled,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppointmentRescheduleSheet(
        appointment: appointment,
        onRescheduled: onRescheduled,
      ),
    );
  }

  @override
  State<AppointmentRescheduleSheet> createState() =>
      _AppointmentRescheduleSheetState();
}

class _AppointmentRescheduleSheetState
    extends State<AppointmentRescheduleSheet> {
  late List<DateTime> _selectableDays;
  late int _selectedDayIndex;
  String? _selectedTimeSlot;

  bool _isLoadingSlots = false;
  bool _isSaving = false;
  List<String> _availableSlots = [];
  Set<String> _bookedSlots = {};

  DoctorScheduleModel? _doctorSchedule;
  List<AppointmentModel> _doctorAppointments = [];

  @override
  void initState() {
    super.initState();
    _initDays();
    _fetchDoctorDataAndSlots();
  }

  void _initDays() {
    final now = DateTime.now();
    _selectableDays = [];
    // Gelecek 14 gün (Pazar günleri hariç veya doktorun mesai günleri)
    for (int i = 1; i <= 14; i++) {
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      if (day.weekday != DateTime.sunday) {
        _selectableDays.add(day);
      }
    }
    _selectedDayIndex = 0;
  }

  String _formatIsoDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDisplayDate(DateTime dt) {
    const monthNames = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    const dayNames = ['', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return '${dt.day} ${monthNames[dt.month]} ${dt.year}, ${dayNames[dt.weekday]}';
  }

  Future<void> _fetchDoctorDataAndSlots() async {
    setState(() => _isLoadingSlots = true);

    final doctorId = (widget.appointment['doctorId'] as String?)?.trim() ??
        'DOC-101';
    final appointmentId = widget.appointment['id']?.toString() ?? '';

    try {
      if (ServiceLocator.isRegistered<FirestoreService>()) {
        final firestoreService = ServiceLocator.get<FirestoreService>();

        // 1. Doktor çalışma programını Firestore'dan oku
        final scheduleMap = await firestoreService.getDoctorSchedule(doctorId);
        if (scheduleMap != null) {
          _doctorSchedule = DoctorScheduleModel.fromJson(
            scheduleMap,
            id: doctorId,
          );
        }

        // 2. Doktorun mevcut randevularını Firestore'dan oku
        final rawApts = await firestoreService.getAppointmentsByDoctor(doctorId);
        _doctorAppointments = rawApts
            .map((map) => AppointmentModel.fromJson(map))
            .where((apt) => !apt.isCancelled && apt.id != appointmentId)
            .toList();
      }
    } catch (_) {
      // Offline fallback: use mock schedule
    }

    _computeSlotsForSelectedDate();

    if (mounted) {
      setState(() => _isLoadingSlots = false);
    }
  }

  void _computeSlotsForSelectedDate() {
    if (_selectableDays.isEmpty) return;
    final selectedDate = _selectableDays[_selectedDayIndex];
    final isoDate = _formatIsoDate(selectedDate);
    final currentAptId = widget.appointment['id']?.toString() ?? '';

    // Seçilen günde dolu olan saatler (bu randevu hariç)
    final booked = <String>{};
    for (final apt in _doctorAppointments) {
      if (apt.date == isoDate && apt.id != currentAptId && !apt.isCancelled) {
        booked.add(apt.time.trim());
      }
    }
    _bookedSlots = booked;

    // Temel slot havuzu
    List<String> rawSlots;
    if (_doctorSchedule != null && _doctorSchedule!.timeSlots.isNotEmpty) {
      rawSlots = _doctorSchedule!.timeSlots.entries
          .where((e) => e.value == 'open')
          .map((e) => e.key)
          .toList()
        ..sort();
    } else {
      // Standart klinik mesai slotları (30-45 dk)
      rawSlots = [
        '09:00',
        '09:45',
        '10:30',
        '11:15',
        '12:00',
        '14:00',
        '14:45',
        '15:30',
        '16:15',
        '17:00',
      ];
    }

    // Dolu saatleri ve mola saatlerini hariç tut (Dolu saatler tekrar önerilmemeli)
    _availableSlots = rawSlots.where((slot) => !booked.contains(slot)).toList();

    // Seçili slot artık uygun değilse sıfırla
    if (_selectedTimeSlot != null &&
        !_availableSlots.contains(_selectedTimeSlot)) {
      _selectedTimeSlot = null;
    }
  }

  Future<void> _handleSaveReschedule() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen yeni bir randevu saati seçiniz.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final selectedDate = _selectableDays[_selectedDayIndex];
    final newIsoDate = _formatIsoDate(selectedDate);
    final newDisplayDate = _formatDisplayDate(selectedDate);
    final newTime = _selectedTimeSlot!;
    final appointmentId = widget.appointment['id']?.toString() ?? '';

    try {
      // Aynı randevu üzerinde değişiklik yapıldığını doğrula (güncelleme işlemi)
      if (ServiceLocator.isRegistered<FirestoreService>() &&
          appointmentId.isNotEmpty) {
        final firestoreService = ServiceLocator.get<FirestoreService>();
        await firestoreService.updateAppointment(appointmentId, {
          'date': newIsoDate,
          'time': newTime,
          'status': 'pending',
        });
      }
    } catch (_) {
      // Local fallback
    }

    if (!mounted) return;

    widget.onRescheduled?.call(newDisplayDate, newTime, newIsoDate);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Symbols.event_available, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Randevunuz $newDisplayDate saat $newTime olarak başarıyla güncellendi.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentApt = widget.appointment;
    final currentDate = currentApt['date']?.toString() ?? 'Belirtilmedi';
    final currentTime = currentApt['time']?.toString() ?? '';
    final title = currentApt['title']?.toString() ?? 'Diş Randevusu';
    final doctor = currentApt['subtitle']?.toString() ??
        currentApt['doctor']?.toString() ??
        'Dentora Uzman Hekimi';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 14,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Symbols.edit_calendar,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Randevuyu Ertele',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Symbols.close, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Current Appointment Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.schedule, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MEVCUT RANDEVU BİLGİSİ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$currentDate • $currentTime',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          doctor,
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
            const SizedBox(height: 18),

            // Date Selection Header
            const Text(
              'YENİ RANDEVU TARİHİ SEÇİN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            // Horizontal Date Strip
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: _selectableDays.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = _selectableDays[index];
                  final isSelected = index == _selectedDayIndex;
                  const dayNames = [
                    '',
                    'Pzt',
                    'Sal',
                    'Çar',
                    'Per',
                    'Cum',
                    'Cmt',
                    'Paz',
                  ];
                  const monthShort = [
                    '',
                    'Oca',
                    'Şub',
                    'Mar',
                    'Nis',
                    'May',
                    'Haz',
                    'Tem',
                    'Ağu',
                    'Eyl',
                    'Eki',
                    'Kas',
                    'Ara',
                  ];

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                        _computeSlotsForSelectedDate();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 62,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayNames[day.weekday],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.onSurface,
                            ),
                          ),
                          Text(
                            monthShort[day.month],
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Time Slots Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'UYGUN SAATLER (DOKTOR PROGRAMI)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                if (_bookedSlots.isNotEmpty)
                  Text(
                    '${_bookedSlots.length} Saat Dolu',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Slots Grid
            if (_isLoadingSlots)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_availableSlots.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Symbols.event_busy, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seçilen tarihte uygun randevu saati bulunmuyor. Lütfen başka bir gün seçiniz.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedTimeSlot = slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
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
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.schedule,
                            size: 14,
                            color: isSelected ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            slot,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_selectedTimeSlot == null || _isSaving)
                    ? null
                    : _handleSaveReschedule,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Symbols.check_circle, size: 20),
                label: Text(
                  _isSaving
                      ? 'Güncelleniyor...'
                      : 'Yeni Tarihi Onayla ve Ertele',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
