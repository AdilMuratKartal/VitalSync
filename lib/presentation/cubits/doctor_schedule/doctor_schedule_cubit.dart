import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/doctor_schedule_model.dart';
import '../../../data/services/firestore_service.dart';
import '../cubit_status.dart';
import 'doctor_schedule_state.dart';

/// Doktor çalışma saatleri, mola aralıkları, randevu slot uygunluğu ve işlem fiyatlarını yönetir.
class DoctorScheduleCubit extends Cubit<DoctorScheduleState> {
  final FirestoreService _firestoreService;

  StreamSubscription<Map<String, dynamic>?>? _scheduleSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _appointmentsSubscription;
  int _dataOperationToken = 0;
  int _actionOperationToken = 0;
  int _scheduleRevision = 0;

  DoctorScheduleCubit({FirestoreService? firestoreService})
      : _firestoreService =
            firestoreService ?? ServiceLocator.get<FirestoreService>(),
        super(const DoctorScheduleState());

  /// Doktorun çalışma programını (ve isteğe bağlı olarak randevularını) tek seferlik yükler.
  Future<void> loadDoctorSchedule(
    String doctorId, {
    bool includeAppointments = true,
  }) async {
    final cleanDoctorId = doctorId.trim();
    if (cleanDoctorId.isEmpty) {
      _invalidateOperations();
      await _cancelSubscriptions();
      emit(
        state.copyWith(
          dataStatus: DataStatus.error,
          schedule: null,
          doctorAppointments: const [],
          dataError: 'Çalışma programını yüklemek için geçerli doktor kimliği gerekli.',
        ),
      );
      return;
    }

    final token = ++_dataOperationToken;
    _actionOperationToken++;
    _scheduleRevision++;
    await _cancelSubscriptions();

    emit(
      state.copyWith(
        dataStatus: DataStatus.loading,
        actionStatus: ActionStatus.idle,
        dataError: null,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    try {
      final rawSchedule = await _firestoreService.getDoctorSchedule(
        cleanDoctorId,
      );
      List<AppointmentModel> parsedAppointments = state.doctorAppointments;

      if (includeAppointments) {
        final rawAppointments = await _firestoreService.getAppointmentsByDoctor(
          cleanDoctorId,
        );
        parsedAppointments = rawAppointments
            .map((map) => AppointmentModel.fromJson(map))
            .toList(growable: false);
      }

      if (!_isCurrentDataOperation(token)) return;
      _scheduleRevision++;

      if (rawSchedule == null) {
        emit(
          state.copyWith(
            dataStatus: DataStatus.empty,
            schedule: null,
            doctorAppointments: parsedAppointments,
            dataError: null,
          ),
        );
        return;
      }

      final scheduleModel = DoctorScheduleModel.fromJson(
        rawSchedule,
        id: cleanDoctorId,
      );

      emit(
        state.copyWith(
          dataStatus: DataStatus.success,
          schedule: scheduleModel,
          doctorAppointments: parsedAppointments,
          dataError: null,
        ),
      );
    } on FirestoreServiceException catch (e) {
      if (!_isCurrentDataOperation(token)) return;
      emit(
        state.copyWith(
          dataStatus: DataStatus.error,
          dataError: e.message,
        ),
      );
    } catch (_) {
      if (!_isCurrentDataOperation(token)) return;
      emit(
        state.copyWith(
          dataStatus: DataStatus.error,
          dataError: 'Doktor çalışma programı yüklenirken bir hata oluştu.',
        ),
      );
    }
  }

  /// Doktorun çalışma programını ve randevu doluluk durumunu gerçek zamanlı olarak dinler.
  void watchDoctorSchedule(
    String doctorId, {
    bool watchAppointments = true,
  }) {
    final cleanDoctorId = doctorId.trim();
    if (cleanDoctorId.isEmpty) {
      _invalidateOperations();
      _cancelSubscriptions();
      emit(
        state.copyWith(
          dataStatus: DataStatus.error,
          schedule: null,
          doctorAppointments: const [],
          dataError: 'Çalışma programını dinlemek için geçerli doktor kimliği gerekli.',
        ),
      );
      return;
    }

    final token = ++_dataOperationToken;
    _actionOperationToken++;
    _scheduleRevision++;
    _cancelSubscriptions();

    emit(
      state.copyWith(
        dataStatus: DataStatus.loading,
        actionStatus: ActionStatus.idle,
        schedule: null,
        doctorAppointments: const [],
        dataError: null,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    _scheduleSubscription = _firestoreService
        .streamDoctorSchedule(cleanDoctorId)
        .listen(
          (rawSchedule) {
            if (!_isCurrentDataOperation(token)) return;
            _scheduleRevision++;

            if (rawSchedule == null) {
              emit(
                state.copyWith(
                  dataStatus: DataStatus.empty,
                  schedule: null,
                  dataError: null,
                ),
              );
              return;
            }

            final scheduleModel = DoctorScheduleModel.fromJson(
              rawSchedule,
              id: cleanDoctorId,
            );

            emit(
              state.copyWith(
                dataStatus: DataStatus.success,
                schedule: scheduleModel,
                dataError: null,
              ),
            );
          },
          onError: (_) {
            if (!_isCurrentDataOperation(token)) return;
            _scheduleRevision++;
            emit(
              state.copyWith(
                dataStatus: DataStatus.error,
                dataError:
                    'Doktor çalışma programı dinlenirken bir hata oluştu.',
              ),
            );
          },
        );

    if (watchAppointments) {
      _appointmentsSubscription = _firestoreService
          .streamAppointmentsByDoctor(cleanDoctorId)
          .listen(
            (rawAppointments) {
              if (!_isCurrentDataOperation(token)) return;
              final parsed = rawAppointments
                  .map((map) => AppointmentModel.fromJson(map))
                  .toList(growable: false);

              emit(state.copyWith(doctorAppointments: parsed));
            },
            onError: (_) {
              // Randevu akışındaki geçici hata, ana çalışma programı görünümünü bozmaz.
            },
          );
    }
  }

  /// Doktor çalışma programını ve işlem tarifesini doğrulayarak Firestore'a kaydeder.
  Future<void> saveSchedule(
    DoctorScheduleModel schedule, {
    String? customSuccessMessage,
  }) async {
    final cleanDoctorId = schedule.doctorId.trim();
    if (cleanDoctorId.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Çalışma programını kaydetmek için doktor kimliği gerekli.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final validationError = _validateSchedule(schedule);
    if (validationError != null) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: validationError,
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final token = ++_actionOperationToken;
    final dataTokenAtStart = _dataOperationToken;
    final revisionAtStart = _scheduleRevision;

    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    try {
      final normalizedSchedule = schedule.copyWith(
        id: schedule.id.trim().isEmpty ? cleanDoctorId : schedule.id.trim(),
        doctorId: cleanDoctorId,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.saveDoctorSchedule(
        cleanDoctorId,
        normalizedSchedule.toJson(),
      );

      if (!_isCurrentActionOperation(token)) return;

      final canApplyLocalSchedule = dataTokenAtStart == _dataOperationToken &&
          revisionAtStart == _scheduleRevision;

      emit(
        state.copyWith(
          dataStatus: canApplyLocalSchedule
              ? DataStatus.success
              : state.dataStatus,
          actionStatus: ActionStatus.succeeded,
          schedule: canApplyLocalSchedule ? normalizedSchedule : state.schedule,
          dataError: canApplyLocalSchedule ? null : state.dataError,
          actionError: null,
          actionSuccessMessage:
              customSuccessMessage ?? 'Çalışma programı ve fiyat tarifesi kaydedildi.',
        ),
      );
    } on FirestoreServiceException catch (e) {
      if (!_isCurrentActionOperation(token)) return;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: e.message,
          actionSuccessMessage: null,
        ),
      );
    } catch (_) {
      if (!_isCurrentActionOperation(token)) return;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Çalışma programı kaydedilirken bir hata oluştu.',
          actionSuccessMessage: null,
        ),
      );
    }
  }

  /// Doktorun çalışma günlerini, mesai başlangıç/bitiş saatlerini, molasını ve slot süresini günceller.
  Future<void> updateWorkingSchedule({
    List<bool>? workingDays,
    String? workStart,
    String? workEnd,
    String? breakRange,
    int? slotDurationMinutes,
    Map<String, String>? timeSlots,
  }) async {
    final current = state.schedule;
    if (current == null) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Güncellenecek çalışma programı bulunamadı.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final updated = current.copyWith(
      workingDays: workingDays ?? current.workingDays,
      workStart: workStart?.trim() ?? current.workStart,
      workEnd: workEnd?.trim() ?? current.workEnd,
      breakRange: breakRange?.trim() ?? current.breakRange,
      slotDurationMinutes: slotDurationMinutes ?? current.slotDurationMinutes,
      timeSlots: timeSlots ?? current.timeSlots,
      updatedAt: DateTime.now(),
    );

    await saveSchedule(
      updated,
      customSuccessMessage:
          'Çalışma saatleri, mola aralıkları ve randevu slotları güncellendi.',
    );
  }

  /// Tek bir saat diliminin durumunu ('open', 'break', 'closed') günceller ve kaydeder.
  Future<void> updateSlotStatus({
    required String timeSlot,
    required String status,
  }) async {
    final current = state.schedule;
    if (current == null) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Saat dilimi güncellemek için yüklü program bulunamadı.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final cleanSlot = timeSlot.trim();
    final cleanStatus = status.trim();
    if (_parseTimeToMinutes(cleanSlot) == null ||
        !_validSlotStatuses.contains(cleanStatus)) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Geçersiz saat dilimi veya slot durumu.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final updatedSlots = Map<String, String>.from(current.timeSlots)
      ..[cleanSlot] = cleanStatus;

    await saveSchedule(
      current.copyWith(
        timeSlots: updatedSlots,
        updatedAt: DateTime.now(),
      ),
      customSuccessMessage: 'Randevu saati durumu güncellendi.',
    );
  }

  /// Tüm işlem ve muayene ücretleri listesini doğrulayarak günceller.
  Future<void> updateProcedures(List<ProcedurePriceItem> procedures) async {
    final current = state.schedule;
    if (current == null) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Fiyat tarifesini güncellemek için yüklü program bulunamadı.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    await saveSchedule(
      current.copyWith(
        procedures: List<ProcedurePriceItem>.unmodifiable(procedures),
        updatedAt: DateTime.now(),
      ),
      customSuccessMessage: 'İşlem ve hizmet fiyat tarifesi güncellendi.',
    );
  }

  /// Tek bir işlemin fiyatını, süresini veya aktiflik durumunu günceller.
  Future<void> updateProcedureItem({
    required String procedureIdOrTitle,
    int? price,
    bool? isActive,
    int? durationMinutes,
  }) async {
    final current = state.schedule;
    if (current == null) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'İşlem güncellemek için yüklü program bulunamadı.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final targetKey = procedureIdOrTitle.trim();
    if (targetKey.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Güncellenecek işlem kimliği veya başlığı belirtilmelidir.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    if (price != null && price < 0) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'İşlem ücreti negatif olamaz.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    if (durationMinutes != null && durationMinutes <= 0) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'İşlem süresi sıfırdan büyük olmalıdır.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    var matched = false;
    final updatedProcedures = current.procedures.map((item) {
      final isMatch = item.id == targetKey || item.title == targetKey;
      if (!isMatch) return item;
      matched = true;
      return item.copyWith(
        price: price ?? item.price,
        isActive: isActive ?? item.isActive,
        durationMinutes: durationMinutes ?? item.durationMinutes,
      );
    }).toList(growable: false);

    if (!matched) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Güncellenmek istenen işlem listede bulunamadı.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    await updateProcedures(updatedProcedures);
  }

  /// Belirtilen 'YYYY-MM-DD' tarihi için uygun (açık ve rezerve edilmemiş) randevu saatlerini döndürür.
  List<String> getAvailableSlotsForDate(
    String date, {
    List<AppointmentModel>? externalAppointments,
  }) {
    return state.availableSlotsForDate(
      date,
      externalAppointments: externalAppointments,
    );
  }

  /// Veri durumuna dokunmadan yalnızca işlem (action) durumunu ve mesajlarını temizler.
  void clearActionState() {
    emit(
      state.copyWith(
        actionStatus: ActionStatus.idle,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );
  }

  /// Aktif abonelikleri kapatır ve çalışma programı state verilerini sıfırlar.
  Future<void> reset() async {
    _invalidateOperations();
    await _cancelSubscriptions();
    if (!isClosed) {
      emit(const DoctorScheduleState());
    }
  }

  static const Set<String> _validSlotStatuses = {'open', 'break', 'closed'};

  /// Çalışma saatleri, mola aralığı, slot süresi ve işlem fiyatlarının geçerliliğini kontrol eder.
  String? _validateSchedule(DoctorScheduleModel schedule) {
    if (schedule.workingDays.length != 7) {
      return 'Çalışma günleri haftanın 7 gününü içermelidir.';
    }

    final startMin = _parseTimeToMinutes(schedule.workStart);
    final endMin = _parseTimeToMinutes(schedule.workEnd);
    if (startMin == null || endMin == null) {
      return 'Mesai başlangıç ve bitiş saatleri SS:DD formatında olmalıdır.';
    }
    if (startMin >= endMin) {
      return 'Mesai başlangıç saati, bitiş saatinden önce olmalıdır.';
    }

    if (schedule.slotDurationMinutes <= 0 ||
        schedule.slotDurationMinutes > (endMin - startMin)) {
      return 'Randevu slot süresi geçerli bir dakika değeri olmalıdır.';
    }

    final cleanBreak = schedule.breakRange.trim();
    if (cleanBreak.isNotEmpty && cleanBreak.toLowerCase() != 'mola yok') {
      final parts = cleanBreak.split('-');
      if (parts.length != 2) {
        return 'Mola aralığı "SS:DD - SS:DD" formatında olmalıdır.';
      }
      final breakStart = _parseTimeToMinutes(parts[0]);
      final breakEnd = _parseTimeToMinutes(parts[1]);
      if (breakStart == null || breakEnd == null || breakStart >= breakEnd) {
        return 'Mola başlangıç saati, mola bitiş saatinden önce olmalıdır.';
      }
      if (breakStart < startMin || breakEnd > endMin) {
        return 'Mola aralığı mesai saatleri içinde olmalıdır.';
      }
    }

    for (final entry in schedule.timeSlots.entries) {
      if (_parseTimeToMinutes(entry.key) == null) {
        return 'Geçersiz saat dilimi anahtarı: ${entry.key}.';
      }
      if (!_validSlotStatuses.contains(entry.value)) {
        return 'Geçersiz saat dilimi durumu: ${entry.value}.';
      }
    }

    for (final proc in schedule.procedures) {
      if (proc.title.trim().isEmpty) {
        return 'İşlem adı boş bırakılamaz.';
      }
      if (proc.price < 0) {
        return '${proc.title} için işlem ücreti negatif olamaz.';
      }
      if (proc.durationMinutes <= 0) {
        return '${proc.title} için işlem süresi sıfırdan büyük olmalıdır.';
      }
    }

    return null;
  }

  static int? _parseTimeToMinutes(String rawTime) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(rawTime.trim());
    if (match == null) return null;

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }

  void _invalidateOperations() {
    _dataOperationToken++;
    _actionOperationToken++;
    _scheduleRevision++;
  }

  Future<void> _cancelSubscriptions() async {
    await _scheduleSubscription?.cancel();
    _scheduleSubscription = null;
    await _appointmentsSubscription?.cancel();
    _appointmentsSubscription = null;
  }

  bool _isCurrentDataOperation(int token) =>
      !isClosed && token == _dataOperationToken;

  bool _isCurrentActionOperation(int token) =>
      !isClosed && token == _actionOperationToken;

  @override
  Future<void> close() async {
    _invalidateOperations();
    await _cancelSubscriptions();
    return super.close();
  }
}

