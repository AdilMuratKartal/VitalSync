import '../../../data/models/appointment_model.dart';
import '../../../data/models/doctor_schedule_model.dart';
import '../cubit_status.dart';

/// Doktor çalışma programı, saat dilimleri, işlem fiyatları ve randevu uygunluk durumunu tutar.
class DoctorScheduleState {
  static const Object _unset = Object();

  final DataStatus dataStatus;
  final ActionStatus actionStatus;
  final DoctorScheduleModel? schedule;
  final List<AppointmentModel> doctorAppointments;
  final String? dataError;
  final String? actionError;
  final String? actionSuccessMessage;

  const DoctorScheduleState({
    this.dataStatus = DataStatus.initial,
    this.actionStatus = ActionStatus.idle,
    this.schedule,
    this.doctorAppointments = const [],
    this.dataError,
    this.actionError,
    this.actionSuccessMessage,
  });

  /// Doktor çalışma programının yüklü olup olmadığını belirtir.
  bool get hasSchedule => schedule != null;

  /// Tanımlı tüm dental işlem ve ücret kalemleri.
  List<ProcedurePriceItem> get procedures => schedule?.procedures ?? const [];

  /// Yalnızca randevuya açık (aktif) işlem ve ücret kalemleri.
  List<ProcedurePriceItem> get activeProcedures =>
      schedule?.activeProcedures ?? const [];

  /// Doktorun tanımladığı ham saat dilimi haritası ('open', 'break', 'closed').
  Map<String, String> get timeSlots => schedule?.timeSlots ?? const {};

  /// Doktorun çalışma programında 'open' (açık) olan, mesai saatleri içindeki ve mola dışındaki saat dilimleri.
  List<String> get openScheduleSlots {
    final currentSchedule = schedule;
    if (currentSchedule == null) return const [];

    final workStartMin = _parseTimeToMinutes(currentSchedule.workStart);
    final workEndMin = _parseTimeToMinutes(currentSchedule.workEnd);
    final breakBounds = _parseBreakRangeToMinutes(currentSchedule.breakRange);

    // timeSlots tanımlıysa içindeki 'open' slotları mesai ve mola kurallarına göre filtreler.
    if (currentSchedule.timeSlots.isNotEmpty) {
      final slots = <({String label, int minutes})>[];

      for (final entry in currentSchedule.timeSlots.entries) {
        if (entry.value != 'open') continue;
        final slotMin = _parseTimeToMinutes(entry.key);
        if (slotMin == null) continue;

        if (workStartMin != null && slotMin < workStartMin) continue;
        if (workEndMin != null && slotMin >= workEndMin) continue;
        if (breakBounds != null &&
            slotMin >= breakBounds.start &&
            slotMin < breakBounds.end) {
          continue;
        }

        slots.add((label: _formatMinutes(slotMin), minutes: slotMin));
      }

      slots.sort((a, b) => a.minutes.compareTo(b.minutes));
      return slots.map((e) => e.label).toList(growable: false);
    }

    // timeSlots boşsa workStart, workEnd, breakRange ve slotDurationMinutes üzerinden üretir.
    final duration = currentSchedule.slotDurationMinutes;
    if (workStartMin == null ||
        workEndMin == null ||
        workStartMin >= workEndMin ||
        duration <= 0) {
      return const [];
    }

    final generated = <String>[];
    for (var current = workStartMin;
        current + duration <= workEndMin;
        current += duration) {
      if (breakBounds != null) {
        final overlapsBreak =
            current < breakBounds.end && (current + duration) > breakBounds.start;
        if (overlapsBreak) continue;
      }
      generated.add(_formatMinutes(current));
    }
    return generated;
  }

  /// Doktorun programında 'break' (mola) olarak işaretlenmiş saat dilimleri.
  List<String> get breakScheduleSlots => _slotsByStatus('break');

  /// Doktorun programında 'closed' (kapalı) olarak işaretlenmiş saat dilimleri.
  List<String> get closedScheduleSlots => _slotsByStatus('closed');

  /// Belirtilen 'YYYY-MM-DD' tarihinin doktorun çalışma günlerinden biri olup olmadığını kontrol eder.
  bool isWorkingDayForDate(String date) {
    final currentSchedule = schedule;
    if (currentSchedule == null) return false;

    final parsedDate = _parseIsoDate(date);
    if (parsedDate == null) return false;

    // DateTime.weekday: 1 (Pazartesi) .. 7 (Pazar) -> workingDays index 0..6
    final dayIndex = parsedDate.weekday - 1;
    if (dayIndex < 0 || dayIndex >= currentSchedule.workingDays.length) {
      return false;
    }
    return currentSchedule.workingDays[dayIndex];
  }

  /// Belirtilen 'YYYY-MM-DD' tarihinde iptal edilmemiş randevular tarafından dolu olan saatleri döndürür.
  Set<String> bookedSlotsForDate(
    String date, {
    List<AppointmentModel>? externalAppointments,
  }) {
    final cleanDate = date.trim();
    if (cleanDate.isEmpty) return const {};

    final sourceAppointments = externalAppointments ?? doctorAppointments;
    final booked = <String>{};

    for (final appointment in sourceAppointments) {
      if (appointment.isCancelled) continue;
      if (appointment.date.trim() != cleanDate) continue;

      final minutes = _parseTimeToMinutes(appointment.time);
      if (minutes != null) {
        booked.add(_formatMinutes(minutes));
      } else {
        final rawTime = appointment.time.trim();
        if (rawTime.isNotEmpty) {
          booked.add(rawTime);
        }
      }
    }
    return booked;
  }

  /// Belirtilen 'YYYY-MM-DD' tarihi için hem doktorun çalışma programında açık olan hem de başka bir randevuyla dolu olmayan uygun saatleri döndürür.
  List<String> availableSlotsForDate(
    String date, {
    List<AppointmentModel>? externalAppointments,
  }) {
    if (schedule == null) return const [];

    final cleanDate = date.trim();
    if (_parseIsoDate(cleanDate) != null && !isWorkingDayForDate(cleanDate)) {
      return const [];
    }

    final booked = bookedSlotsForDate(
      cleanDate,
      externalAppointments: externalAppointments,
    );

    return openScheduleSlots
        .where((slot) => !booked.contains(slot))
        .toList(growable: false);
  }

  List<String> _slotsByStatus(String targetStatus) {
    final currentSchedule = schedule;
    if (currentSchedule == null || currentSchedule.timeSlots.isEmpty) {
      return const [];
    }

    final matched = <({String label, int minutes})>[];
    for (final entry in currentSchedule.timeSlots.entries) {
      if (entry.value != targetStatus) continue;
      final minutes = _parseTimeToMinutes(entry.key);
      if (minutes == null) continue;
      matched.add((label: _formatMinutes(minutes), minutes: minutes));
    }
    matched.sort((a, b) => a.minutes.compareTo(b.minutes));
    return matched.map((e) => e.label).toList(growable: false);
  }

  static DateTime? _parseIsoDate(String rawDate) {
    final match =
        RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(rawDate.trim());
    if (match == null) return null;

    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;

    final dt = DateTime(year, month, day);
    if (dt.year != year || dt.month != month || dt.day != day) return null;
    return dt;
  }

  static int? _parseTimeToMinutes(String rawTime) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(rawTime.trim());
    if (match == null) return null;

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }

  static ({int start, int end})? _parseBreakRangeToMinutes(String rawRange) {
    final clean = rawRange.trim();
    if (clean.isEmpty || clean.toLowerCase() == 'mola yok') return null;

    final parts = clean.split('-');
    if (parts.length != 2) return null;

    final start = _parseTimeToMinutes(parts[0]);
    final end = _parseTimeToMinutes(parts[1]);
    if (start == null || end == null || start >= end) return null;

    return (start: start, end: end);
  }

  static String _formatMinutes(int totalMinutes) {
    final h = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final m = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  DoctorScheduleState copyWith({
    DataStatus? dataStatus,
    ActionStatus? actionStatus,
    Object? schedule = _unset,
    List<AppointmentModel>? doctorAppointments,
    Object? dataError = _unset,
    Object? actionError = _unset,
    Object? actionSuccessMessage = _unset,
  }) {
    return DoctorScheduleState(
      dataStatus: dataStatus ?? this.dataStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      schedule: identical(schedule, _unset)
          ? this.schedule
          : schedule as DoctorScheduleModel?,
      doctorAppointments: doctorAppointments ?? this.doctorAppointments,
      dataError: identical(dataError, _unset)
          ? this.dataError
          : dataError as String?,
      actionError: identical(actionError, _unset)
          ? this.actionError
          : actionError as String?,
      actionSuccessMessage: identical(actionSuccessMessage, _unset)
          ? this.actionSuccessMessage
          : actionSuccessMessage as String?,
    );
  }
}

