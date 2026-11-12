import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

/// Firestore veritabanı işlemleri için ortak hata sınıfı.
class FirestoreServiceException implements Exception {
  final String code;
  final String message;

  const FirestoreServiceException(this.code, this.message);

  @override
  String toString() => message;
}

/// Tüm Firestore koleksiyonları için temel CRUD ve canlı Stream işlemlerini sunar.
class FirestoreService {
  final FirebaseFirestore? firestore;

  FirestoreService({this.firestore});

  FirebaseFirestore get _firestore => firestore ?? FirebaseFirestore.instance;

  /// Belirtilen koleksiyonun referansını döndürür.
  CollectionReference<Map<String, dynamic>> collectionRef(String collection) {
    return _firestore.collection(collection);
  }

  // ---------------------------------------------------------------------------
  // Genel CRUD ve Canlı Stream Yardımcıları
  // ---------------------------------------------------------------------------

  /// Koleksiyona yeni belge ekler; [docId] verilmezse otomatik kimlik üretir.
  Future<String> addDocument(
    String collection,
    Map<String, dynamic> data, {
    String? docId,
  }) async {
    final colRef = collectionRef(collection);
    final docRef = docId != null && docId.isNotEmpty
        ? colRef.doc(docId)
        : colRef.doc();

    final payload = <String, dynamic>{
      ...data,
      'id': docRef.id,
      if (!data.containsKey('createdAt'))
        'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(payload);
    return docRef.id;
  }

  /// Belgeyi tam veya birleştirmeli (`merge`) olarak yazar.
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    final payload = <String, dynamic>{
      ...data,
      'id': docId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await collectionRef(collection).doc(docId).set(
      payload,
      SetOptions(merge: merge),
    );
  }

  /// Tek bir belgeyi kimliğine göre okur.
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    final snapshot = await collectionRef(collection).doc(docId).get();
    if (!snapshot.exists) return null;
    return _mapSnapshot(snapshot);
  }

  /// Koleksiyon belgelerini isteğe bağlı eşitlik filtresi ve sıralama ile getirir.
  Future<List<Map<String, dynamic>>> getCollection(
    String collection, {
    String? filterField,
    Object? isEqualTo,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    final query = _buildQuery(
      collection,
      filterField: filterField,
      isEqualTo: isEqualTo,
      orderByField: orderByField,
      descending: descending,
      limit: limit,
    );

    final snapshot = await query.get();
    final items = snapshot.docs.map(_mapSnapshot).toList();

    // Filtre + sıralama aynı anda istendiğinde bileşik indeks hatasını önlemek için bellek içi sıralama yapılır.
    if (filterField != null && orderByField != null) {
      _sortMaps(items, orderByField, descending: descending);
    }
    return items;
  }

  /// Mevcut belgeyi günceller.
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await collectionRef(collection).doc(docId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Belirtilen belgeyi kalıcı olarak siler.
  Future<void> deleteDocument(String collection, String docId) async {
    await collectionRef(collection).doc(docId).delete();
  }

  /// Tek bir belgeyi gerçek zamanlı olarak dinler.
  Stream<Map<String, dynamic>?> streamDocument(
    String collection,
    String docId,
  ) {
    return collectionRef(collection).doc(docId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return _mapSnapshot(snapshot);
    });
  }

  /// Koleksiyonu gerçek zamanlı Stream olarak dinler.
  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    String? filterField,
    Object? isEqualTo,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) {
    final query = _buildQuery(
      collection,
      filterField: filterField,
      isEqualTo: isEqualTo,
      orderByField: orderByField,
      descending: descending,
      limit: limit,
    );

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map(_mapSnapshot).toList();
      if (filterField != null && orderByField != null) {
        _sortMaps(items, orderByField, descending: descending);
      }
      return items;
    });
  }

  // ---------------------------------------------------------------------------
  // Users (`users`)
  // ---------------------------------------------------------------------------

  Future<void> saveUser(String userId, Map<String, dynamic> data) =>
      setDocument(AppConstants.usersCollection, userId, data);

  Future<Map<String, dynamic>?> getUser(String userId) =>
      getDocument(AppConstants.usersCollection, userId);

  Future<void> updateUser(String userId, Map<String, dynamic> data) =>
      updateDocument(AppConstants.usersCollection, userId, data);

  Future<void> deleteUser(String userId) =>
      deleteDocument(AppConstants.usersCollection, userId);

  Stream<Map<String, dynamic>?> streamUser(String userId) =>
      streamDocument(AppConstants.usersCollection, userId);

  Future<List<Map<String, dynamic>>> getDoctors() => getCollection(
    AppConstants.usersCollection,
    filterField: 'role',
    isEqualTo: AppConstants.roleDoctor,
    orderByField: 'fullName',
  );

  Stream<List<Map<String, dynamic>>> streamDoctors() => streamCollection(
    AppConstants.usersCollection,
    filterField: 'role',
    isEqualTo: AppConstants.roleDoctor,
    orderByField: 'fullName',
  );

  Future<List<Map<String, dynamic>>> getPatients() => getCollection(
    AppConstants.usersCollection,
    filterField: 'role',
    isEqualTo: AppConstants.rolePatient,
    orderByField: 'fullName',
  );

  Stream<List<Map<String, dynamic>>> streamPatients() => streamCollection(
    AppConstants.usersCollection,
    filterField: 'role',
    isEqualTo: AppConstants.rolePatient,
    orderByField: 'fullName',
  );

  // ---------------------------------------------------------------------------
  // Appointments (`appointments`)
  // ---------------------------------------------------------------------------

  Future<String> createAppointment(Map<String, dynamic> data) =>
      addDocument(AppConstants.appointmentsCollection, data);

  /// Aynı doktor, tarih ve saat slotunda iptal edilmemiş randevu varsa çakışmayı engeller.
  Future<String> bookAppointmentIfAvailable(Map<String, dynamic> data) async {
    final doctorId = data['doctorId'] as String?;
    final date = data['date'] as String?;
    final time = data['time'] as String?;

    if (doctorId != null && date != null && time != null) {
      final existing = await collectionRef(AppConstants.appointmentsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isEqualTo: date)
          .where('time', isEqualTo: time)
          .get();

      final hasActiveSlot = existing.docs.any((doc) {
        final status = (doc.data()['status'] as String?)?.toLowerCase();
        return status != 'cancelled' && status != 'iptal';
      });

      if (hasActiveSlot) {
        throw const FirestoreServiceException(
          'slot-already-booked',
          'Seçilen randevu saati başka bir hasta tarafından alınmış.',
        );
      }
    }

    return createAppointment(data);
  }

  Future<Map<String, dynamic>?> getAppointment(String appointmentId) =>
      getDocument(AppConstants.appointmentsCollection, appointmentId);

  Future<List<Map<String, dynamic>>> getAppointmentsByPatient(
    String patientId,
  ) => getCollection(
    AppConstants.appointmentsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Stream<List<Map<String, dynamic>>> streamAppointmentsByPatient(
    String patientId,
  ) => streamCollection(
    AppConstants.appointmentsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Future<List<Map<String, dynamic>>> getAppointmentsByDoctor(
    String doctorId,
  ) => getCollection(
    AppConstants.appointmentsCollection,
    filterField: 'doctorId',
    isEqualTo: doctorId,
    orderByField: 'createdAt',
    descending: true,
  );

  Stream<List<Map<String, dynamic>>> streamAppointmentsByDoctor(
    String doctorId,
  ) => streamCollection(
    AppConstants.appointmentsCollection,
    filterField: 'doctorId',
    isEqualTo: doctorId,
    orderByField: 'createdAt',
    descending: true,
  );

  Future<void> updateAppointment(
    String appointmentId,
    Map<String, dynamic> data,
  ) => updateDocument(
    AppConstants.appointmentsCollection,
    appointmentId,
    data,
  );

  Future<void> updateAppointmentStatus(String appointmentId, String status) =>
      updateAppointment(appointmentId, {'status': status});

  Future<void> deleteAppointment(String appointmentId) =>
      deleteDocument(AppConstants.appointmentsCollection, appointmentId);

  // ---------------------------------------------------------------------------
  // Tooth Records (`tooth_records`)
  // ---------------------------------------------------------------------------

  Future<String> createToothRecord(Map<String, dynamic> data) =>
      addDocument(AppConstants.toothRecordsCollection, data);

  Future<Map<String, dynamic>?> getToothRecord(String recordId) =>
      getDocument(AppConstants.toothRecordsCollection, recordId);

  Future<List<Map<String, dynamic>>> getToothRecordsByPatient(
    String patientId,
  ) => getCollection(
    AppConstants.toothRecordsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Stream<List<Map<String, dynamic>>> streamToothRecordsByPatient(
    String patientId,
  ) => streamCollection(
    AppConstants.toothRecordsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Future<void> updateToothRecord(
    String recordId,
    Map<String, dynamic> data,
  ) => updateDocument(
    AppConstants.toothRecordsCollection,
    recordId,
    data,
  );

  Future<void> deleteToothRecord(String recordId) =>
      deleteDocument(AppConstants.toothRecordsCollection, recordId);

  // ---------------------------------------------------------------------------
  // Treatments (`treatments`)
  // ---------------------------------------------------------------------------

  Future<String> createTreatment(Map<String, dynamic> data) =>
      addDocument(AppConstants.treatmentsCollection, data);

  Future<Map<String, dynamic>?> getTreatment(String treatmentId) =>
      getDocument(AppConstants.treatmentsCollection, treatmentId);

  Future<List<Map<String, dynamic>>> getTreatmentsByPatient(
    String patientId,
  ) => getCollection(
    AppConstants.treatmentsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Stream<List<Map<String, dynamic>>> streamTreatmentsByPatient(
    String patientId,
  ) => streamCollection(
    AppConstants.treatmentsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Future<List<Map<String, dynamic>>> getTreatmentsByDoctor(
    String doctorId,
  ) => getCollection(
    AppConstants.treatmentsCollection,
    filterField: 'doctorId',
    isEqualTo: doctorId,
    orderByField: 'createdAt',
    descending: true,
  );

  Stream<List<Map<String, dynamic>>> streamTreatmentsByDoctor(
    String doctorId,
  ) => streamCollection(
    AppConstants.treatmentsCollection,
    filterField: 'doctorId',
    isEqualTo: doctorId,
    orderByField: 'createdAt',
    descending: true,
  );

  Future<void> updateTreatment(
    String treatmentId,
    Map<String, dynamic> data,
  ) => updateDocument(
    AppConstants.treatmentsCollection,
    treatmentId,
    data,
  );

  Future<void> deleteTreatment(String treatmentId) =>
      deleteDocument(AppConstants.treatmentsCollection, treatmentId);

  // ---------------------------------------------------------------------------
  // Payments (`payments`)
  // ---------------------------------------------------------------------------

  Future<String> createPayment(Map<String, dynamic> data) =>
      addDocument(AppConstants.paymentsCollection, data);

  Future<Map<String, dynamic>?> getPayment(String paymentId) =>
      getDocument(AppConstants.paymentsCollection, paymentId);

  Future<List<Map<String, dynamic>>> getPaymentsByPatient(
    String patientId,
  ) => getCollection(
    AppConstants.paymentsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Stream<List<Map<String, dynamic>>> streamPaymentsByPatient(
    String patientId,
  ) => streamCollection(
    AppConstants.paymentsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Future<void> updatePayment(String paymentId, Map<String, dynamic> data) =>
      updateDocument(AppConstants.paymentsCollection, paymentId, data);

  Future<void> deletePayment(String paymentId) =>
      deleteDocument(AppConstants.paymentsCollection, paymentId);

  // ---------------------------------------------------------------------------
  // Prescriptions (`prescriptions`)
  // ---------------------------------------------------------------------------

  Future<String> createPrescription(Map<String, dynamic> data) =>
      addDocument(AppConstants.prescriptionsCollection, data);

  Future<Map<String, dynamic>?> getPrescription(String prescriptionId) =>
      getDocument(AppConstants.prescriptionsCollection, prescriptionId);

  Future<List<Map<String, dynamic>>> getPrescriptionsByPatient(
    String patientId,
  ) => getCollection(
    AppConstants.prescriptionsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Stream<List<Map<String, dynamic>>> streamPrescriptionsByPatient(
    String patientId,
  ) => streamCollection(
    AppConstants.prescriptionsCollection,
    filterField: 'patientId',
    isEqualTo: patientId,
    orderByField: 'createdAt',
    descending: true,
  );

  Future<List<Map<String, dynamic>>> getPrescriptionsByDoctor(
    String doctorId,
  ) => getCollection(
    AppConstants.prescriptionsCollection,
    filterField: 'doctorId',
    isEqualTo: doctorId,
    orderByField: 'createdAt',
    descending: true,
  );

  Stream<List<Map<String, dynamic>>> streamPrescriptionsByDoctor(
    String doctorId,
  ) => streamCollection(
    AppConstants.prescriptionsCollection,
    filterField: 'doctorId',
    isEqualTo: doctorId,
    orderByField: 'createdAt',
    descending: true,
  );

  Future<void> updatePrescription(
    String prescriptionId,
    Map<String, dynamic> data,
  ) => updateDocument(
    AppConstants.prescriptionsCollection,
    prescriptionId,
    data,
  );

  Future<void> deletePrescription(String prescriptionId) =>
      deleteDocument(AppConstants.prescriptionsCollection, prescriptionId);

  // ---------------------------------------------------------------------------
  // Ek Klinik Koleksiyonları (`vitals`, `results`, `messages`, `doctor_schedules`)
  // ---------------------------------------------------------------------------

  Future<String> createVital(Map<String, dynamic> data) =>
      addDocument(AppConstants.vitalsCollection, data);

  Stream<List<Map<String, dynamic>>> streamVitalsByPatient(String patientId) =>
      streamCollection(
        AppConstants.vitalsCollection,
        filterField: 'patientId',
        isEqualTo: patientId,
        orderByField: 'createdAt',
        descending: true,
      );

  Future<String> createResult(Map<String, dynamic> data) =>
      addDocument(AppConstants.resultsCollection, data);

  Stream<List<Map<String, dynamic>>> streamResultsByPatient(String patientId) =>
      streamCollection(
        AppConstants.resultsCollection,
        filterField: 'patientId',
        isEqualTo: patientId,
        orderByField: 'createdAt',
        descending: true,
      );

  Future<String> sendMessage(Map<String, dynamic> data) =>
      addDocument(AppConstants.messagesCollection, data);

  Stream<List<Map<String, dynamic>>> streamMessagesByConversation(
    String conversationId,
  ) => streamCollection(
    AppConstants.messagesCollection,
    filterField: 'conversationId',
    isEqualTo: conversationId,
    orderByField: 'createdAt',
  );

  Future<void> saveDoctorSchedule(
    String doctorId,
    Map<String, dynamic> data,
  ) => setDocument(AppConstants.doctorSchedulesCollection, doctorId, {
    ...data,
    'doctorId': doctorId,
  });

  Future<Map<String, dynamic>?> getDoctorSchedule(String doctorId) =>
      getDocument(AppConstants.doctorSchedulesCollection, doctorId);

  Stream<Map<String, dynamic>?> streamDoctorSchedule(String doctorId) =>
      streamDocument(AppConstants.doctorSchedulesCollection, doctorId);

  // ---------------------------------------------------------------------------
  // Dahili Yardımcılar
  // ---------------------------------------------------------------------------

  Query<Map<String, dynamic>> _buildQuery(
    String collection, {
    String? filterField,
    Object? isEqualTo,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = collectionRef(collection);

    if (filterField != null && isEqualTo != null) {
      query = query.where(filterField, isEqualTo: isEqualTo);
    } else if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }
    return query;
  }

  Map<String, dynamic> _mapSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return {'id': doc.id, ...?doc.data()};
  }

  void _sortMaps(
    List<Map<String, dynamic>> items,
    String field, {
    bool descending = false,
  }) {
    items.sort((a, b) {
      final cmp = _compareValues(a[field], b[field]);
      return descending ? -cmp : cmp;
    });
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    final normalizedA = a is Timestamp ? a.toDate() : a;
    final normalizedB = b is Timestamp ? b.toDate() : b;

    if (normalizedA is Comparable && normalizedB is Comparable) {
      try {
        return normalizedA.compareTo(normalizedB);
      } catch (_) {
        return normalizedA.toString().compareTo(normalizedB.toString());
      }
    }
    return normalizedA.toString().compareTo(normalizedB.toString());
  }
}

