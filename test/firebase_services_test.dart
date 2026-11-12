import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalsync/core/constants/app_constants.dart';
import 'package:vitalsync/core/di/service_locator.dart';
import 'package:vitalsync/data/services/services.dart';

/// Testlerde gerçek Firestore bağlantısı olmadan kayıt akışını doğrular.
class _FakeFirestoreService extends FirestoreService {
  final List<Map<String, dynamic>> savedCalls = [];

  @override
  Future<String> addDocument(
    String collection,
    Map<String, dynamic> data, {
    String? docId,
  }) async {
    savedCalls.add({
      'op': 'add',
      'collection': collection,
      'data': data,
    });
    return docId ?? 'mock-doc-id';
  }

  @override
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    savedCalls.add({
      'op': 'set',
      'collection': collection,
      'docId': docId,
      'data': data,
    });
  }

  @override
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    savedCalls.add({
      'op': 'update',
      'collection': collection,
      'docId': docId,
      'data': data,
    });
  }
}

void main() {
  test('ServiceLocator temel Firebase servislerini kaydeder', () {
    ServiceLocator.setup();

    expect(ServiceLocator.isRegistered<FirestoreService>(), isTrue);
    expect(ServiceLocator.isRegistered<AuthService>(), isTrue);
    expect(ServiceLocator.isRegistered<StorageService>(), isTrue);
  });

  test('StorageService Spark planında güvenli fallback URL döndürür ve Firestore\'a yazar', () async {
    final fakeFirestore = _FakeFirestoreService();
    final storageService = StorageService(firestoreService: fakeFirestore);

    double? reportedProgress;
    final url = await storageService.uploadAndSavePatientDocument(
      patientId: 'patient-1',
      title: 'Panoramik Röntgen',
      bytes: Uint8List.fromList([1, 2, 3]),
      onProgress: (p) => reportedProgress = p,
    );

    expect(url, AppConstants.defaultXrayFallbackAsset);
    expect(reportedProgress, 1.0);
    expect(fakeFirestore.savedCalls, hasLength(1));
    expect(
      fakeFirestore.savedCalls.first['collection'],
      AppConstants.resultsCollection,
    );
    expect(
      (fakeFirestore.savedCalls.first['data'] as Map)['downloadUrl'],
      AppConstants.defaultXrayFallbackAsset,
    );
  });

  test('StorageService profil fotoğrafı fallback yolunu users koleksiyonuna kaydeder', () async {
    final fakeFirestore = _FakeFirestoreService();
    final storageService = StorageService(firestoreService: fakeFirestore);

    final url = await storageService.uploadAndSaveProfilePhoto(
      userId: 'user-1',
      bytes: Uint8List.fromList([10, 20]),
    );

    expect(url, AppConstants.defaultAvatarFallbackAsset);
    expect(fakeFirestore.savedCalls, hasLength(1));
    expect(
      fakeFirestore.savedCalls.first['collection'],
      AppConstants.usersCollection,
    );
    expect(fakeFirestore.savedCalls.first['docId'], 'user-1');
  });
}

