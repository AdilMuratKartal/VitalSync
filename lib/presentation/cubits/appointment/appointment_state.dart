import '../../../data/models/appointment_model.dart';
import '../cubit_status.dart';

/// Randevu listesi akışını ve tekil randevu işlemlerinin (rezervasyon, iptal, güncelleme) durumunu tutar.
class AppointmentState {
  static const Object _unset = Object();

  final DataStatus listStatus;
  final ActionStatus actionStatus;
  final List<AppointmentModel> appointments;
  final String? listError;
  final String? actionError;
  final String? actionSuccessMessage;

  const AppointmentState({
    this.listStatus = DataStatus.initial,
    this.actionStatus = ActionStatus.idle,
    this.appointments = const [],
    this.listError,
    this.actionError,
    this.actionSuccessMessage,
  });

  /// Aktif (iptal edilmemiş ve tamamlanmamış) yaklaşan randevular.
  List<AppointmentModel> get upcomingAppointments =>
      appointments.where((item) => item.isActive).toList(growable: false);

  /// Tamamlanmış geçmiş randevular.
  List<AppointmentModel> get pastAppointments =>
      appointments.where((item) => item.isCompleted).toList(growable: false);

  /// İptal edilmiş randevular.
  List<AppointmentModel> get cancelledAppointments =>
      appointments.where((item) => item.isCancelled).toList(growable: false);

  /// İptal edilmemiş, tamamlanmamış ve tarihi/saati geçmemiş en yakın gelecek randevu.
  AppointmentModel? get nextAppointment {
    final now = DateTime.now();
    final futureEntries = <({AppointmentModel appointment, DateTime scheduledAt})>[];

    for (final item in appointments) {
      if (!item.isActive) continue;
      final scheduledAt = _parseAppointmentDateTime(item.date, item.time);
      if (scheduledAt == null || scheduledAt.isBefore(now)) continue;
      futureEntries.add((appointment: item, scheduledAt: scheduledAt));
    }

    if (futureEntries.isEmpty) return null;

    futureEntries.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return futureEntries.first.appointment;
  }

  /// AppointmentModel'in 'YYYY-MM-DD' tarih ve 'HH:mm' saat alanlarını DateTime'a dönüştürür.
  static DateTime? _parseAppointmentDateTime(String rawDate, String rawTime) {
    final dateMatch =
        RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(rawDate.trim());
    final timeMatch =
        RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(rawTime.trim());

    if (dateMatch == null || timeMatch == null) return null;

    final year = int.tryParse(dateMatch.group(1)!);
    final month = int.tryParse(dateMatch.group(2)!);
    final day = int.tryParse(dateMatch.group(3)!);
    final hour = int.tryParse(timeMatch.group(1)!);
    final minute = int.tryParse(timeMatch.group(2)!);

    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null) {
      return null;
    }

    if (month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31 ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    final parsed = DateTime(year, month, day, hour, minute);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  AppointmentState copyWith({
    DataStatus? listStatus,
    ActionStatus? actionStatus,
    List<AppointmentModel>? appointments,
    Object? listError = _unset,
    Object? actionError = _unset,
    Object? actionSuccessMessage = _unset,
  }) {
    return AppointmentState(
      listStatus: listStatus ?? this.listStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      appointments: appointments ?? this.appointments,
      listError: identical(listError, _unset)
          ? this.listError
          : listError as String?,
      actionError: identical(actionError, _unset)
          ? this.actionError
          : actionError as String?,
      actionSuccessMessage: identical(actionSuccessMessage, _unset)
          ? this.actionSuccessMessage
          : actionSuccessMessage as String?,
    );
  }
}

