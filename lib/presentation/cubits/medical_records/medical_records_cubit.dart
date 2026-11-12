import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/prescription_model.dart';
import '../../../data/models/result_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/storage_service.dart';
import '../cubit_status.dart';
import 'medical_records_state.dart';

/// Hasta sonuçları (röntgen/tahlil), e-reçete işlemleri ve belge yükleme akışlarını yönetir.
class MedicalRecordsCubit extends Cubit<MedicalRecordsState> {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  StreamSubscription<List<Map<String, dynamic>>>? _resultsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _prescriptionsSubscription;

  int _resultsOperationToken = 0;
  int _prescriptionsOperationToken = 0;
  int _actionOperationToken = 0;
  int _prescriptionsRevision = 0;

  String? _watchedResultsPatientId;
  String? _watchedPrescriptionsOwnerKey;

  MedicalRecordsCubit({
    FirestoreService? firestoreService,
    StorageService? storageService,
  })  : _firestoreService =
            firestoreService ?? ServiceLocator.get<FirestoreService>(),
        _storageService =
            storageService ?? ServiceLocator.get<StorageService>(),
        super(const MedicalRecordsState());

  /// Hastanın hem sonuç (röntgen/tahlil) hem de reçete akışlarını birbirinden bağımsız başlatır.
  void watchPatientRecords(String patientId) {
    watchPatientResults(patientId);
    watchPatientPrescriptions(patientId);
  }

  /// Hastanın tahlil ve röntgen sonuçlarını gerçek zamanlı dinler; reçete listesini etkilemez.
  void watchPatientResults(String patientId) {
    final cleanPatientId = patientId.trim();
    if (cleanPatientId.isEmpty) {
      _resultsOperationToken++;
      _watchedResultsPatientId = null;
      _cancelResultsSubscription();
      emit(
        state.copyWith(
          resultsStatus: DataStatus.error,
          results: const [],
          resultsError:
              'Sonuçları görüntülemek için geçerli hasta kimliği gerekli.',
        ),
      );
      return;
    }

    if (_watchedResultsPatientId != null &&
        _watchedResultsPatientId != cleanPatientId) {
      _actionOperationToken++;
    }
    _watchedResultsPatientId = cleanPatientId;

    final token = ++_resultsOperationToken;
    _cancelResultsSubscription();

    emit(
      state.copyWith(
        resultsStatus: DataStatus.loading,
        results: const [],
        resultsError: null,
      ),
    );

    _resultsSubscription = _firestoreService
        .streamResultsByPatient(cleanPatientId)
        .listen(
          (rawItems) {
            if (!_isCurrentResultsOperation(token)) return;

            final parsedResults = rawItems
                .map((map) => ResultModel.fromJson(map))
                .toList(growable: false);

            emit(
              state.copyWith(
                resultsStatus: parsedResults.isEmpty
                    ? DataStatus.empty
                    : DataStatus.success,
                results: parsedResults,
                resultsError: null,
              ),
            );
          },
          onError: (_) {
            if (!_isCurrentResultsOperation(token)) return;
            emit(
              state.copyWith(
                resultsStatus: DataStatus.error,
                resultsError: 'Hasta sonuçları alınırken bir hata oluştu.',
              ),
            );
          },
        );
  }

  /// Hastanın reçetelerini gerçek zamanlı dinler; sonuç listesini etkilemez.
  void watchPatientPrescriptions(String patientId) {
    final cleanPatientId = patientId.trim();
    if (cleanPatientId.isEmpty) {
      _prescriptionsOperationToken++;
      _prescriptionsRevision++;
      _watchedPrescriptionsOwnerKey = null;
      _cancelPrescriptionsSubscription();
      emit(
        state.copyWith(
          prescriptionsStatus: DataStatus.error,
          prescriptions: const [],
          prescriptionsError:
              'Reçeteleri görüntülemek için geçerli hasta kimliği gerekli.',
        ),
      );
      return;
    }

    _subscribeToPrescriptions(
      ownerKey: 'patient:$cleanPatientId',
      streamBuilder: () =>
          _firestoreService.streamPrescriptionsByPatient(cleanPatientId),
    );
  }

  /// Doktorun oluşturduğu reçeteleri gerçek zamanlı dinler.
  void watchDoctorPrescriptions(String doctorId) {
    final cleanDoctorId = doctorId.trim();
    if (cleanDoctorId.isEmpty) {
      _prescriptionsOperationToken++;
      _prescriptionsRevision++;
      _watchedPrescriptionsOwnerKey = null;
      _cancelPrescriptionsSubscription();
      emit(
        state.copyWith(
          prescriptionsStatus: DataStatus.error,
          prescriptions: const [],
          prescriptionsError:
              'Reçeteleri görüntülemek için geçerli doktor kimliği gerekli.',
        ),
      );
      return;
    }

    _subscribeToPrescriptions(
      ownerKey: 'doctor:$cleanDoctorId',
      streamBuilder: () =>
          _firestoreService.streamPrescriptionsByDoctor(cleanDoctorId),
    );
  }

  /// Doktorun oluşturduğu reçeteleri tek seferlik getirir.
  Future<void> loadDoctorPrescriptions(String doctorId) async {
    final cleanDoctorId = doctorId.trim();
    if (cleanDoctorId.isEmpty) {
      _prescriptionsOperationToken++;
      _prescriptionsRevision++;
      _watchedPrescriptionsOwnerKey = null;
      await _cancelPrescriptionsSubscription();
      emit(
        state.copyWith(
          prescriptionsStatus: DataStatus.error,
          prescriptions: const [],
          prescriptionsError:
              'Reçeteleri yüklemek için geçerli doktor kimliği gerekli.',
        ),
      );
      return;
    }

    await _loadPrescriptionsOnce(
      ownerKey: 'doctor:$cleanDoctorId',
      loader: () => _firestoreService.getPrescriptionsByDoctor(cleanDoctorId),
    );
  }

  /// Hastanın reçetelerini tek seferlik getirir.
  Future<void> loadPatientPrescriptions(String patientId) async {
    final cleanPatientId = patientId.trim();
    if (cleanPatientId.isEmpty) {
      _prescriptionsOperationToken++;
      _prescriptionsRevision++;
      _watchedPrescriptionsOwnerKey = null;
      await _cancelPrescriptionsSubscription();
      emit(
        state.copyWith(
          prescriptionsStatus: DataStatus.error,
          prescriptions: const [],
          prescriptionsError:
              'Reçeteleri yüklemek için geçerli hasta kimliği gerekli.',
        ),
      );
      return;
    }

    await _loadPrescriptionsOnce(
      ownerKey: 'patient:$cleanPatientId',
      loader: () => _firestoreService.getPrescriptionsByPatient(cleanPatientId),
    );
  }

  /// Yeni e-reçete oluşturur; mevcut sonuç ve reçete listelerini bozmaz.
  Future<String?> createPrescription(PrescriptionModel prescription) async {
    final validationError = _validatePrescription(prescription);
    if (validationError != null) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: validationError,
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
      final payload = Map<String, dynamic>.from(prescription.toJson());
      if (prescription.id.trim().isEmpty) {
        payload.remove('id');
      }

      final createdId = await _firestoreService.createPrescription(payload);
      if (!_isCurrentActionOperation(token)) return null;

      emit(
        state.copyWith(
          actionStatus: ActionStatus.succeeded,
          actionError: null,
          actionSuccessMessage: 'Reçete başarıyla oluşturuldu.',
        ),
      );
      return createdId;
    } on FirestoreServiceException catch (e) {
      if (!_isCurrentActionOperation(token)) return null;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: e.message,
          actionSuccessMessage: null,
        ),
      );
      return null;
    } catch (_) {
      if (!_isCurrentActionOperation(token)) return null;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Reçete oluşturulurken bir hata oluştu.',
          actionSuccessMessage: null,
        ),
      );
      return null;
    }
  }

  /// Henüz onaylanmamış bir reçeteyi günceller; onaylanmış (isApproved == true) reçetelerin değiştirilmesini engeller.
  Future<void> updatePrescription(PrescriptionModel prescription) async {
    final cleanId = prescription.id.trim();
    if (cleanId.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Güncellenecek reçete kimliği geçerli olmalıdır.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final validationError = _validatePrescription(prescription);
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

    // 1. Yerel listede reçete onaylanmış görünüyorsa doğrudan engeller.
    final localMatch = state.prescriptions
        .where((item) => item.id == cleanId)
        .firstOrNull;
    if (localMatch != null && localMatch.isApproved) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Onaylanmış reçete üzerinde değişiklik yapılamaz.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final token = ++_actionOperationToken;
    final prescriptionsTokenAtStart = _prescriptionsOperationToken;
    final revisionAtStart = _prescriptionsRevision;

    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    try {
      // 2. Eşzamanlı onaylanmalara karşı Firestore'daki güncel belgeyi kontrol eder.
      final remoteDoc = await _firestoreService.getPrescription(cleanId);
      if (!_isCurrentActionOperation(token)) return;

      if (remoteDoc == null) {
        emit(
          state.copyWith(
            actionStatus: ActionStatus.failed,
            actionError: 'Güncellenmek istenen reçete kaydı bulunamadı.',
            actionSuccessMessage: null,
          ),
        );
        return;
      }

      final remotePrescription = PrescriptionModel.fromJson(
        remoteDoc,
        id: cleanId,
      );
      if (remotePrescription.isApproved) {
        emit(
          state.copyWith(
            actionStatus: ActionStatus.failed,
            actionError: 'Onaylanmış reçete üzerinde değişiklik yapılamaz.',
            actionSuccessMessage: null,
          ),
        );
        return;
      }

      await _firestoreService.updatePrescription(
        cleanId,
        prescription.toJson(),
      );
      if (!_isCurrentActionOperation(token)) return;

      final canApplyLocalUpdate =
          prescriptionsTokenAtStart == _prescriptionsOperationToken &&
              revisionAtStart == _prescriptionsRevision;

      final updatedList = canApplyLocalUpdate
          ? state.prescriptions.map((item) {
              if (item.id == cleanId) return prescription;
              return item;
            }).toList(growable: false)
          : state.prescriptions;

      emit(
        state.copyWith(
          actionStatus: ActionStatus.succeeded,
          prescriptions: updatedList,
          actionError: null,
          actionSuccessMessage: 'Reçete güncellendi.',
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
          actionError: 'Reçete güncellenirken bir hata oluştu.',
          actionSuccessMessage: null,
        ),
      );
    }
  }

  /// Hasta röntgen veya tıbbi belgesini StorageService üzerinden yükler ve Firestore'a kaydeder.
  Future<String?> uploadPatientDocument({
    required String patientId,
    required String title,
    Uint8List? bytes,
    String? fileName,
    String contentType = 'image/png',
    String? existingRecordId,
    String? doctorId,
    String? note,
  }) async {
    final cleanPatientId = patientId.trim();
    final cleanTitle = title.trim();

    if (cleanPatientId.isEmpty || cleanTitle.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          uploadProgress: null,
          actionError:
              'Belge yüklemek için hasta kimliği ve belge başlığı zorunludur.',
          actionSuccessMessage: null,
        ),
      );
      return null;
    }

    final token = ++_actionOperationToken;
    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        uploadProgress: 0.0,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    try {
      final downloadUrl = await _storageService.uploadAndSavePatientDocument(
        patientId: cleanPatientId,
        title: cleanTitle,
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
        existingRecordId: existingRecordId,
        doctorId: doctorId,
        note: note,
        onProgress: (progress) {
          if (!_isCurrentActionOperation(token)) return;
          final normalizedProgress = progress.clamp(0.0, 1.0);
          emit(state.copyWith(uploadProgress: normalizedProgress));
        },
      );

      if (!_isCurrentActionOperation(token)) return null;

      emit(
        state.copyWith(
          actionStatus: ActionStatus.succeeded,
          uploadProgress: 1.0,
          actionError: null,
          actionSuccessMessage: 'Belge başarıyla kaydedildi.',
        ),
      );
      return downloadUrl;
    } on FirestoreServiceException catch (e) {
      if (!_isCurrentActionOperation(token)) return null;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          uploadProgress: null,
          actionError: e.message,
          actionSuccessMessage: null,
        ),
      );
      return null;
    } catch (_) {
      if (!_isCurrentActionOperation(token)) return null;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          uploadProgress: null,
          actionError: 'Belge yüklenirken bir hata oluştu.',
          actionSuccessMessage: null,
        ),
      );
      return null;
    }
  }

  /// Sonuç ve reçete listelerine dokunmadan yalnızca işlem (action) durumunu ve mesajlarını temizler.
  void clearActionState() {
    emit(
      state.copyWith(
        actionStatus: ActionStatus.idle,
        uploadProgress: null,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );
  }

  /// Aktif abonelikleri iptal eder ve kullanıcıya özgü tüm sonuç/reçete verilerini sıfırlar.
  Future<void> reset() async {
    _resultsOperationToken++;
    _prescriptionsOperationToken++;
    _actionOperationToken++;
    _prescriptionsRevision++;
    _watchedResultsPatientId = null;
    _watchedPrescriptionsOwnerKey = null;
    await _cancelAllSubscriptions();
    if (!isClosed) {
      emit(const MedicalRecordsState());
    }
  }

  void _subscribeToPrescriptions({
    required String ownerKey,
    required Stream<List<Map<String, dynamic>>> Function() streamBuilder,
  }) {
    if (_watchedPrescriptionsOwnerKey != null &&
        _watchedPrescriptionsOwnerKey != ownerKey) {
      _actionOperationToken++;
    }
    _watchedPrescriptionsOwnerKey = ownerKey;

    final token = ++_prescriptionsOperationToken;
    _prescriptionsRevision++;
    _cancelPrescriptionsSubscription();

    emit(
      state.copyWith(
        prescriptionsStatus: DataStatus.loading,
        prescriptions: const [],
        prescriptionsError: null,
      ),
    );

    _prescriptionsSubscription = streamBuilder().listen(
      (rawItems) {
        if (!_isCurrentPrescriptionsOperation(token)) return;
        _prescriptionsRevision++;

        final parsedPrescriptions = rawItems
            .map((map) => PrescriptionModel.fromJson(map))
            .toList(growable: false);

        emit(
          state.copyWith(
            prescriptionsStatus: parsedPrescriptions.isEmpty
                ? DataStatus.empty
                : DataStatus.success,
            prescriptions: parsedPrescriptions,
            prescriptionsError: null,
          ),
        );
      },
      onError: (_) {
        if (!_isCurrentPrescriptionsOperation(token)) return;
        _prescriptionsRevision++;
        emit(
          state.copyWith(
            prescriptionsStatus: DataStatus.error,
            prescriptionsError: 'Reçete kayıtları alınırken bir hata oluştu.',
          ),
        );
      },
    );
  }

  Future<void> _loadPrescriptionsOnce({
    required String ownerKey,
    required Future<List<Map<String, dynamic>>> Function() loader,
  }) async {
    if (_watchedPrescriptionsOwnerKey != null &&
        _watchedPrescriptionsOwnerKey != ownerKey) {
      _actionOperationToken++;
    }
    _watchedPrescriptionsOwnerKey = ownerKey;

    final token = ++_prescriptionsOperationToken;
    _prescriptionsRevision++;
    await _cancelPrescriptionsSubscription();

    emit(
      state.copyWith(
        prescriptionsStatus: DataStatus.loading,
        prescriptionsError: null,
      ),
    );

    try {
      final rawItems = await loader();
      if (!_isCurrentPrescriptionsOperation(token)) return;
      _prescriptionsRevision++;

      final parsedPrescriptions = rawItems
          .map((map) => PrescriptionModel.fromJson(map))
          .toList(growable: false);

      emit(
        state.copyWith(
          prescriptionsStatus: parsedPrescriptions.isEmpty
              ? DataStatus.empty
              : DataStatus.success,
          prescriptions: parsedPrescriptions,
          prescriptionsError: null,
        ),
      );
    } on FirestoreServiceException catch (e) {
      if (!_isCurrentPrescriptionsOperation(token)) return;
      emit(
        state.copyWith(
          prescriptionsStatus: DataStatus.error,
          prescriptionsError: e.message,
        ),
      );
    } catch (_) {
      if (!_isCurrentPrescriptionsOperation(token)) return;
      emit(
        state.copyWith(
          prescriptionsStatus: DataStatus.error,
          prescriptionsError: 'Reçeteler yüklenirken bir hata oluştu.',
        ),
      );
    }
  }

  String? _validatePrescription(PrescriptionModel prescription) {
    if (prescription.patientId.trim().isEmpty) {
      return 'Reçete için geçerli hasta kimliği zorunludur.';
    }
    if (prescription.doctorId.trim().isEmpty) {
      return 'Reçete için geçerli doktor kimliği zorunludur.';
    }
    if (prescription.diagnosis.trim().isEmpty) {
      return 'Reçete tanı (ICD-10) bilgisi boş bırakılamaz.';
    }
    if (prescription.medicines.isEmpty) {
      return 'Reçetede en az bir ilaç kalemi bulunmalıdır.';
    }
    final hasEmptyMedicineName = prescription.medicines.any(
      (item) => item.name.trim().isEmpty,
    );
    if (hasEmptyMedicineName) {
      return 'Reçetedeki tüm ilaçların adı eksiksiz girilmelidir.';
    }
    return null;
  }

  Future<void> _cancelResultsSubscription() async {
    await _resultsSubscription?.cancel();
    _resultsSubscription = null;
  }

  Future<void> _cancelPrescriptionsSubscription() async {
    await _prescriptionsSubscription?.cancel();
    _prescriptionsSubscription = null;
  }

  Future<void> _cancelAllSubscriptions() async {
    await _cancelResultsSubscription();
    await _cancelPrescriptionsSubscription();
  }

  bool _isCurrentResultsOperation(int token) =>
      !isClosed && token == _resultsOperationToken;

  bool _isCurrentPrescriptionsOperation(int token) =>
      !isClosed && token == _prescriptionsOperationToken;

  bool _isCurrentActionOperation(int token) =>
      !isClosed && token == _actionOperationToken;

  @override
  Future<void> close() async {
    _resultsOperationToken++;
    _prescriptionsOperationToken++;
    _actionOperationToken++;
    _prescriptionsRevision++;
    await _cancelAllSubscriptions();
    return super.close();
  }
}

