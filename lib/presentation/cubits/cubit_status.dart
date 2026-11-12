/// Veri yükleyen ve liste gösteren ekranların ortak durum değerleri.
enum DataStatus {
  initial,
  loading,
  empty,
  success,
  error;

  bool get isInitial => this == DataStatus.initial;
  bool get isLoading => this == DataStatus.loading;
  bool get isEmpty => this == DataStatus.empty;
  bool get isSuccess => this == DataStatus.success;
  bool get isError => this == DataStatus.error;
}

/// Kayıt, güncelleme ve silme gibi tekil kullanıcı işlemlerinin durum değerleri.
enum ActionStatus {
  idle,
  submitting,
  succeeded,
  failed;

  bool get isIdle => this == ActionStatus.idle;
  bool get isSubmitting => this == ActionStatus.submitting;
  bool get isSucceeded => this == ActionStatus.succeeded;
  bool get isFailed => this == ActionStatus.failed;
}

