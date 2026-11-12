import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/services/firestore_service.dart';
import '../cubit_status.dart';
import 'appointment_state.dart';

/// Hasta ve doktor randevularının canlı akışını, çakışma kontrollü rezervasyonu ve durum güncellemelerini yönetir.
class AppointmentCubit extends Cubit<AppointmentState> {
  final FirestoreService _firestoreService;

  StreamSubscription<List<Map<String, dynamic>>>? _appointmentsSubscription;
  int _listOperationToken = 0;
  int _actionOperationToken = 0;
  int _streamRevision = 0;

  AppointmentCubit({FirestoreService? firestoreService})
    : _firestoreService =
          firestoreService ?? ServiceLocator.get<FirestoreService>(),
      super(const AppointmentState());

  /// Belirtilen hastanın randevularını gerçek zamanlı olarak dinler.
  void watchPatientAppointments(String patientId) {
    final cleanPatientId = patientId.trim();
    if (cleanPatientId.isEmpty) {
      _listOperationToken++;
      _actionOperationToken++;
      _streamRevision++;
      _cancelSubscription();
      emit(
        state.copyWith(
          listStatus: DataStatus.error,
          appointments: const [],
          listError:
              'Randevuları görüntülemek için geçerli hasta kimliği gerekli.',
        ),
      );
      return;
    }

    _subscribeToAppointments(
      () => _firestoreService.streamAppointmentsByPatient(cleanPatientId),
    );
  }

  /// Belirtilen doktorun randevularını gerçek zamanlı olarak dinler.
  void watchDoctorAppointments(String doctorId) {
    final cleanDoctorId = doctorId.trim();
    if (cleanDoctorId.isEmpty) {
      _listOperationToken++;
      _actionOperationToken++;
      _streamRevision++;
      _cancelSubscription();
      emit(
        state.copyWith(
          listStatus: DataStatus.error,
          appointments: const [],
          listError:
              'Randevuları görüntülemek için geçerli doktor kimliği gerekli.',
        ),
      );
      return;
    }

    _subscribeToAppointments(
      () => _firestoreService.streamAppointmentsByDoctor(cleanDoctorId),
    );
  }

  /// Seçilen saat dilimi müsaitse yeni randevu oluşturur; mevcut listeyi bozmaz.
  Future<String?> bookAppointment(AppointmentModel appointment) async {
    if (appointment.patientId.trim().isEmpty ||
        appointment.doctorId.trim().isEmpty ||
        appointment.date.trim().isEmpty ||
        appointment.time.trim().isEmpty ||
        appointment.serviceName.trim().isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Randevu oluşturmak için doktor, hizmet, tarih ve saat bilgileri eksiksiz olmalıdır.',
          actionSuccessMessage: null,
        ),
      );
      return null;
    }

    final token = ++_actionOperationToken;
    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    try {
      final payload = Map<String, dynamic>.from(appointment.toJson());
      if (appointment.id.trim().isEmpty) {
        payload.remove('id');
      }

      final createdId = await _firestoreService.bookAppointmentIfAvailable(
        payload,
      );
      if (!_isCurrentActionOperation(token)) return null;

      emit(
        state.copyWith(
          actionStatus: ActionStatus.succeeded,
          actionError: null,
          actionSuccessMessage: 'Randevunuz başarıyla oluşturuldu.',
        ),
      );
      return createdId;
    } on FirestoreServiceException catch (e) {
      if (!_isCurrentActionOperation(token)) return null;
      final errorMessage = e.code == 'slot-already-booked'
          ? 'Seçilen randevu saati başka bir hasta tarafından alınmış. Lütfen farklı bir saat seçin.'
          : e.message;

      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: errorMessage,
          actionSuccessMessage: null,
        ),
      );
      return null;
    } catch (_) {
      if (!_isCurrentActionOperation(token)) return null;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Randevu oluşturulurken beklenmeyen bir hata oluştu.',
          actionSuccessMessage: null,
        ),
      );
      return null;
    }
  }

  /// Belirtilen randevuyu iptal durumuna ('cancelled') geçirir.
  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: 'cancelled',
      customSuccessMessage: 'Randevu iptal edildi.',
    );
  }

  /// Randevunun durumunu ('pending', 'approved', 'completed', 'cancelled') günceller.
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    String? customSuccessMessage,
  }) async {
    final cleanId = appointmentId.trim();
    final cleanStatus = status.trim();

    if (cleanId.isEmpty || cleanStatus.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Geçerli bir randevu kimliği ve durum bilgisi gerekli.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final token = ++_actionOperationToken;
    final listTokenAtStart = _listOperationToken;
    final revisionAtStart = _streamRevision;

    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    try {
      await _firestoreService.updateAppointmentStatus(cleanId, cleanStatus);
      if (!_isCurrentActionOperation(token)) return;

      // Yalnızca aynı kullanıcı dinleniyorsa ve bu sırada Stream daha yeni bir veri yayınlamadıysa yerel listeyi günceller.
      final canApplyLocalUpdate =
          listTokenAtStart == _listOperationToken &&
          revisionAtStart == _streamRevision;
      final updatedList = canApplyLocalUpdate
          ? _updateLocalAppointmentIfPresent(
              cleanId,
              (item) => item.copyWith(status: cleanStatus),
            )
          : state.appointments;

      emit(
        state.copyWith(
          actionStatus: ActionStatus.succeeded,
          appointments: updatedList,
          actionError: null,
          actionSuccessMessage:
              customSuccessMessage ?? 'Randevu durumu güncellendi.',
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
          actionError: 'Randevu durumu güncellenirken bir hata oluştu.',
          actionSuccessMessage: null,
        ),
      );
    }
  }

  /// Randevuya ait klinik/hasta notunu günceller.
  Future<void> updateAppointmentNote({
    required String appointmentId,
    required String note,
  }) async {
    final cleanId = appointmentId.trim();
    if (cleanId.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Not güncellemek için geçerli randevu kimliği gerekli.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final cleanNote = note.trim();
    final token = ++_actionOperationToken;
    final listTokenAtStart = _listOperationToken;
    final revisionAtStart = _streamRevision;

    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    try {
      await _firestoreService.updateAppointment(cleanId, {'note': cleanNote});
      if (!_isCurrentActionOperation(token)) return;

      final canApplyLocalUpdate =
          listTokenAtStart == _listOperationToken &&
          revisionAtStart == _streamRevision;
      final updatedList = canApplyLocalUpdate
          ? _updateLocalAppointmentIfPresent(
              cleanId,
              (item) => item.copyWith(note: cleanNote),
            )
          : state.appointments;

      emit(
        state.copyWith(
          actionStatus: ActionStatus.succeeded,
          appointments: updatedList,
          actionError: null,
          actionSuccessMessage: 'Randevu notu kaydedildi.',
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
          actionError: 'Randevu notu güncellenirken bir hata oluştu.',
          actionSuccessMessage: null,
        ),
      );
    }
  }

  /// Listeleme durumuna dokunmadan yalnızca işlem (action) durumunu ve mesajlarını temizler.
  void clearActionState() {
    emit(
      state.copyWith(
        actionStatus: ActionStatus.idle,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );
  }

  /// Aktif abonelikleri iptal eder ve kullanıcıya özgü tüm randevu verilerini sıfırlar.
  Future<void> reset() async {
    _listOperationToken++;
    _actionOperationToken++;
    _streamRevision++;
    await _cancelSubscription();
    if (!isClosed) {
      emit(const AppointmentState());
    }
  }

  void _subscribeToAppointments(
    Stream<List<Map<String, dynamic>>> Function() streamBuilder,
  ) {
    final token = ++_listOperationToken;
    // Dinlenen hasta/doktor değiştiğinde önceki kullanıcıya ait bekleyen aksiyonları geçersiz kılar.
    _actionOperationToken++;
    _streamRevision++;
    _cancelSubscription();

    emit(
      state.copyWith(
        listStatus: DataStatus.loading,
        actionStatus: ActionStatus.idle,
        appointments: const [],
        listError: null,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    _appointmentsSubscription = streamBuilder().listen(
      (rawItems) {
        if (!_isCurrentListOperation(token)) return;
        _streamRevision++;

        final parsedAppointments = rawItems
            .map((map) => AppointmentModel.fromJson(map))
            .toList(growable: false);

        emit(
          state.copyWith(
            listStatus: parsedAppointments.isEmpty
                ? DataStatus.empty
                : DataStatus.success,
            appointments: parsedAppointments,
            listError: null,
          ),
        );
      },
      onError: (_) {
        if (!_isCurrentListOperation(token)) return;
        _streamRevision++;
        emit(
          state.copyWith(
            listStatus: DataStatus.error,
            listError: 'Randevu verileri alınırken bir hata oluştu.',
          ),
        );
      },
    );
  }

  List<AppointmentModel> _updateLocalAppointmentIfPresent(
    String appointmentId,
    AppointmentModel Function(AppointmentModel current) updater,
  ) {
    if (state.appointments.isEmpty) return state.appointments;
    var changed = false;
    final updated = state.appointments
        .map((item) {
          if (item.id == appointmentId) {
            changed = true;
            return updater(item);
          }
          return item;
        })
        .toList(growable: false);

    return changed ? updated : state.appointments;
  }

  Future<void> _cancelSubscription() async {
    await _appointmentsSubscription?.cancel();
    _appointmentsSubscription = null;
  }

  bool _isCurrentListOperation(int token) =>
      !isClosed && token == _listOperationToken;

  bool _isCurrentActionOperation(int token) =>
      !isClosed && token == _actionOperationToken;

  @override
  Future<void> close() async {
    _listOperationToken++;
    _actionOperationToken++;
    await _cancelSubscription();
    return super.close();
  }
}
