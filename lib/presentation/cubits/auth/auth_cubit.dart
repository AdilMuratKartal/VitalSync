import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/storage_service.dart';
import '../cubit_status.dart';
import 'auth_state.dart';

/// Kimlik doğrulama, oturum yaşam döngüsü, rol doğrulama ve profil işlemlerini yönetir.
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  StreamSubscription<User?>? _authSubscription;
  int _operationToken = 0;
  int _activeExplicitAuthActions = 0;
  bool _hasPendingAuthStreamSync = false;

  AuthCubit({
    AuthService? authService,
    FirestoreService? firestoreService,
    StorageService? storageService,
  })  : _authService = authService ?? ServiceLocator.get<AuthService>(),
        _firestoreService =
            firestoreService ?? ServiceLocator.get<FirestoreService>(),
        _storageService =
            storageService ?? ServiceLocator.get<StorageService>(),
        super(const AuthState());

  /// Tek seferlik aktif oturum ve Firestore profil/rol kontrolü yapar.
  Future<void> checkSession() async {
    final token = ++_operationToken;
    emit(
      state.copyWith(
        sessionStatus: AuthSessionStatus.checking,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null || firebaseUser.uid.isEmpty) {
      if (!_isCurrentOperation(token)) return;
      emit(
        const AuthState(
          sessionStatus: AuthSessionStatus.unauthenticated,
          actionStatus: ActionStatus.idle,
        ),
      );
      return;
    }

    await _resolveUserProfileAndEmit(
      uid: firebaseUser.uid,
      token: token,
      preserveActionStatus: true,
    );
  }

  /// Firebase Auth oturum değişikliklerini gerçek zamanlı dinler.
  void watchAuthState() {
    _authSubscription?.cancel();
    _authSubscription = _authService.authStateChanges.listen(
      (firebaseUser) async {
        if (isClosed) return;

        // Açık bir giriş/kayıt/çıkış işlemi sürerken erken stream olaylarını beklemeye alır.
        if (_activeExplicitAuthActions > 0) {
          _hasPendingAuthStreamSync = true;
          return;
        }

        await _syncWithFirebaseUser(firebaseUser);
      },
      onError: (_) {
        if (isClosed) return;
        emit(
          state.copyWith(
            sessionStatus: AuthSessionStatus.unauthenticated,
            actionStatus: ActionStatus.failed,
            authUid: null,
            user: null,
            role: null,
            errorMessage: 'Oturum durumu dinlenirken bir hata oluştu.',
          ),
        );
      },
    );
  }

  /// E-posta ve şifre ile giriş yapar, ardından kullanıcı profilini ve rolünü doğrular.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final token = ++_operationToken;
    _beginExplicitAuthAction();

    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid ?? _authService.currentUser?.uid;

      if (!_isCurrentOperation(token)) return;

      if (uid == null || uid.isEmpty) {
        emit(
          state.copyWith(
            sessionStatus: AuthSessionStatus.unauthenticated,
            actionStatus: ActionStatus.failed,
            authUid: null,
            user: null,
            role: null,
            errorMessage: 'Giriş yapıldı ancak kullanıcı kimliği alınamadı.',
          ),
        );
        return;
      }

      await _resolveUserProfileAndEmit(
        uid: uid,
        token: token,
        preserveActionStatus: false,
      );
    } on AuthServiceException catch (e) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          sessionStatus: AuthSessionStatus.unauthenticated,
          actionStatus: ActionStatus.failed,
          authUid: null,
          user: null,
          role: null,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          sessionStatus: AuthSessionStatus.unauthenticated,
          actionStatus: ActionStatus.failed,
          authUid: null,
          user: null,
          role: null,
          errorMessage: 'Giriş işlemi sırasında beklenmeyen bir hata oluştu.',
        ),
      );
    } finally {
      _endExplicitAuthAction();
    }
  }

  /// Yeni kullanıcı kaydı oluşturur ve Firestore profilini/rolünü doğrular.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? tcNo,
    String? titleOrInfo,
    Map<String, dynamic>? extraData,
  }) async {
    final normalizedRole = _validateRoleValue(role);
    if (normalizedRole == null) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          errorMessage: 'Geçerli bir kullanıcı rolü seçilmelidir.',
          infoMessage: null,
        ),
      );
      return;
    }

    final token = ++_operationToken;
    _beginExplicitAuthAction();

    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: normalizedRole,
        phone: phone,
        tcNo: tcNo,
        titleOrInfo: titleOrInfo,
        extraData: extraData,
      );

      final uid = credential.user?.uid ?? _authService.currentUser?.uid;
      if (!_isCurrentOperation(token)) return;

      if (uid == null || uid.isEmpty) {
        emit(
          state.copyWith(
            sessionStatus: AuthSessionStatus.unauthenticated,
            actionStatus: ActionStatus.failed,
            authUid: null,
            user: null,
            role: null,
            errorMessage: 'Kayıt tamamlandı ancak kullanıcı kimliği alınamadı.',
          ),
        );
        return;
      }

      await _resolveUserProfileAndEmit(
        uid: uid,
        token: token,
        preserveActionStatus: false,
      );
    } on AuthServiceException catch (e) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          sessionStatus: AuthSessionStatus.unauthenticated,
          actionStatus: ActionStatus.failed,
          authUid: null,
          user: null,
          role: null,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          sessionStatus: AuthSessionStatus.unauthenticated,
          actionStatus: ActionStatus.failed,
          authUid: null,
          user: null,
          role: null,
          errorMessage: 'Kayıt işlemi sırasında beklenmeyen bir hata oluştu.',
        ),
      );
    } finally {
      _endExplicitAuthAction();
    }
  }

  /// Mevcut oturumu kapatır ve kullanıcıya özgü tüm state verilerini temizler.
  Future<void> signOut() async {
    final token = ++_operationToken;
    _beginExplicitAuthAction();

    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    try {
      await _authService.signOut();
      if (!_isCurrentOperation(token)) return;

      emit(
        const AuthState(
          sessionStatus: AuthSessionStatus.unauthenticated,
          actionStatus: ActionStatus.succeeded,
        ),
      );
    } catch (_) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          errorMessage: 'Çıkış yapılırken bir hata oluştu.',
        ),
      );
    } finally {
      _endExplicitAuthAction();
    }
  }

  /// Mevcut oturum durumunu bozmadan şifre sıfırlama e-postası gönderir.
  Future<void> sendPasswordReset({required String email}) async {
    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    try {
      await _authService.sendPasswordResetEmail(email: email);
      if (isClosed) return;

      emit(
        state.copyWith(
          actionStatus: ActionStatus.succeeded,
          errorMessage: null,
          infoMessage:
              'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.',
        ),
      );
    } on AuthServiceException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          errorMessage: e.message,
          infoMessage: null,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          errorMessage: 'Şifre sıfırlama e-postası gönderilemedi.',
          infoMessage: null,
        ),
      );
    }
  }

  /// Aktif Firebase oturumu için Firestore profil ve rol bilgisini yeniden yükler.
  Future<void> refreshProfile() async {
    final uid = state.authUid ?? _authService.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      emit(
        state.copyWith(
          sessionStatus: AuthSessionStatus.unauthenticated,
          actionStatus: ActionStatus.failed,
          authUid: null,
          user: null,
          role: null,
          errorMessage: 'Profil yenilemek için aktif oturum bulunamadı.',
        ),
      );
      return;
    }

    final token = ++_operationToken;
    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    await _resolveUserProfileAndEmit(
      uid: uid,
      token: token,
      preserveActionStatus: false,
    );
  }

  /// Aktif kullanıcının profil alanlarını Firestore üzerinde günceller.
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? tcNo,
    String? titleOrInfo,
  }) async {
    final uid = state.authUid ?? _authService.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          errorMessage: 'Profil güncellemek için aktif oturum bulunamadı.',
          infoMessage: null,
        ),
      );
      return;
    }

    final updates = <String, dynamic>{
      if (fullName != null) 'fullName': fullName.trim(),
      if (phone != null) 'phone': phone.trim(),
      if (tcNo != null) 'tcNo': tcNo.trim(),
      if (titleOrInfo != null) 'titleOrInfo': titleOrInfo.trim(),
    };

    if (updates.isEmpty) return;

    final token = ++_operationToken;
    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    try {
      await _firestoreService.updateUser(uid, updates);
      if (!_isCurrentOperation(token)) return;

      await _resolveUserProfileAndEmit(
        uid: uid,
        token: token,
        preserveActionStatus: false,
        successMessage: 'Profil bilgileriniz güncellendi.',
      );
    } on FirestoreServiceException catch (e) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          errorMessage: e.message,
          infoMessage: null,
        ),
      );
    } catch (_) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          errorMessage: 'Profil güncellenirken bir hata oluştu.',
          infoMessage: null,
        ),
      );
    }
  }

  /// Aktif kullanıcının profil fotoğrafını yükler ve kullanıcı profilini günceller.
  Future<void> uploadProfilePhoto({
    required Uint8List bytes,
    String? fileName,
    void Function(double progress)? onProgress,
  }) async {
    final uid = state.authUid ?? _authService.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          errorMessage:
              'Profil fotoğrafı yüklemek için aktif oturum bulunamadı.',
          infoMessage: null,
        ),
      );
      return;
    }

    final token = ++_operationToken;
    emit(
      state.copyWith(
        actionStatus: ActionStatus.submitting,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    try {
      final downloadUrl = await _storageService.uploadAndSaveProfilePhoto(
        userId: uid,
        bytes: bytes,
        fileName: fileName,
        onProgress: onProgress,
      );

      if (!_isCurrentOperation(token)) return;

      final currentUserModel = state.user;
      if (currentUserModel != null) {
        emit(
          state.copyWith(
            actionStatus: ActionStatus.succeeded,
            user: currentUserModel.copyWith(avatarUrl: downloadUrl),
            errorMessage: null,
            infoMessage: 'Profil fotoğrafınız güncellendi.',
          ),
        );
      } else {
        await _resolveUserProfileAndEmit(
          uid: uid,
          token: token,
          preserveActionStatus: false,
          successMessage: 'Profil fotoğrafınız güncellendi.',
        );
      }
    } catch (_) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          errorMessage: 'Profil fotoğrafı yüklenirken bir hata oluştu.',
          infoMessage: null,
        ),
      );
    }
  }

  /// Ekranda gösterilen geçici hata ve bilgi mesajlarını sıfırlar.
  void clearMessages() {
    emit(
      state.copyWith(
        actionStatus: ActionStatus.idle,
        errorMessage: null,
        infoMessage: null,
      ),
    );
  }

  /// Firestore'dan kullanıcı profilini okur ve rol bilgisini varsayılan atama yapmadan doğrular.
  Future<void> _resolveUserProfileAndEmit({
    required String uid,
    required int token,
    required bool preserveActionStatus,
    String? successMessage,
  }) async {
    try {
      final profileData = await _authService.getUserProfile(uid);
      if (!_isCurrentOperation(token)) return;

      if (profileData == null) {
        emit(
          state.copyWith(
            sessionStatus: AuthSessionStatus.profileUnavailable,
            actionStatus: preserveActionStatus
                ? state.actionStatus
                : ActionStatus.failed,
            authUid: uid,
            user: null,
            role: null,
            errorMessage: 'Kullanıcı profil kaydı bulunamadı.',
            infoMessage: null,
          ),
        );
        return;
      }

      // UserModel.fromJson varsayılan rol atadığı için önce ham 'role' alanı doğrulanır.
      final validatedRole = _validateRoleValue(profileData['role']);
      if (validatedRole == null) {
        emit(
          state.copyWith(
            sessionStatus: AuthSessionStatus.profileUnavailable,
            actionStatus: preserveActionStatus
                ? state.actionStatus
                : ActionStatus.failed,
            authUid: uid,
            user: null,
            role: null,
            errorMessage: 'Kullanıcı rol bilgisi eksik veya geçersiz.',
            infoMessage: null,
          ),
        );
        return;
      }

      final userModel = UserModel.fromJson(
        {...profileData, 'role': validatedRole},
        id: uid,
      );

      emit(
        state.copyWith(
          sessionStatus: AuthSessionStatus.authenticated,
          actionStatus: preserveActionStatus
              ? state.actionStatus
              : ActionStatus.succeeded,
          authUid: uid,
          user: userModel,
          role: validatedRole,
          errorMessage: null,
          infoMessage: successMessage,
        ),
      );
    } on AuthServiceException catch (e) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          sessionStatus: AuthSessionStatus.profileUnavailable,
          actionStatus:
              preserveActionStatus ? state.actionStatus : ActionStatus.failed,
          authUid: uid,
          user: null,
          role: null,
          errorMessage: e.message,
          infoMessage: null,
        ),
      );
    } catch (_) {
      if (!_isCurrentOperation(token)) return;
      emit(
        state.copyWith(
          sessionStatus: AuthSessionStatus.profileUnavailable,
          actionStatus:
              preserveActionStatus ? state.actionStatus : ActionStatus.failed,
          authUid: uid,
          user: null,
          role: null,
          errorMessage: 'Kullanıcı profili doğrulanırken bir hata oluştu.',
          infoMessage: null,
        ),
      );
    }
  }

  /// Rol değerinin yalnızca 'patient' veya 'doctor' olduğunu doğrular; aksi halde null döner.
  String? _validateRoleValue(Object? rawRole) {
    if (rawRole is! String) return null;
    final cleanRole = rawRole.trim();
    if (cleanRole == AppConstants.rolePatient) {
      return AppConstants.rolePatient;
    }
    if (cleanRole == AppConstants.roleDoctor) {
      return AppConstants.roleDoctor;
    }
    return null;
  }

  bool _isCurrentOperation(int token) => !isClosed && token == _operationToken;

  void _beginExplicitAuthAction() {
    _activeExplicitAuthActions++;
  }

  void _endExplicitAuthAction() {
    if (_activeExplicitAuthActions > 0) {
      _activeExplicitAuthActions--;
    }

    if (_activeExplicitAuthActions == 0 &&
        _hasPendingAuthStreamSync &&
        !isClosed) {
      _hasPendingAuthStreamSync = false;
      final currentUser = _authService.currentUser;
      final currentUid =
          (currentUser != null && currentUser.uid.isNotEmpty)
              ? currentUser.uid
              : null;

      // İşlem sürerken oturum dışarıdan kapandıysa veya farklı bir kullanıcıya geçtiyse state'i gerçek oturumla eşitler.
      final isSessionOutOfSync = currentUid != state.authUid ||
          (currentUid == null && !state.sessionStatus.isUnauthenticated);

      if (isSessionOutOfSync) {
        unawaited(_syncWithFirebaseUser(currentUser));
      }
    }
  }

  Future<void> _syncWithFirebaseUser(User? firebaseUser) async {
    final token = ++_operationToken;
    if (firebaseUser == null || firebaseUser.uid.isEmpty) {
      if (!_isCurrentOperation(token)) return;
      emit(
        const AuthState(
          sessionStatus: AuthSessionStatus.unauthenticated,
          actionStatus: ActionStatus.idle,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        sessionStatus: AuthSessionStatus.checking,
        authUid: firebaseUser.uid,
        errorMessage: null,
        infoMessage: null,
      ),
    );

    await _resolveUserProfileAndEmit(
      uid: firebaseUser.uid,
      token: token,
      preserveActionStatus: true,
    );
  }

  @override
  Future<void> close() async {
    _operationToken++;
    _activeExplicitAuthActions = 0;
    _hasPendingAuthStreamSync = false;
    await _authSubscription?.cancel();
    _authSubscription = null;
    return super.close();
  }
}

