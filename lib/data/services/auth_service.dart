import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';

/// Kimlik doğrulama işlemlerinde anlaşılır Türkçe hata mesajı taşır.
class AuthServiceException implements Exception {
  final String code;
  final String message;

  const AuthServiceException(this.code, this.message);

  @override
  String toString() => message;
}

/// Firebase Authentication ve kullanıcı rolü okuma işlemlerini yönetir.
class AuthService {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  AuthService({this.auth, this.firestore});

  FirebaseAuth get _auth => auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => firestore ?? FirebaseFirestore.instance;

  /// Anlık oturum açmış Firebase kullanıcısı.
  User? get currentUser => _auth.currentUser;

  /// Oturum durumundaki değişiklikleri dinler.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// E-posta ve şifre ile giriş yapar.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(e.code, _mapAuthError(e.code));
    } catch (_) {
      throw const AuthServiceException(
        'unknown',
        'Giriş yapılırken beklenmeyen bir hata oluştu.',
      );
    }
  }

  /// Yeni kullanıcı oluşturur ve profil/rol bilgisini Firestore'a kaydeder.
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = AppConstants.rolePatient,
    String? phone,
    String? tcNo,
    String? titleOrInfo,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthServiceException(
          'user-creation-failed',
          'Kullanıcı hesabı oluşturulamadı.',
        );
      }

      final cleanName = fullName.trim();
      await user.updateDisplayName(cleanName);

      // Rol değeri dışarıdan hatalı gelse bile yalnızca tanımlı rollere izin verilir.
      final normalizedRole = role == AppConstants.roleDoctor
          ? AppConstants.roleDoctor
          : AppConstants.rolePatient;

      final profileData = <String, dynamic>{
        'id': user.uid,
        'uid': user.uid,
        'email': email.trim(),
        'fullName': cleanName,
        'role': normalizedRole,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (tcNo != null && tcNo.trim().isNotEmpty) 'tcNo': tcNo.trim(),
        if (titleOrInfo != null && titleOrInfo.trim().isNotEmpty)
          'titleOrInfo': titleOrInfo.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?extraData,
      };

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(profileData);

      return credential;
    } on AuthServiceException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(e.code, _mapAuthError(e.code));
    } catch (_) {
      throw const AuthServiceException(
        'unknown',
        'Kayıt işlemi sırasında bir hata oluştu.',
      );
    }
  }

  /// Kayıtlı e-posta adresine şifre sıfırlama bağlantısı gönderir.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(e.code, _mapAuthError(e.code));
    } catch (_) {
      throw const AuthServiceException(
        'unknown',
        'Şifre sıfırlama e-postası gönderilemedi.',
      );
    }
  }

  /// Mevcut kullanıcı oturumunu sonlandırır.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Kullanıcının rolünü (`patient` veya `doctor`) Firestore `users` koleksiyonundan okur.
  Future<String> getUserRole([String? uid]) async {
    final targetUid = uid ?? currentUser?.uid;
    if (targetUid == null || targetUid.isEmpty) {
      throw const AuthServiceException(
        'not-authenticated',
        'Rol bilgisi için aktif kullanıcı oturumu bulunamadı.',
      );
    }

    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(targetUid)
        .get();

    final role = snapshot.data()?['role'] as String?;
    if (role == AppConstants.roleDoctor) {
      return AppConstants.roleDoctor;
    }
    return AppConstants.rolePatient;
  }

  /// Aktif kullanıcının Firestore profil belgesini getirir.
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    return getUserProfile(uid);
  }

  /// Belirtilen kullanıcının Firestore profil belgesini getirir.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...?doc.data()};
  }

  /// Firebase Auth hata kodlarını kullanıcı dostu Türkçe mesajlara çevirir.
  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Geçersiz e-posta adresi formatı.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kayıtlı.';
      case 'weak-password':
        return 'Şifre güvenlik gereksinimlerini karşılamıyor.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen biraz bekleyin.';
      case 'network-request-failed':
        return 'İnternet bağlantısı kurulamadı.';
      default:
        return 'Kimlik doğrulama işlemi tamamlanamadı ($code).';
    }
  }
}

