import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../cubit_status.dart';

/// Kullanıcının uygulama içi oturum durumunu temsil eder.
enum AuthSessionStatus {
  initial,
  checking,
  authenticated,
  unauthenticated,
  profileUnavailable;

  bool get isInitial => this == AuthSessionStatus.initial;
  bool get isChecking => this == AuthSessionStatus.checking;
  bool get isAuthenticated => this == AuthSessionStatus.authenticated;
  bool get isUnauthenticated => this == AuthSessionStatus.unauthenticated;
  bool get isProfileUnavailable => this == AuthSessionStatus.profileUnavailable;
}

/// Kimlik doğrulama, oturum, rol ve kullanıcı profili durumlarını tutar.
class AuthState {
  static const Object _unset = Object();

  final AuthSessionStatus sessionStatus;
  final ActionStatus actionStatus;
  final String? authUid;
  final UserModel? user;
  final String? role;
  final String? errorMessage;
  final String? infoMessage;

  const AuthState({
    this.sessionStatus = AuthSessionStatus.initial,
    this.actionStatus = ActionStatus.idle,
    this.authUid,
    this.user,
    this.role,
    this.errorMessage,
    this.infoMessage,
  });

  /// Firebase Auth üzerinde aktif bir oturum kimliği olup olmadığını belirtir.
  bool get hasFirebaseSession => authUid != null && authUid!.isNotEmpty;

  /// Kullanıcı profilinin ve geçerli rol bilgisinin doğrulanmış olup olmadığını belirtir.
  bool get hasResolvedProfile =>
      user != null &&
      (role == AppConstants.rolePatient || role == AppConstants.roleDoctor);

  /// Yalnızca oturum ve Firestore profili/rolü birlikte doğrulandığında true döner.
  bool get isAuthenticated =>
      sessionStatus.isAuthenticated && hasFirebaseSession && hasResolvedProfile;

  /// Doğrulanmış kullanıcının doktor rolünde olup olmadığını belirtir.
  bool get isDoctor => isAuthenticated && role == AppConstants.roleDoctor;

  /// Doğrulanmış kullanıcının hasta rolünde olup olmadığını belirtir.
  bool get isPatient => isAuthenticated && role == AppConstants.rolePatient;

  AuthState copyWith({
    AuthSessionStatus? sessionStatus,
    ActionStatus? actionStatus,
    Object? authUid = _unset,
    Object? user = _unset,
    Object? role = _unset,
    Object? errorMessage = _unset,
    Object? infoMessage = _unset,
  }) {
    return AuthState(
      sessionStatus: sessionStatus ?? this.sessionStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      authUid: identical(authUid, _unset) ? this.authUid : authUid as String?,
      user: identical(user, _unset) ? this.user : user as UserModel?,
      role: identical(role, _unset) ? this.role : role as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      infoMessage: identical(infoMessage, _unset)
          ? this.infoMessage
          : infoMessage as String?,
    );
  }
}

