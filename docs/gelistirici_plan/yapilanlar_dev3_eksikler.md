# Geliştirici 3 — Firebase & Backend Eksiklerini Tamamlama Teknik Raporu

Bu belge, **VitalSync (Dentora)** projesinde `feat/dev3-services-fixes` branch'i üzerinde gerçekleştirilen Firebase güvenlik kuralları (`firestore.rules`, `storage.rules`), bileşik indeks yapılandırması (`firestore.indexes.json`) ve `FirestoreService` üzerindeki reçete transaction korumaları ile tamamlayıcı yardımcı metotları içerir.

---

## 1. Çalışmanın Amacı ve Kapsamı

- **Temel İlke:** Geliştirici 3'ün daha önce hazırladığı `AuthService`, `FirestoreService` ve `StorageService` mimarisi, mevcut metot imzaları ve çalışma davranışları **hiç bozulmadan** korunmuştur.
- **Kapsam:**
  1. Firestore ve Firebase Storage için en az yetki (least privilege) ilkesine dayalı güvenlik kurallarının ve gerekli bileşik indekslerin oluşturulması.
  2. Onaylanmış reçetelerin (`isApproved == true`) değiştirilemezliği kuralının `FirestoreService` içerisinde atomik Firestore Transaction (`runTransaction`) ile güvence altına alınması.
  3. Mevcut koleksiyonlar (`vitals`, `results`, `messages`) için eksik olan tek seferlik okuma, güncelleme, okundu işaretleme ve doktor mesaj akışı yardımcı metotlarının geriye dönük uyumlu şekilde `FirestoreService` içerisine eklenmesi.

---

## 2. Firebase Aşama 1 — Güvenlik Kuralları ve İndeks Yapılandırması

### 2.1. Oluşturulan ve Güncellenen Yapılandırma Dosyaları
- `firestore.rules` (Yeni oluşturuldu)
- `storage.rules` (Yeni oluşturuldu)
- `firestore.indexes.json` (Yeni oluşturuldu)
- `firebase.json` (Mevcut `flutter` platform ayarları korunarak `firestore` ve `storage` kural/indeks dosya referansları eklendi)

### 2.2. `firestore.rules` Özeti
- **`users/{userId}`:**
  - Kullanıcı yalnızca kendi profilini (`request.auth.uid == userId`) ve randevu/hekim seçimi için doktor profillerini (`resource.data.role == 'doctor'`) okuyabilir; hasta profillerinin toplu listelenmesi engellenmiştir.
  - Kayıt (`create`) sırasında istemcinin kendi kendine `'doctor'` rolü ataması engellenmiştir (`role == 'patient'` veya doğrulanmış `request.auth.token.role == 'doctor'`).
  - Güncelleme (`update`) sırasında `role`, `id`, `uid` ve `email` alanlarının değiştirilmesi kesin olarak engellenmiştir.
- **`doctor_schedules/{doctorId}`:**
  - Oturum açmış kullanıcılar okuyabilir (`read`); yalnızca ilgili doktor (`isDoctor() && request.auth.uid == doctorId`) 7 günlük çalışma dizisiyle yazabilir (`create`, `update`).
- **`appointments/{appointmentId}`:**
  - Yalnızca randevu sahibi hasta (`resource.data.patientId == request.auth.uid`) veya ilgili doktor (`isDoctor() && resource.data.doctorId == request.auth.uid`) okuyabilir.
  - Hasta yalnızca kendi adına `'pending'` durumunda randevu oluşturabilir ve aktif randevusunu `'cancelled'` durumuna çekebilir veya notunu güncelleyebilir; ilgili doktor randevu durumunu ve notunu güncelleyebilir.
- **`prescriptions/{prescriptionId}`:**
  - Yalnızca reçetenin hastası veya reçeteyi oluşturan doktor okuyabilir.
  - Yalnızca yetkili doktor (`isDoctor() && request.resource.data.doctorId == request.auth.uid`) oluşturabilir.
  - Yalnızca reçeteyi oluşturan doktor ve **yalnızca mevcut reçete henüz onaylanmamışsa (`resource.data.isApproved == false`)** güncelleyebilir veya silebilir. Onaylanmış (`isApproved == true`) reçetelerin güncellenmesi ve silinmesi sunucu tarafında kapatılmıştır.
- **`results/{resultId}`, `treatments/{treatmentId}`, `tooth_records/{recordId}`, `payments/{paymentId}`:**
  - Yalnızca verinin sahibi hasta (`resource.data.patientId == request.auth.uid`) veya belge üzerinde `doctorId == request.auth.uid` olarak kayıtlı yetkili doktor erişebilir.
- **`vitals/{vitalId}`:**
  - `VitalModel` şemasında `doctorId` alanı bulunmadığından doktorlara genel erişim izni verilmemiştir; yalnızca veri sahibi hasta (`patientId == request.auth.uid`) sayısal doğrulama kurallarıyla (`systolic > diastolic > 0`, `1 <= oxygen <= 100`, vb.) okuyabilir, oluşturabilir ve güncelleyebilir.
- **`messages/{messageId}`:**
  - Yalnızca konuşmanın tarafları (`patientId`, `doctorId`, `senderId` veya `receiverId == request.auth.uid`) okuyabilir.
  - Gönderen oturum açmış kullanıcı olmalı (`senderId == request.auth.uid`), `{senderId, receiverId}` çifti `{patientId, doctorId}` ile eşleşmeli, `conversationId == patientId + '_' + doctorId` olmalı ve `isRead == false` olarak başlamalıdır.
  - `update` işlemi **yalnızca mesajın alıcısı (`resource.data.receiverId == request.auth.uid`)** tarafından yapılabilir; yalnızca `['isRead', 'updatedAt']` alanları değişebilir ve `request.resource.data.isRead == true` olmalıdır.
- **Varsayılan Kural (`/{document=**}`):** Tanımlanmamış tüm koleksiyon ve belgelere erişim reddedilir (`allow read, write: if false;`).

### 2.3. `storage.rules` Özeti
- **`users/{userId}/profile/{fileName}`:**
  - Yalnızca profil sahibi (`request.auth.uid == userId`) okuyabilir, yazabilir ve silebilir; yüklemelerde içerik tipi `image/(png|jpeg|jpg|webp)` ve maksimum boyut `5 MB` ile sınırlandırılmıştır.
- **`patients/{patientId}/documents/{fileName}`:**
  - Yalnızca ilgili hasta (`request.auth.uid == patientId`) okuyabilir, yazabilir ve silebilir; içerik tipi `image/(png|jpeg|jpg|webp)` veya `application/pdf` ve maksimum boyut `10 MB` ile sınırlandırılmıştır. Kullanıcı tarafından değiştirilebilen Storage `metadata` alanları yetki kanıtı olarak kabul edilmemiştir.
- **Varsayılan Kural (`/{allPaths=**}`):** Diğer tüm dosya yollarına erişim reddedilir.

### 2.4. `firestore.indexes.json` Özeti
Yalnızca çoklu alan filtresi gerektiren sorgular için 3 bileşik indeks tanımlanmıştır:
1. `appointments`: `doctorId` (ASC) + `date` (ASC) + `time` (ASC)
2. `results`: `doctorId` (ASC) + `patientId` (ASC)
3. `messages`: `conversationId` (ASC) + `receiverId` (ASC) + `isRead` (ASC)

---

## 3. Firebase Aşama 2 — `FirestoreService` Transaction Koruması ve Eklenen Yardımcı Metotlar

`lib/data/services/firestore_service.dart` dosyasında mevcut metot imzaları korunarak yapılan geliştirmeler:

### 3.1. Transaction Korumalı Reçete Metotları
| Metot | Parametreler | Dönüş Tipi | Görev ve Davranış |
| :--- | :--- | :--- | :--- |
| `updatePrescription` | `String prescriptionId, Map<String, dynamic> data` | `Future<void>` | Reçete belgesini `_firestore.runTransaction` içinde okur; belge yoksa `'prescription-not-found'`, `existingData?['isApproved'] != false` ise `'prescription-already-approved'` hatası fırlatır. Yalnızca `isApproved == false` ise günceller. |
| `deletePrescription` | `String prescriptionId` | `Future<void>` | Reçete belgesini `_firestore.runTransaction` içinde okur; belge yoksa `'prescription-not-found'`, `existingData?['isApproved'] != false` ise `'prescription-already-approved'` hatası fırlatır. Yalnızca `isApproved == false` ise siler. |

### 3.2. Eklenen 8 Yardımcı Metot
| Koleksiyon | Metot | Parametreler | Dönüş Tipi | Görevi |
| :--- | :--- | :--- | :--- | :--- |
| `vitals` | `getVitalsByPatient` | `String patientId` | `Future<List<Map<String, dynamic>>>` | Hastaya ait yaşamsal sağlık ölçümlerini `createdAt` azalan sırayla tek seferlik getirir. |
| `vitals` | `updateVital` | `String vitalId, Map<String, dynamic> data` | `Future<void>` | Mevcut bir yaşamsal sağlık ölçüm belgesini günceller. |
| `results` | `getResultsByPatient` | `String patientId` | `Future<List<Map<String, dynamic>>>` | Hastaya ait tahlil/röntgen sonuçlarını `createdAt` azalan sırayla tek seferlik getirir. |
| `messages` | `getMessagesByConversation` | `String conversationId` | `Future<List<Map<String, dynamic>>>` | Belirtilen `conversationId` değerine ait mesaj geçmişini `createdAt` artan sırayla tek seferlik getirir. |
| `messages` | `markMessageAsRead` | `String messageId` | `Future<void>` | Tek bir mesajın yalnızca `isRead: true` (ve `updatedAt`) alanını günceller; mesaj içeriğine ve kimlik alanlarına dokunmaz. |
| `messages` | `markConversationMessagesAsRead` | `{required String conversationId, required String receiverId}` | `Future<int>` | Konuşmada ilgili alıcıya (`receiverId`) ait okunmamış (`isRead == false`) mesajları sorgular ve `WriteBatch` ile toplu olarak `isRead: true` işaretler; güncellenen mesaj sayısını döndürür. |
| `messages` | `getMessagesByDoctor` | `String doctorId` | `Future<List<Map<String, dynamic>>>` | Doktora ait mesajları `doctorId` filtresi ve `createdAt` azalan sırayla tek seferlik getirir. |
| `messages` | `streamMessagesByDoctor` | `String doctorId` | `Stream<List<Map<String, dynamic>>>` | Doktora ait mesajları `doctorId` filtresi ve `createdAt` azalan sırayla gerçek zamanlı dinler. |

---

## 4. Reçete Güvenliği (`isApproved != false` Koruması)

- `PrescriptionModel.fromJson` (`lib/data/models/prescription_model.dart`) belgede `isApproved` alanı eksik veya `null` olduğunda varsayılan olarak `true` (onaylanmış/değiştirilemez) kabul etmektedir (`isApproved: json['isApproved'] as bool? ?? true`).
- `firestore.rules` içinde de güncelleme ve silme işlemleri yalnızca `resource.data.isApproved == false` koşulunda açıktır.
- Bu nedenle `FirestoreService.updatePrescription` ve `FirestoreService.deletePrescription` metotlarında `if (existingData?['isApproved'] != false)` kontrolü uygulanmıştır. Böylece yalnızca açıkça `isApproved == false` olan taslak reçeteler düzenlenebilir veya silinebilir; onaylanmış (`true`) veya alanı eksik/bozuk belgeler hem istemci servisinde (transaction içinde) hem de Firestore Security Rules katmanında engellenir.

---

## 5. Korunan Mevcut Çalışmalar

Geriye dönük uyumluluk kararı doğrultusunda aşağıdaki yapı ve dosyalara **hiç dokunulmamıştır**:
- `lib/data/services/auth_service.dart` (Giriş, kayıt, şifre sıfırlama ve rol okuma davranışları korundu)
- `lib/data/services/storage_service.dart` (Spark planı yerel fallback mekanizması ve Storage dosya yolları korundu)
- `FirestoreService.bookAppointmentIfAvailable` (Mevcut randevu çakışma sorgusu ve belge oluşturma algoritması korundu)
- `lib/data/models/` altındaki tüm veri modelleri (`UserModel`, `AppointmentModel`, `VitalModel`, `PrescriptionModel`, `ResultModel`, `MessageModel`, `DoctorScheduleModel`)
- Geliştirici 5 Cubit/State dosyaları (`feature/dev5-state-management` branch'inde ayrı tutuldu) ve Geliştirici 6 UI ekranları

---

## 6. Bilinen Teknik Kısıtlar ve Security Rules Uyumsuzlukları

Mevcut servis metotlarının davranışları değiştirilmediği ve güvenlik kuralları (`firestore.rules`, `storage.rules`) gevşetilmediği için canlı Security Rules devredeyken bilinen kısıtlar şunlardır:

1. **İstemci Üzerinden Doktor Kaydı (`AuthService.signUp`):**
   - `AuthService.signUp(role: 'doctor')` istemciden doğrudan `role: 'doctor'` yazmaya çalışır; ancak `firestore.rules` istemcinin kendi kendine doktor yetkisi vermesini (`request.auth.token.role == 'doctor'` olmadan) engellediği için canlı kurallar altında `permission-denied` alır. Doktor hesapları Firebase Console / Admin üzerinden tanımlanmalıdır.
2. **Hasta Tarafında Randevu Çakışma Sorgusu (`bookAppointmentIfAvailable` & `streamAppointmentsByDoctor`):**
   - Bu metotlar doktorun randevu belgelerini `doctorId` üzerinden sorgular. Hastaların başka hastaların kişisel randevu belgelerini okuması `firestore.rules` ile kapatıldığı için, hasta oturumuyla bu sorgular çalıştırıldığında `permission-denied` döner.
3. **Doktorun Hasta Listesi ve Hasta Verisi Sorguları (`getPatients`, `vitals`, `results`, `tooth_records`, `payments`):**
   - `getPatients()` / `streamPatients()` tüm hasta profillerini (`role == 'patient'`) sorgular; genel hasta listeleme kapalı olduğundan `permission-denied` döner.
   - `vitals` belgelerinde `doctorId` alanı bulunmadığı için doktor oturumuyla `getVitalsByPatient` / `streamVitalsByPatient` çağrıları `permission-denied` alır.
   - `getResultsByPatient`, `streamResultsByPatient`, `streamToothRecordsByPatient` ve `streamPaymentsByPatient` yalnızca `patientId` filtrelediği için hasta oturumunda çalışır; doktor oturumunda ise `doctorId == request.auth.uid` filtresi içermediğinden `firestore.rules` tarafından reddedilir.
4. **Uzak Storage Hasta Belgesi Yükleme (`StorageService.uploadAndSavePatientDocument`):**
   - Uzak Storage açıkken (`enableRemoteStorage = true`), `patients/{patientId}/documents/` yolu yalnızca ilgili hastaya (`isOwner(patientId)`) açıktır; doktorun bu klasöre doğrudan uzak dosya yazması/okuması `storage.rules` tarafından engellenir (varsayılan Spark planında `enableRemoteStorage = false` olduğu için yerel fallback URL akışı etkilenmez).
5. **Mesajlaşma Konuşma Sorgusu (`streamMessagesByConversation` / `getMessagesByConversation`):**
   - Bu metotlar `messages` koleksiyonunu yalnızca `where('conversationId', isEqualTo: conversationId)` ile sorgular. `firestore.rules` içindeki `messages` `allow read` kuralı katılımcı kimliği (`patientId`, `doctorId`, `senderId` veya `receiverId == request.auth.uid`) aradığı için, katılımcı filtresi içermeyen tek alanlı `conversationId` sorgusu canlı kurallar altında `permission-denied` alır.

---

## 7. Doğrulama Sonuçları

- **Statik Analiz (`flutter analyze lib/data/services`):**
  - Sonuç: `No issues found!` (**0 hata, 0 uyarı**).
- **Mevcut Birim Testleri (`flutter test test/firebase_services_test.dart`):**
  - Sonuç: **3 / 3 başarılı** (`ServiceLocator` kaydı, `StorageService` hasta belgesi fallback testi, `StorageService` profil fotoğrafı fallback testi).
  - **Test Kapsamı Notu:** `test/firebase_services_test.dart` içindeki mevcut 3 test yalnızca `ServiceLocator` ve `StorageService` yerel fallback akışını doğrulamaktadır; Aşama 2'de `FirestoreService` içine eklenen reçete transaction korumaları ve 8 yeni yardımcı metot için henüz özel birim testi bulunmamaktadır.

---

## 8. Teslim Durumu

- **Aktif Branch:** `feat/dev3-services-fixes`
- **Değiştirilen Dosyalar (Modified):**
  - `firebase.json`
  - `lib/data/services/firestore_service.dart`
- **Oluşturulan Dosyalar (Untracked):**
  - `firestore.rules`
  - `storage.rules`
  - `firestore.indexes.json`
  - `docs/gelistirici_plan/yapilanlar_dev3_eksikler.md`
- **Git Commit / Push Durumu:** Henüz commit ve push yapılmamıştır (kullanıcı onayı beklenmektedir).
- **Firebase Deploy Durumu:** Canlı Firebase (Firestore / Storage) ortamına **deploy yapılmamıştır**.
