import '../../../data/models/vital_model.dart';
import '../cubit_status.dart';

/// Hastanın yaşamsal sağlık ölçümlerinin (tansiyon, kan şekeri, nabız, SpO2) akış ve işlem durumunu tutar.
class VitalState {
  static const Object _unset = Object();

  final DataStatus dataStatus;
  final ActionStatus actionStatus;
  final List<VitalModel> vitals;
  final String? dataError;
  final String? actionError;
  final String? actionSuccessMessage;

  const VitalState({
    this.dataStatus = DataStatus.initial,
    this.actionStatus = ActionStatus.idle,
    this.vitals = const [],
    this.dataError,
    this.actionError,
    this.actionSuccessMessage,
  });

  /// Ölçümleri en yeniden en eskiye doğru (createdAt azalan) sıralı döndürür.
  List<VitalModel> get sortedByNewest {
    if (vitals.length <= 1) return vitals;
    final copy = List<VitalModel>.from(vitals)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<VitalModel>.unmodifiable(copy);
  }

  /// Grafik çizimleri için ölçümleri en eskiden en yeniye doğru (kronolojik) sıralı döndürür.
  List<VitalModel> get chronologicalVitals {
    if (vitals.isEmpty) return const [];
    final copy = List<VitalModel>.from(vitals)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List<VitalModel>.unmodifiable(copy);
  }

  /// Kaydedilmiş en güncel sağlık ölçümü; kayıt yoksa null döner.
  VitalModel? get latestVital {
    final newest = sortedByNewest;
    return newest.isEmpty ? null : newest.first;
  }

  /// Mevcut VitalModel.isCritical kuralına göre referans eşik dışındaki ölçümler.
  List<VitalModel> get criticalVitals => sortedByNewest
      .where((item) => item.isCritical)
      .toList(growable: false);

  /// Listede en az bir kritik eşik ölçümü bulunup bulunmadığını belirtir.
  bool get hasCriticalVital => criticalVitals.isNotEmpty;

  /// En güncel ölçümün VitalModel.isCritical kuralına göre kritik eşikte olup olmadığını belirtir.
  bool get isLatestVitalCritical => latestVital?.isCritical ?? false;

  /// Belirtilen gün aralığı (örn. 7 veya 30 gün) için kronolojik grafik verilerini döndürür.
  List<VitalModel> chartVitalsForPeriod({int? days, int? maxPoints}) {
    var ordered = chronologicalVitals;
    if (ordered.isEmpty) return const [];

    if (days != null && days > 0) {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      ordered = ordered
          .where((item) => !item.createdAt.isBefore(cutoff))
          .toList(growable: false);
    }

    if (maxPoints != null && maxPoints > 0 && ordered.length > maxPoints) {
      ordered = ordered.sublist(ordered.length - maxPoints);
    }

    return ordered;
  }

  VitalState copyWith({
    DataStatus? dataStatus,
    ActionStatus? actionStatus,
    List<VitalModel>? vitals,
    Object? dataError = _unset,
    Object? actionError = _unset,
    Object? actionSuccessMessage = _unset,
  }) {
    return VitalState(
      dataStatus: dataStatus ?? this.dataStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      vitals: vitals ?? this.vitals,
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

