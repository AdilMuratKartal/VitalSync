import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/constants/app_constants.dart';
import 'firestore_service.dart';

/// Röntgen, klinik belge ve profil görsellerini yükleyip Firestore'a bağlar.
///
/// Proje ücretsiz Spark planında tutulduğunda [enableRemoteStorage] varsayılan
/// olarak `false` çalışır ve uygulama çökmeden güvenli yerel/örnek URL döner.
class StorageService {
  final FirebaseStorage? storage;
  final FirestoreService? firestoreService;
  final bool enableRemoteStorage;

  StorageService({
    this.storage,
    this.firestoreService,
    this.enableRemoteStorage = false,
  });

  FirestoreService get _firestoreService =>
      firestoreService ?? FirestoreService();

  /// Dosya baytlarını yükler; Storage kapalıysa veya hata oluşursa fallback döner.
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String storagePath,
    String contentType = 'image/png',
    String fallbackUrl = AppConstants.defaultXrayFallbackAsset,
    void Function(double progress)? onProgress,
  }) async {
    if (!enableRemoteStorage) {
      onProgress?.call(1.0);
      return fallbackUrl;
    }

    try {
      final storageInstance = storage ?? FirebaseStorage.instance;
      final ref = storageInstance.ref().child(storagePath);
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final total = snapshot.totalBytes;
          if (total > 0) {
            onProgress(snapshot.bytesTransferred / total);
          }
        });
      }

      final completed = await uploadTask;
      return await completed.ref.getDownloadURL();
    } catch (_) {
      // Spark planı veya ağ nedeniyle yükleme yapılamazsa akışın kesilmesini önler.
      onProgress?.call(1.0);
      return fallbackUrl;
    }
  }

  /// Hasta röntgen/belge görselini yükler ve bağlantısını Firestore'a kaydeder.
  Future<String> uploadAndSavePatientDocument({
    required String patientId,
    required String title,
    Uint8List? bytes,
    String? fileName,
    String contentType = 'image/png',
    String targetCollection = AppConstants.resultsCollection,
    String? existingRecordId,
    String? doctorId,
    String? note,
    String fallbackUrl = AppConstants.defaultXrayFallbackAsset,
    void Function(double progress)? onProgress,
  }) async {
    final safeName = (fileName ?? 'document.png').replaceAll(' ', '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'patients/$patientId/documents/${timestamp}_$safeName';

    final downloadUrl = bytes != null && bytes.isNotEmpty
        ? await uploadBytes(
            bytes: bytes,
            storagePath: storagePath,
            contentType: contentType,
            fallbackUrl: fallbackUrl,
            onProgress: onProgress,
          )
        : fallbackUrl;

    if (existingRecordId != null && existingRecordId.isNotEmpty) {
      await _firestoreService.updateDocument(
        targetCollection,
        existingRecordId,
        {
          'downloadUrl': downloadUrl,
          'fileUrl': downloadUrl,
        },
      );
    } else {
      await _firestoreService.addDocument(targetCollection, {
        'patientId': patientId,
        if (doctorId != null && doctorId.isNotEmpty) 'doctorId': doctorId,
        'title': title,
        'downloadUrl': downloadUrl,
        'fileUrl': downloadUrl,
        if (note != null && note.isNotEmpty) 'note': note,
        'isLocalFallback': !downloadUrl.startsWith('http'),
      });
    }

    return downloadUrl;
  }

  /// Kullanıcı profil fotoğrafını yükler ve `users` belgesini günceller.
  Future<String> uploadAndSaveProfilePhoto({
    required String userId,
    Uint8List? bytes,
    String? fileName,
    String fallbackUrl = AppConstants.defaultAvatarFallbackAsset,
    void Function(double progress)? onProgress,
  }) async {
    final safeName = (fileName ?? 'avatar.png').replaceAll(' ', '_');
    final storagePath = 'users/$userId/profile/$safeName';

    final downloadUrl = bytes != null && bytes.isNotEmpty
        ? await uploadBytes(
            bytes: bytes,
            storagePath: storagePath,
            fallbackUrl: fallbackUrl,
            onProgress: onProgress,
          )
        : fallbackUrl;

    await _firestoreService.saveUser(userId, {
      'avatarUrl': downloadUrl,
      'photoUrl': downloadUrl,
    });

    return downloadUrl;
  }

  /// Yalnızca uzak Firebase Storage URL'lerini siler; yerel asset yollarını atlar.
  Future<void> deleteRemoteFile(String fileUrl) async {
    if (!enableRemoteStorage || !fileUrl.startsWith('http')) {
      return;
    }
    try {
      final storageInstance = storage ?? FirebaseStorage.instance;
      await storageInstance.refFromURL(fileUrl).delete();
    } catch (_) {
      // Uzak dosya silinemese bile kayıt akışını engellemez.
    }
  }
}
