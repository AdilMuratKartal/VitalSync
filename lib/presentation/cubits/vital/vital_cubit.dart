import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/vital_model.dart';
import '../../../data/services/firestore_service.dart';
import '../cubit_status.dart';
import 'vital_state.dart';

/// Hastanın yaşamsal sağlık ölçümlerini (tansiyon, şeker, nabız, SpO2) dinler ve kaydeder.
class VitalCubit extends Cubit<VitalState> {
  final FirestoreService _firestoreService;

  StreamSubscription<List<Map<String, dynamic>>>? _vitalsSubscription;
  int _dataOperationToken = 0;
  int _actionOperationToken = 0;
  int _vitalsRevision = 0;
  String? _watchedPatientId;

  VitalCubit({FirestoreService? firestoreService})
      : _firestoreService =
            firestoreService ?? ServiceLocator.get<FirestoreService>(),
        super(const VitalState());

  /// Belirtilen hastanın sağlık ölçümlerini gerçek zamanlı olarak dinler.
  void watchPatientVitals(String patientId) {
    final cleanPatientId = patientId.trim();
    if (cleanPatientId.isEmpty) {
      _invalidateOperations();
      _watchedPatientId = null;
      _cancelSubscription();
      emit(
        state.copyWith(
          dataStatus: DataStatus.error,
          vitals: const [],
          dataError:
              'Sağlık verilerini görüntülemek için geçerli hasta kimliği gerekli.',
        ),
      );
      return;
    }

    if (_watchedPatientId != null && _watchedPatientId != cleanPatientId) {
      _actionOperationToken++;
    }
    _watchedPatientId = cleanPatientId;

    final token = ++_dataOperationToken;
    _vitalsRevision++;
    _cancelSubscription();

    emit(
      state.copyWith(
        dataStatus: DataStatus.loading,
        vitals: const [],
        dataError: null,
      ),
    );

    _vitalsSubscription = _firestoreService
        .streamVitalsByPatient(cleanPatientId)
        .listen(
          (rawItems) {
            if (!_isCurrentDataOperation(token)) return;
            _vitalsRevision++;

            final parsedVitals = _parseAndSortVitals(rawItems);

            emit(
              state.copyWith(
                dataStatus: parsedVitals.isEmpty
                    ? DataStatus.empty
                    : DataStatus.success,
                vitals: parsedVitals,
                dataError: null,
              ),
            );
          },
          onError: (_) {
            if (!_isCurrentDataOperation(token)) return;
            _vitalsRevision++;
            emit(
              state.copyWith(
                dataStatus: DataStatus.error,
                dataError: 'Sağlık ölçümleri alınırken bir hata oluştu.',
              ),
            );
          },
        );
  }

  /// Belirtilen hastanın sağlık ölçümlerini tek seferlik yükler.
  Future<void> loadPatientVitals(String patientId) async {
    final cleanPatientId = patientId.trim();
    if (cleanPatientId.isEmpty) {
      _invalidateOperations();
      _watchedPatientId = null;
      await _cancelSubscription();
      emit(
        state.copyWith(
          dataStatus: DataStatus.error,
          vitals: const [],
          dataError:
              'Sağlık verilerini yüklemek için geçerli hasta kimliği gerekli.',
        ),
      );
      return;
    }

    if (_watchedPatientId != null && _watchedPatientId != cleanPatientId) {
      _actionOperationToken++;
    }
    _watchedPatientId = cleanPatientId;

    final token = ++_dataOperationToken;
    _vitalsRevision++;
    await _cancelSubscription();

    emit(
      state.copyWith(
        dataStatus: DataStatus.loading,
        dataError: null,
      ),
    );

    try {
      final rawItems = await _firestoreService.getCollection(
        AppConstants.vitalsCollection,
        filterField: 'patientId',
        isEqualTo: cleanPatientId,
        orderByField: 'createdAt',
        descending: true,
      );

      if (!_isCurrentDataOperation(token)) return;
      _vitalsRevision++;

      final parsedVitals = _parseAndSortVitals(rawItems);

      emit(
        state.copyWith(
          dataStatus:
              parsedVitals.isEmpty ? DataStatus.empty : DataStatus.success,
          vitals: parsedVitals,
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
          dataError: 'Sağlık ölçümleri yüklenirken bir hata oluştu.',
        ),
      );
    }
  }

  /// Yeni bir sağlık ölçümünü doğrulayarak kaydeder; mevcut ölçüm listesini temizlemez.
  Future<String?> createVital(VitalModel vital) async {
    final validationError = _validateVital(vital);
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
    final dataTokenAtStart = _dataOperationToken;
    final revisionAtStart = _vitalsRevision;

    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    try {
      final payload = Map<String, dynamic>.from(vital.toJson());
      if (vital.id.trim().isEmpty) {
        payload.remove('id');
      }

      final createdId = await _firestoreService.createVital(payload);
      if (!_isCurrentActionOperation(token)) return null;

      final savedVital = vital.copyWith(id: createdId);
      final canApplyLocalInsert = dataTokenAtStart == _dataOperationToken &&
          revisionAtStart == _vitalsRevision &&
          (_watchedPatientId == null ||
              _watchedPatientId == savedVital.patientId.trim());

      List<VitalModel> updatedVitals = state.vitals;
      DataStatus nextDataStatus = state.dataStatus;

      if (canApplyLocalInsert) {
        final merged = <VitalModel>[
          savedVital,
          ...state.vitals.where((item) => item.id != createdId),
        ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        updatedVitals = List<VitalModel>.unmodifiable(merged);
        nextDataStatus = DataStatus.success;
      }

      // VitalModel.isCritical kuralına göre tıbbi tanı koymadan bilgilendirici mesaj üretir.
      final message = savedVital.isCritical
          ? 'Ölçüm kaydedildi. Bazı değerler referans aralığı dışında görünüyor; kontrol için hekiminizle paylaşabilirsiniz.'
          : 'Yeni sağlık ölçüm değerleriniz kaydedildi.';

      emit(
        state.copyWith(
          dataStatus: nextDataStatus,
          actionStatus: ActionStatus.succeeded,
          vitals: updatedVitals,
          actionError: null,
          actionSuccessMessage: message,
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
          actionError: 'Sağlık ölçümü kaydedilirken bir hata oluştu.',
          actionSuccessMessage: null,
        ),
      );
      return null;
    }
  }

  /// Form alanlarından gelen sayısal değerlerle yeni bir VitalModel oluşturup kaydeder.
  Future<String?> recordVital({
    required String patientId,
    required int systolic,
    required int diastolic,
    required int bloodSugar,
    required int pulse,
    int oxygen = 98,
    DateTime? createdAt,
  }) {
    final model = VitalModel(
      id: '',
      patientId: patientId.trim(),
      systolic: systolic,
      diastolic: diastolic,
      bloodSugar: bloodSugar,
      pulse: pulse,
      oxygen: oxygen,
      createdAt: createdAt ?? DateTime.now(),
    );
    return createVital(model);
  }

  /// Mevcut bir sağlık ölçüm kaydını doğrulayarak günceller.
  Future<void> updateVital(VitalModel vital) async {
    final cleanId = vital.id.trim();
    if (cleanId.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: 'Güncellenecek ölçüm kaydının kimliği geçerli olmalıdır.',
          actionSuccessMessage: null,
        ),
      );
      return;
    }

    final validationError = _validateVital(vital);
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
    final revisionAtStart = _vitalsRevision;

    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );

    try {
      await _firestoreService.updateDocument(
        AppConstants.vitalsCollection,
        cleanId,
        vital.toJson(),
      );
      if (!_isCurrentActionOperation(token)) return;

      final canApplyLocalUpdate = dataTokenAtStart == _dataOperationToken &&
          revisionAtStart == _vitalsRevision;

      List<VitalModel> updatedVitals = state.vitals;
      if (canApplyLocalUpdate && state.vitals.isNotEmpty) {
        final modified = state.vitals.map((item) {
          if (item.id == cleanId) return vital;
          return item;
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        updatedVitals = List<VitalModel>.unmodifiable(modified);
      }

      emit(
        state.copyWith(
          actionStatus: ActionStatus.succeeded,
          vitals: updatedVitals,
          actionError: null,
          actionSuccessMessage: 'Sağlık ölçüm kaydı güncellendi.',
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
          actionError: 'Sağlık ölçümü güncellenirken bir hata oluştu.',
          actionSuccessMessage: null,
        ),
      );
    }
  }

  /// Ölçüm listesine dokunmadan yalnızca işlem (action) durumunu ve mesajlarını sıfırlar.
  void clearActionState() {
    emit(
      state.copyWith(
        actionStatus: ActionStatus.idle,
        actionError: null,
        actionSuccessMessage: null,
      ),
    );
  }

  /// Aktif aboneliği iptal eder ve hastaya özgü tüm sağlık ölçüm verilerini sıfırlar.
  Future<void> reset() async {
    _invalidateOperations();
    _watchedPatientId = null;
    await _cancelSubscription();
    if (!isClosed) {
      emit(const VitalState());
    }
  }

  List<VitalModel> _parseAndSortVitals(List<Map<String, dynamic>> rawItems) {
    final parsed = rawItems.map((map) => VitalModel.fromJson(map)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<VitalModel>.unmodifiable(parsed);
  }

  /// Tıbbi tanı eşiği koymadan yalnızca veri bütünlüğünü ve sayısal geçerliliği kontrol eder.
  String? _validateVital(VitalModel vital) {
    if (vital.patientId.trim().isEmpty) {
      return 'Ölçüm kaydı için geçerli hasta kimliği zorunludur.';
    }
    if (vital.systolic <= 0 || vital.diastolic <= 0) {
      return 'Tansiyon değerleri sıfırdan büyük olmalıdır.';
    }
    if (vital.systolic <= vital.diastolic) {
      return 'Büyük tansiyon (sistolik), küçük tansiyondan (diyastolik) büyük olmalıdır.';
    }
    if (vital.bloodSugar <= 0) {
      return 'Kan şekeri değeri sıfırdan büyük olmalıdır.';
    }
    if (vital.pulse <= 0) {
      return 'Nabız değeri sıfırdan büyük olmalıdır.';
    }
    if (vital.oxygen <= 0 || vital.oxygen > 100) {
      return 'Oksijen doygunluğu (SpO2) 1 ile 100 arasında olmalıdır.';
    }
    return null;
  }

  void _invalidateOperations() {
    _dataOperationToken++;
    _actionOperationToken++;
    _vitalsRevision++;
  }

  Future<void> _cancelSubscription() async {
    await _vitalsSubscription?.cancel();
    _vitalsSubscription = null;
  }

  bool _isCurrentDataOperation(int token) =>
      !isClosed && token == _dataOperationToken;

  bool _isCurrentActionOperation(int token) =>
      !isClosed && token == _actionOperationToken;

  @override
  Future<void> close() async {
    _invalidateOperations();
    _watchedPatientId = null;
    await _cancelSubscription();
    return super.close();
  }
}

