# Geliştirici 5 (State Management & Logic Lead) — Teknik Geliştirme Raporu

Bu belge, **VitalSync (Dentora)** projesinde **Geliştirici 5 — State Management & Logic Lead** sorumluluğu kapsamında (`feature/dev5-state-management` branch'i üzerinde) gerçekleştirilen `flutter_bloc` (Cubit) altyapısını, 6 ana özellik modülünü, doğrulama sonuçlarını, tespit edilen teknik/güvenlik risklerini ve Geliştirici 6 için ekran entegrasyon rehberini içerir.

---

## 1. Mimari Yaklaşım ve Genel Kurallar

- **Durum Yönetimi Paketi:** `pubspec.yaml` dosyasına `flutter_bloc: ^9.1.0` eklenmiş (çözümlenen sürüm: `flutter_bloc 9.1.1`) ve BLoC Event yapısı yerine doğrudan **Cubit** mimarisi kullanılmıştır.
- **Klasör Yapısı:** Tüm Cubit ve State dosyaları `lib/presentation/cubits/` altında modüler olarak konumlandırılmış ve `lib/presentation/cubits/cubits.dart` üzerinden dışa aktarılmıştır.
- **Veri ve Aksiyon Ayrımı:** Liste/veri yükleme durumları (`DataStatus`) ile form gönderimi/güncelleme/silme gibi kullanıcı aksiyonlarının durumları (`ActionStatus`) birbirinden ayrılmıştır. Böylece bir aksiyon sırasında veya aksiyon hatasında ekrandaki mevcut listelerin kaybolması engellenmiştir.
- **Bağımlılık Enjeksiyonu (DI):** Hiçbir Cubit doğrudan Firebase SDK sınıflarını (`FirebaseAuth.instance`, `FirebaseFirestore.instance`, `FirebaseStorage.instance`) çağırmaz. Tüm Cubit'ler yapıcı (constructor) üzerinden opsiyonel olarak `AuthService`, `FirestoreService` ve `StorageService` alır; parametre verilmediğinde `ServiceLocator.get<T>()` üzerinden çözümlenir.
- **Kapsam Sınırları:** Geliştirici 1, 2, 3, 4 ve 6'nın sorumluluğundaki mevcut uygulama dosyaları (`lib/core/`, `lib/data/`, `lib/presentation/screens/`, `lib/main.dart`) değiştirilmemiştir.

---

## 2. Tamamlanan Modüller

### 2.1. Ortak Cubit Altyapısı (`DataStatus` & `ActionStatus`)

- **Dosya Yolları:**
  - `lib/presentation/cubits/cubit_status.dart`
  - `lib/presentation/cubits/cubits.dart` (ortak barrel dosyası)
  - `test/cubits/cubit_status_test.dart`
- **Tanımlanan Yapılar:**
  - **`DataStatus`:** `initial`, `loading`, `empty`, `success`, `error`
    - Yardımcı getter'lar: `isInitial`, `isLoading`, `isEmpty`, `isSuccess`, `isError`
  - **`ActionStatus`:** `idle`, `submitting`, `succeeded`, `failed`
    - Yardımcı getter'lar: `isIdle`, `isSubmitting`, `isSucceeded`, `isFailed`
- **Tamamlanma Durumu:** Tamamlandı. Statik analiz (`flutter analyze`) ve birim testleri (`test/cubits/cubit_status_test.dart` — 11 test) başarılı.

---

### 2.2. `AuthCubit` & `AuthState`

- **Dosya Yolları:**
  - `lib/presentation/cubits/auth/auth_state.dart`
  - `lib/presentation/cubits/auth/auth_cubit.dart`
- **Public Metotlar (`AuthCubit`):**
  - `Future<void> checkSession()`
  - `void watchAuthState()`
  - `Future<void> signIn({required String email, required String password})`
  - `Future<void> signUp({required String email, required String password, required String fullName, required String role, String? phone, String? tcNo, String? titleOrInfo, Map<String, dynamic>? extraData})`
  - `Future<void> signOut()`
  - `Future<void> sendPasswordReset({required String email})`
  - `Future<void> refreshProfile()`
  - `Future<void> updateProfile({String? fullName, String? phone, String? tcNo, String? titleOrInfo})`
  - `Future<void> uploadProfilePhoto({required Uint8List bytes, String? fileName, void Function(double progress)? onProgress})`
  - `void clearMessages()`
- **State Alanları ve Yardımcı Getter'lar (`AuthState`):**
  - `AuthSessionStatus`: `initial`, `checking`, `authenticated`, `unauthenticated`, `profileUnavailable`
  - Alanlar: `sessionStatus`, `actionStatus`, `authUid`, `user` (`UserModel?`), `role` (`String?`), `errorMessage`, `infoMessage`
  - Getter'lar: `hasFirebaseSession`, `hasResolvedProfile`, `isAuthenticated`, `isDoctor`, `isPatient`
- **Kullanılan Firebase Servisleri:**
  - `AuthService` (`currentUser`, `authStateChanges`, `signIn`, `signUp`, `signOut`, `sendPasswordResetEmail`, `getUserProfile`)
  - `FirestoreService` (`updateUser`)
  - `StorageService` (`uploadAndSaveProfilePhoto`)
- **Yönetilen İş Kuralları:**
  - Firebase Auth oturumu açık olsa dahi Firestore `users/{uid}` belgesi okunamıyorsa veya `role` alanı `'patient'` / `'doctor'` dışında (eksik/bozuk) ise kullanıcıya varsayılan rol **atanmaz**; oturum `AuthSessionStatus.profileUnavailable` durumuna geçirilir ve `isAuthenticated` `false` döner.
  - `sendPasswordReset` işlemi mevcut `sessionStatus` değerini bozmadan yalnızca `actionStatus` üzerinden yürütülür.
  - `signOut` başarısız olduğunda mevcut oturum durumu korunur ve hata `actionStatus: ActionStatus.failed` ile bildirilir.
- **Stream ve Asenkron İşlem Yönetimi:**
  - `_operationToken` ile eski/iptal edilmiş asenkron işlemlerin yeni kullanıcı oturumunu ezmesi engellenir.
  - `_activeExplicitAuthActions` sayacı ve `_hasPendingAuthStreamSync` mekanizması ile `signIn` / `signUp` / `signOut` sürerken gelen erken `authStateChanges` olaylarının yarım State üretmesi önlenir; işlem bittiğinde gerçek Firebase oturumu ile mevcut State arasında fark varsa otomatik senkronizasyon yapılır.
- **Hata Yönetimi:** `AuthServiceException` ve `FirestoreServiceException` mesajları yakalanarak Türkçe ve kullanıcı dostu biçimde `errorMessage` alanına aktarılır.
- **Tamamlanma Durumu:** Tamamlandı (`flutter analyze` — 0 sorun).

---

### 2.3. `AppointmentCubit` & `AppointmentState`

- **Dosya Yolları:**
  - `lib/presentation/cubits/appointment/appointment_state.dart`
  - `lib/presentation/cubits/appointment/appointment_cubit.dart`
- **Public Metotlar (`AppointmentCubit`):**
  - `void watchPatientAppointments(String patientId)`
  - `void watchDoctorAppointments(String doctorId)`
  - `Future<String?> bookAppointment(AppointmentModel appointment)`
  - `Future<void> cancelAppointment(String appointmentId)`
  - `Future<void> updateAppointmentStatus({required String appointmentId, required String status, String? customSuccessMessage})`
  - `Future<void> updateAppointmentNote({required String appointmentId, required String note})`
  - `void clearActionState()`
  - `Future<void> reset()`
- **State Alanları ve Yardımcı Getter'lar (`AppointmentState`):**
  - Alanlar: `listStatus` (`DataStatus`), `actionStatus` (`ActionStatus`), `appointments` (`List<AppointmentModel>`), `listError`, `actionError`, `actionSuccessMessage`
  - Getter'lar:
    - `upcomingAppointments`: Aktif (`!isCancelled && !isCompleted`) randevular.
    - `pastAppointments`: Tamamlanmış (`isCompleted`) randevular.
    - `cancelledAppointments`: İptal edilmiş (`isCancelled`) randevular.
    - `nextAppointment`: `date` (`YYYY-MM-DD`) ve `time` (`HH:mm`) alanlarını gerçek `DateTime` olarak ayrıştırarak geçmiş tarihli, iptal edilmiş veya tamamlanmış randevuları dışarıda bırakan ve kronolojik olarak **en yakın gelecekteki** aktif randevuyu döndüren getter.
- **Kullanılan Firebase Servisleri:**
  - `FirestoreService` (`streamAppointmentsByPatient`, `streamAppointmentsByDoctor`, `bookAppointmentIfAvailable`, `updateAppointmentStatus`, `updateAppointment`)
- **Yönetilen İş Kuralları:**
  - Çift rezervasyon (slot çakışması) kontrolü için `createAppointment` yerine `bookAppointmentIfAvailable` kullanılır; `'slot-already-booked'` hatası yakalanarak kullanıcıya anlaşılır Türkçe uyarı verilir.
  - Randevu oluşturma, iptal etme veya not güncelleme sırasında mevcut randevu listesi sıfırlanmaz.
- **Stream ve Asenkron İşlem Yönetimi:**
  - `_listOperationToken`, `_actionOperationToken` ve `_streamRevision` sayaçları ile kullanıcı değişiminde önceki abonelikler iptal edilir; yerel iyimser güncellemelerin daha yeni bir stream verisini ezmesi önlenir.
- **Hata Yönetimi:** Liste hataları `listError`, işlem hataları `actionError` üzerinden birbirinden bağımsız yönetilir.
- **Tamamlanma Durumu:** Tamamlandı (`flutter analyze` — 0 sorun).

---

### 2.4. `DoctorScheduleCubit` & `DoctorScheduleState`

- **Dosya Yolları:**
  - `lib/presentation/cubits/doctor_schedule/doctor_schedule_state.dart`
  - `lib/presentation/cubits/doctor_schedule/doctor_schedule_cubit.dart`
- **Public Metotlar (`DoctorScheduleCubit`):**
  - `Future<void> loadDoctorSchedule(String doctorId, {bool includeAppointments = true})`
  - `void watchDoctorSchedule(String doctorId, {bool watchAppointments = true})`
  - `Future<void> saveSchedule(DoctorScheduleModel schedule, {String? customSuccessMessage})`
  - `Future<void> updateWorkingSchedule({List<bool>? workingDays, String? workStart, String? workEnd, String? breakRange, int? slotDurationMinutes, Map<String, String>? timeSlots})`
  - `Future<void> updateSlotStatus({required String timeSlot, required String status})`
  - `Future<void> updateProcedures(List<ProcedurePriceItem> procedures)`
  - `Future<void> updateProcedureItem({required String procedureIdOrTitle, int? price, bool? isActive, int? durationMinutes})`
  - `List<String> getAvailableSlotsForDate(String date, {List<AppointmentModel>? externalAppointments})`
  - `void clearActionState()`
  - `Future<void> reset()`
- **State Alanları ve Yardımcı Getter'lar (`DoctorScheduleState`):**
  - Alanlar: `dataStatus`, `actionStatus`, `schedule` (`DoctorScheduleModel?`), `doctorAppointments` (`List<AppointmentModel>`), `dataError`, `actionError`, `actionSuccessMessage`
  - Getter ve Metotlar: `hasSchedule`, `procedures`, `activeProcedures`, `timeSlots`, `openScheduleSlots`, `breakScheduleSlots`, `closedScheduleSlots`, `isWorkingDayForDate(String date)`, `bookedSlotsForDate(String date, ...)`, `availableSlotsForDate(String date, ...)`
- **Kullanılan Firebase Servisleri:**
  - `FirestoreService` (`getDoctorSchedule`, `streamDoctorSchedule`, `saveDoctorSchedule`, `getAppointmentsByDoctor`, `streamAppointmentsByDoctor`)
- **Yönetilen İş Kuralları:**
  - Doktorun genel programında açık olan saatler (`openScheduleSlots`) ile belirli bir tarihte gerçekten rezerve edilebilir saatler (`availableSlotsForDate`) birbirinden ayrılmıştır.
  - `availableSlotsForDate(date)` metodu; ilgili tarihin doktorun çalışma günü olup olmadığını (`workingDays`), mesai başlangıç/bitiş saatlerini, mola aralığını (`breakRange`) ve o tarihteki iptal edilmemiş randevuları (`bookedSlotsForDate`) birlikte değerlendirir.
  - Kayıt öncesinde 7 günlük çalışma dizisi, `SS:DD` saat formatı, `workStart < workEnd`, mola aralığının mesai içinde olması, negatif olmayan işlem fiyatları ve pozitif işlem süreleri doğrulanır.
- **Stream ve Asenkron İşlem Yönetimi:**
  - Doktor programı (`_scheduleSubscription`) ve doktor randevuları (`_appointmentsSubscription`) birlikte dinlenir; `_dataOperationToken`, `_actionOperationToken` ve `_scheduleRevision` ile yarış durumları engellenir.
- **Tamamlanma Durumu:** Tamamlandı (`flutter analyze` — 0 sorun).

---

### 2.5. `MedicalRecordsCubit` & `MedicalRecordsState`

- **Dosya Yolları:**
  - `lib/presentation/cubits/medical_records/medical_records_state.dart`
  - `lib/presentation/cubits/medical_records/medical_records_cubit.dart`
- **Public Metotlar (`MedicalRecordsCubit`):**
  - `void watchPatientRecords(String patientId)`
  - `void watchPatientResults(String patientId)`
  - `void watchPatientPrescriptions(String patientId)`
  - `void watchDoctorPrescriptions(String doctorId)`
  - `Future<void> loadDoctorPrescriptions(String doctorId)`
  - `Future<void> loadPatientPrescriptions(String patientId)`
  - `Future<String?> createPrescription(PrescriptionModel prescription)`
  - `Future<void> updatePrescription(PrescriptionModel prescription)`
  - `Future<String?> uploadPatientDocument({required String patientId, required String title, Uint8List? bytes, String? fileName, String contentType = 'image/png', String? existingRecordId, String? doctorId, String? note})`
  - `void clearActionState()`
  - `Future<void> reset()`
- **State Alanları ve Yardımcı Getter'lar (`MedicalRecordsState`):**
  - Alanlar: `resultsStatus` (`DataStatus`), `prescriptionsStatus` (`DataStatus`), `actionStatus` (`ActionStatus`), `results` (`List<ResultModel>`), `prescriptions` (`List<PrescriptionModel>`), `uploadProgress` (`double?`), `resultsError`, `prescriptionsError`, `actionError`, `actionSuccessMessage`
  - Getter ve Metotlar: `readyResults`, `resultsByCategory(String category)`, `approvedPrescriptions`, `draftPrescriptions`
- **Kullanılan Firebase Servisleri:**
  - `FirestoreService` (`streamResultsByPatient`, `streamPrescriptionsByPatient`, `streamPrescriptionsByDoctor`, `getPrescriptionsByDoctor`, `getPrescriptionsByPatient`, `createPrescription`, `getPrescription`, `updatePrescription`)
  - `StorageService` (`uploadAndSavePatientDocument`)
- **Yönetilen İş Kuralları:**
  - **Onaylanmış Reçete Değiştirilemezliği (`project.md` kuralı):** `updatePrescription` hem yerel listede hem de güncelleme öncesi `getPrescription` ile uzak belgede `isApproved == true` kontrolü yapar; onaylanmış reçetelerin güncellenmesini `"Onaylanmış reçete üzerinde değişiklik yapılamaz."` hatasıyla engeller.
  - Reçete oluşturma/güncelleme öncesinde hasta kimliği, doktor kimliği, tanı (`diagnosis`), en az bir ilaç kalemi ve boş olmayan ilaç adları doğrulanır.
  - Sonuçlar (`resultsStatus`) ve reçeteler (`prescriptionsStatus`) birbirinden bağımsız iki ayrı akış olarak yönetilir.
  - Spark planında `StorageService` yerel fallback URL döndürdüğünde de `uploadProgress` (`0.0 -> 1.0`) ve Firestore kayıt akışı kesintisiz çalışır.
- **Stream ve Asenkron İşlem Yönetimi:**
  - `_resultsSubscription` ve `_prescriptionsSubscription` bağımsız yönetilir; `_resultsOperationToken`, `_prescriptionsOperationToken`, `_actionOperationToken` ve `_prescriptionsRevision` ile eşzamanlılık korunur.
- **Tamamlanma Durumu:** Tamamlandı (`flutter analyze` — 0 sorun).

---

### 2.6. `VitalCubit` & `VitalState`

- **Dosya Yolları:**
  - `lib/presentation/cubits/vital/vital_state.dart`
  - `lib/presentation/cubits/vital/vital_cubit.dart`
- **Public Metotlar (`VitalCubit`):**
  - `void watchPatientVitals(String patientId)`
  - `Future<void> loadPatientVitals(String patientId)`
  - `Future<String?> createVital(VitalModel vital)`
  - `Future<String?> recordVital({required String patientId, required int systolic, required int diastolic, required int bloodSugar, required int pulse, int oxygen = 98, DateTime? createdAt})`
  - `Future<void> updateVital(VitalModel vital)`
  - `void clearActionState()`
  - `Future<void> reset()`
- **State Alanları ve Yardımcı Getter'lar (`VitalState`):**
  - Alanlar: `dataStatus`, `actionStatus`, `vitals` (`List<VitalModel>`), `dataError`, `actionError`, `actionSuccessMessage`
  - Getter ve Metotlar: `sortedByNewest`, `chronologicalVitals`, `latestVital`, `criticalVitals`, `hasCriticalVital`, `isLatestVitalCritical`, `chartVitalsForPeriod({int? days, int? maxPoints})`
- **Kullanılan Firebase Servisleri:**
  - `FirestoreService` (`streamVitalsByPatient`, `getCollection`, `createVital`, `updateDocument`)
- **Yönetilen İş Kuralları:**
  - Tıbbi tanı veya yeni klinik eşik algoritması uydurulmamıştır; kritik değer tespiti yalnızca `VitalModel.isCritical` getter'ına (`systolic >= 140 || diastolic >= 90 || bloodSugar >= 180 || bloodSugar < 70 || pulse > 110 || pulse < 50 || oxygen < 94`) dayanır.
  - Kayıt öncesi veri bütünlüğü kontrolleri: `patientId` boş olamaz, `systolic > 0`, `diastolic > 0`, `systolic > diastolic`, `bloodSugar > 0`, `pulse > 0`, `1 <= oxygen <= 100`.
  - Liste ekranları için yeniden eskiye (`sortedByNewest`), grafik çizimleri için eskiden yeniye (`chronologicalVitals` ve `chartVitalsForPeriod`) sıralama yardımcıları sunulmuştur.
- **Tamamlanma Durumu:** Tamamlandı (`flutter analyze` — 0 sorun).

---

### 2.7. `ChatCubit` & `ChatState`

- **Dosya Yolları:**
  - `lib/presentation/cubits/chat/chat_state.dart`
  - `lib/presentation/cubits/chat/chat_cubit.dart`
- **Public Metotlar (`ChatCubit`):**
  - `void watchConversation({required String patientId, required String doctorId})`
  - `Future<void> loadConversation({required String patientId, required String doctorId})`
  - `Future<String?> sendMessage({required String patientId, required String doctorId, required String senderId, required String receiverId, required String text, String? attachmentUrl})`
  - `Future<bool> markMessageAsRead(String messageId)`
  - `Future<bool> markConversationReadForReceiver(String receiverId)`
  - `void clearActionState()`
  - `Future<void> reset()`
- **State Alanları ve Yardımcı Getter'lar (`ChatState`):**
  - Alanlar: `dataStatus`, `actionStatus`, `conversationId`, `patientId`, `doctorId`, `messages` (`List<MessageModel>`), `dataError`, `actionError`, `actionSuccessMessage`
  - Getter ve Metotlar: `hasActiveConversation`, `hasMessages`, `chronologicalMessages`, `newestFirstMessages`, `lastMessage`, `unreadMessages`, `unreadCount`, `unreadMessagesForUser(String receiverId)`, `unreadCountForUser(String receiverId)`
- **Kullanılan Firebase Servisleri:**
  - `FirestoreService` (`streamMessagesByConversation`, `getCollection`, `sendMessage`, `updateDocument`)
- **Yönetilen İş Kuralları:**
  - Standart konuşma kimliği `MessageModel.buildConversationId(patientId, doctorId)` (`${patientId}_${doctorId}`) ile üretilir.
  - `patientId` ve `doctorId` boş olamaz ve birbirine eşit olamaz. `sendMessage` içinde `senderId` ve `receiverId` çiftinin konuşmadaki `{patientId, doctorId}` çiftiyle birebir eşleşmesi zorunludur.
  - Hem `text` hem `attachmentUrl` boşsa mesaj gönderimi engellenir.
  - Mesajlar `id` bazında tekilleştirilir ve `createdAt` zaman damgasına göre deterministik olarak sıralanır; gönderim sonrası yerel güncelleme ile stream snapshot'ının çift (duplicate) mesaj üretmesi önlenir.
- **Tamamlanma Durumu:** Tamamlandı (`flutter analyze` — 0 sorun).

---

## 3. Doğrulama Durumu (Statik Analiz vs. Testler)

- **Statik Analiz (`flutter analyze lib/presentation/cubits`):**
  - Tüm 14 Cubit/State/Barrel dosyası üzerinde çalıştırılmış ve **0 hata / 0 uyarı** (`No issues found!`) ile doğrulanmıştır.
- **Birim Testleri:**
  - `test/cubits/cubit_status_test.dart` dosyasında `DataStatus` ve `ActionStatus` için 11 birim testi yazılmış ve tamamı geçmiştir (`flutter test test/cubits/cubit_status_test.dart`).
  - Diğer Cubit sınıfları için kapsamlı birim testleri ve uygulama genelindeki widget/entegrasyon testleri bu aşamada çalıştırılmamıştır; genel uygulama testleri Geliştirici 5 kapsamı dışındadır.

---

## 4. Entegrasyon Bulguları, Şema Uyumsuzlukları ve Güvenlik Riskleri

> **Önemli Not:** Aşağıda listelenen Firebase servis eksikleri, Firestore/Storage Security Rules tanımları, reçete transaction koruması ve doktor konuşma listesi veri akışı henüz bu branch'te (`feature/dev5-state-management`) uygulanmamıştır; bu maddeler **ayrı bir Firebase/Backend geliştirme kapsamında (`feat/dev3-services-fixes` branch'i üzerinde)** tamamlanacaktır.

### 4.1. `LoginScreen` TC Kimlik / E-Posta Giriş Uyumsuzluğu
- **Durum:** `LoginScreen` (`lib/presentation/screens/auth/login_screen.dart`) kullanıcıdan 11 haneli TC Kimlik Numarası (veyaデモ hesap TC'si) istemektedir; ancak `AuthService.signIn` (`FirebaseAuth.signInWithEmailAndPassword`) yalnızca e-posta adresi ve şifre kabul etmektedir.
- **Çözüm Yolu:** Geliştirici 6 ekran entegrasyonunda giriş alanı e-posta formatını destekleyecek şekilde bağlanmalı veya TC Kimlik Numarası ile giriş için Firebase/servis katmanında TC -> e-posta çözümleme adımı kullanılmalıdır.

### 4.2. `DoctorScheduleModel` ve Gün Bazlı Çalışma Saatleri Uyumsuzluğu
- **Durum:** `DoctorSchedulePricingScreen` arayüzünde her gün için ayrı başlangıç/bitiş saati gösterilmek istenebilmektedir; ancak mevcut `DoctorScheduleModel` (`lib/data/models/doctor_schedule_model.dart`) haftanın 7 günü için `List<bool> workingDays` ve tüm çalışma günleri için tek bir `workStart`, `workEnd`, `breakRange` ve `Map<String, String> timeSlots` tutmaktadır.
- **Çözüm Yolu:** `DoctorScheduleCubit` gerçek `DoctorScheduleModel` şemasını esas alarak geliştirilmiştir; Geliştirici 6 ekranı bağlarken `workingDays`, `workStart`, `workEnd`, `breakRange` ve `timeSlots` alanlarını doğrudan kullanmalıdır.

### 4.3. Reçete Transaction ve Firestore Security Rules Gereksinimi
- **Durum:** `MedicalRecordsCubit.updatePrescription` istemci tarafında `getPrescription` ile `isApproved` kontrolü yapmaktadır; ancak iki eşzamanlı istek arasında yarış durumu (race condition) oluşmaması için `FirestoreService.updatePrescription` ve `deletePrescription` metotlarının Firestore `runTransaction` ile atomik hale getirilmesi ve `firestore.rules` üzerinde `resource.data.isApproved == false` şartının zorunlu kılınması gerekmektedir. (Henüz uygulanmadı; `feat/dev3-services-fixes` kapsamında tamamlanacak.)

### 4.4. Hasta Sağlık Verilerine Rol ve Sahiplik Bazlı Erişim Yetkileri
- **Durum:** Projede henüz `firestore.rules` ve `storage.rules` dosyaları bulunmamaktadır.
- **Risk ve Tasarım Kararı:** Doktor rolüne sahip olmak tüm hastaların verilerine erişim hakkı vermemelidir. Doktor yalnızca yetkili olduğu (`resource.data.doctorId == request.auth.uid`) kayıtlara erişebilmelidir. `vitals`, `tooth_records` ve `payments` koleksiyonlarında `doctorId` alanı bulunmadığı için bu koleksiyonlarda geniş doktor izni verilmemeli, yalnızca veri sahibi hastaya (`patientId == request.auth.uid`) erişim tanınmalı veya doğrulanabilir doktor ilişkisi aranmalıdır. Kullanıcıların `users/{userId}` belgesindeki `role` alanını sonradan değiştirmesi Security Rules ile engellenmelidir. (Henüz uygulanmadı; `feat/dev3-services-fixes` kapsamında tamamlanacak.)

### 4.5. Mesajlaşma Güvenliği ve Okundu (`isRead`) Kısıtı
- **Durum:** `messages` koleksiyonunda mesaj gönderme, okuma ve `isRead` güncellemesi şu an yalnızca `ChatCubit` istemci kontrolleriyle doğrulanmaktadır.
- **Gereksinim:** `firestore.rules` içinde mesajların yalnızca konuşma taraflarınca okunabilmesi, `senderId == request.auth.uid` doğrulaması ve `isRead` alanının **yalnızca mesajın alıcısı (`resource.data.receiverId == request.auth.uid`)** tarafından `true` değerine güncellenebilmesi kural altına alınacaktır.

### 4.6. Doktor Konuşma Listesi ve Eksik Yardımcı Servis Metotları
- **Durum:** `DoctorMessagesScreen` ekranında doktorun mesajlaştığı hastaların konuşma özetleri (son mesaj, zaman, okunmamış sayısı) listelenmektedir; ancak `FirestoreService` içinde henüz `streamMessagesByDoctor(String doctorId)`, `markMessageAsRead`, `markConversationMessagesAsRead` ve konuşma özeti modeli (`ConversationSummaryModel`) bulunmamaktadır. Ayrıca `VitalCubit` ve `ChatCubit` bazı tek seferlik okuma/güncelleme işlemlerinde genel `getCollection` ve `updateDocument` metotlarını kullanmaktadır.
- **Çözüm Yolu:** Bu servis metotları ve konuşma özeti akışı `feat/dev3-services-fixes` branch'inde tamamlanacaktır.

---

## 5. Geliştirici 6 İçin Cubit, `ServiceLocator` ve `BlocProvider` Entegrasyon Rehberi

### 5.1. `ServiceLocator` ve `BlocProvider` Kurulumu
- Tüm Cubit'ler `ServiceLocator.setup()` çalıştırıldıktan sonra parametresiz olarak oluşturulabilir (`AuthCubit()`, `AppointmentCubit()`, vb.).
- **Önerilen Sağlayıcı (Provider) Yapısı:**
  - `main.dart` / `DentoraApp` kökünde `MultiBlocProvider` (veya tekil `BlocProvider`) ile `AuthCubit` uygulama genelinde sağlanmalı ve başlangıçta `watchAuthState()` (veya `checkSession()`) çağrılmalıdır.
  - `AppointmentCubit`, `DoctorScheduleCubit`, `MedicalRecordsCubit`, `VitalCubit` ve `ChatCubit` ilgili hasta/doktor kabuklarında (`PatientShell`, `DoctorShell`) veya ekran bazlı `BlocProvider` ile sağlanmalıdır.

### 5.2. Oturum Kapatma (`signOut`) ve Kullanıcı Değişiminde Temizlik
- Kullanıcı çıkış yaptığında veya `AuthState.sessionStatus` değeri `unauthenticated` / `profileUnavailable` olduğunda, bellekteki hasta/doktor verilerinin ve açık Firestore Stream aboneliklerinin temizlenmesi için aktif Cubit'lerin `reset()` metotları çağrılmalıdır:
  - `appointmentCubit.reset()`
  - `doctorScheduleCubit.reset()`
  - `medicalRecordsCubit.reset()`
  - `vitalCubit.reset()`
  - `chatCubit.reset()`

### 5.3. Ekran Bazlı Cubit Eşleşmesi
| Ekran / Akış | Kullanılacak Cubit | Başlatma Metodu | Temel Aksiyon Metotları |
| :--- | :--- | :--- | :--- |
| `SplashScreen`, `LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`, `PatientProfileScreen` | `AuthCubit` | `watchAuthState()` / `checkSession()` | `signIn`, `signUp`, `signOut`, `sendPasswordReset`, `updateProfile`, `uploadProfilePhoto` |
| `PatientHomeScreen`, `PatientAppointmentsScreen`, `DoctorAgendaScreen` | `AppointmentCubit` | `watchPatientAppointments(uid)` / `watchDoctorAppointments(uid)` | `bookAppointment`, `cancelAppointment`, `updateAppointmentStatus`, `updateAppointmentNote` |
| `PatientBookAppointmentScreen`, `PatientBookCalendarScreen`, `DoctorSchedulePricingScreen` | `DoctorScheduleCubit` + `AppointmentCubit` | `watchDoctorSchedule(doctorId)` | `getAvailableSlotsForDate(date)`, `saveSchedule`, `updateWorkingSchedule`, `updateSlotStatus`, `updateProcedures`, `updateProcedureItem` |
| `PatientResultsScreen`, `DoctorPrescriptionScreen`, `DoctorPastPatientsScreen` | `MedicalRecordsCubit` | `watchPatientRecords(patientId)` / `watchDoctorPrescriptions(doctorId)` | `createPrescription`, `updatePrescription`, `uploadPatientDocument` |
| `PatientVitalsScreen` | `VitalCubit` | `watchPatientVitals(patientId)` | `recordVital`, `createVital`, `updateVital` |
| `PatientChatScreen`, `DoctorMessagesScreen` | `ChatCubit` | `watchConversation(patientId: ..., doctorId: ...)` | `sendMessage`, `markMessageAsRead`, `markConversationReadForReceiver` |

