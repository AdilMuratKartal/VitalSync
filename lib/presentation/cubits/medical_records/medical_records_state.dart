import '../../../data/models/prescription_model.dart';
import '../../../data/models/result_model.dart';
import '../cubit_status.dart';

/// Hasta tahlil/röntgen sonuçları ile e-reçete kayıtlarının akış ve işlem durumlarını birbirinden bağımsız tutar.
class MedicalRecordsState {
  static const Object _unset = Object();

  final DataStatus resultsStatus;
  final DataStatus prescriptionsStatus;
  final ActionStatus actionStatus;
  final List<ResultModel> results;
  final List<PrescriptionModel> prescriptions;
  final double? uploadProgress;
  final String? resultsError;
  final String? prescriptionsError;
  final String? actionError;
  final String? actionSuccessMessage;

  const MedicalRecordsState({
    this.resultsStatus = DataStatus.initial,
    this.prescriptionsStatus = DataStatus.initial,
    this.actionStatus = ActionStatus.idle,
    this.results = const [],
    this.prescriptions = const [],
    this.uploadProgress,
    this.resultsError,
    this.prescriptionsError,
    this.actionError,
    this.actionSuccessMessage,
  });

  /// Hazır ('ready') durumundaki sonuçlar.
  List<ResultModel> get readyResults =>
      results.where((item) => item.isReady).toList(growable: false);

  /// Kategoriye ('radiology', 'lab', 'report' veya 'all') göre filtrelenmiş sonuçlar.
  List<ResultModel> resultsByCategory(String category) {
    final cleanCategory = category.trim().toLowerCase();
    if (cleanCategory.isEmpty || cleanCategory == 'all') {
      return results;
    }
    return results
        .where((item) => item.category.toLowerCase() == cleanCategory)
        .toList(growable: false);
  }

  /// Onaylanmış (değiştirilemez) reçeteler.
  List<PrescriptionModel> get approvedPrescriptions =>
      prescriptions.where((item) => item.isApproved).toList(growable: false);

  /// Henüz onaylanmamış taslak reçeteler.
  List<PrescriptionModel> get draftPrescriptions =>
      prescriptions.where((item) => !item.isApproved).toList(growable: false);

  MedicalRecordsState copyWith({
    DataStatus? resultsStatus,
    DataStatus? prescriptionsStatus,
    ActionStatus? actionStatus,
    List<ResultModel>? results,
    List<PrescriptionModel>? prescriptions,
    Object? uploadProgress = _unset,
    Object? resultsError = _unset,
    Object? prescriptionsError = _unset,
    Object? actionError = _unset,
    Object? actionSuccessMessage = _unset,
  }) {
    return MedicalRecordsState(
      resultsStatus: resultsStatus ?? this.resultsStatus,
      prescriptionsStatus: prescriptionsStatus ?? this.prescriptionsStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      results: results ?? this.results,
      prescriptions: prescriptions ?? this.prescriptions,
      uploadProgress: identical(uploadProgress, _unset)
          ? this.uploadProgress
          : uploadProgress as double?,
      resultsError: identical(resultsError, _unset)
          ? this.resultsError
          : resultsError as String?,
      prescriptionsError: identical(prescriptionsError, _unset)
          ? this.prescriptionsError
          : prescriptionsError as String?,
      actionError: identical(actionError, _unset)
          ? this.actionError
          : actionError as String?,
      actionSuccessMessage: identical(actionSuccessMessage, _unset)
          ? this.actionSuccessMessage
          : actionSuccessMessage as String?,
    );
  }
}

