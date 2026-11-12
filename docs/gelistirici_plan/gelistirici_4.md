
# Geliştirici 4 — Data Models & DTO Lead

## 1. Görev

Uygulamada kullanılacak veri modellerini ve Firestore veri düzenini hazırlamak.

Amaç, tüm geliştiricilerin aynı veri alanlarını ve aynı model yapısını kullanmasını sağlamaktır.

## 2. Sorumluluklar

Temel modeller:

- User
- Appointment
- Vital
- Prescription
- Result
- Message
- DoctorSchedule

Her model için ihtiyaç duyulan alanlar belirlenmelidir.

Örnek:

**Appointment**
- id
- patientId
- doctorId
- serviceName
- date
- time
- status
- note

**Vital**
- id
- patientId
- systolic
- diastolic
- bloodSugar
- pulse
- oxygen
- createdAt

**Prescription**
- id
- patientId
- doctorId
- diagnosis
- medicines
- doctorNote
- createdAt

Gerekli modellerde:

- `fromJson`
- `toJson`
- `copyWith`

fonksiyonları hazırlanmalıdır.

Firestore koleksiyon ve alan isimleri tutarlı olmalıdır.

## 3. Diğer Geliştiricilerle Bağımlılık

- Geliştirici 3 ile Firebase ve Firestore veri yapısı konusunda birlikte çalışır.
- Geliştirici 5, Cubit ve state işlemlerinde bu modelleri kullanır.
- Geliştirici 6, ekranlarda verileri bu modeller üzerinden gösterir.

**Önemli:** Modeller ve alan isimleri mümkün olduğunca erken belirlenmelidir. Diğer geliştiriciler aynı veriyi farklı isimlerle tanımlamamalıdır.

## 4. Çalışma Kuralları

- Gereksiz model ve alan oluşturma.
- Yalnızca projede gerçekten kullanılacak verileri tanımla.
- Model isimlerini ve alanlarını diğer geliştiricilerle paylaş.
- Bir model değiştirildiğinde ilgili geliştiricilere haber ver.
- Karmaşık veri dönüştürme yapılarından kaçın.

Proje geliştirilirken kısa, anlamlı ve sade Türkçe yorum satırları eklenebilir.

---

## 5. Tamamlanan Modeller ve Firestore Şema Özeti (`lib/data/models/`)

Geliştirici 3'ün hazırladığı `AuthService`, `FirestoreService` ve `StorageService` alanlarıyla birebir uyumlu 7 temel model (`fromJson`, `toJson`, `copyWith` ve `Timestamp` dönüşümleriyle) `lib/data/models/models.dart` altında toplanmıştır:

1. **`UserModel` (`user_model.dart` — Koleksiyon: `users`)**
   - Alanlar: `id` (`uid`), `fullName`, `email`, `phone`, `tcNo`, `role` (`patient` / `doctor`), `titleOrInfo`, `avatarUrl` (`photoUrl`), `createdAt`
2. **`AppointmentModel` (`appointment_model.dart` — Koleksiyon: `appointments`)**
   - Alanlar: `id`, `patientId`, `patientName`, `doctorId`, `doctorName`, `serviceName`, `price`, `date`, `time`, `status` (`pending` / `approved` / `completed` / `cancelled`), `note`, `createdAt`
3. **`VitalModel` (`vital_model.dart` — Koleksiyon: `vitals`)**
   - Alanlar: `id`, `patientId`, `systolic`, `diastolic`, `bloodSugar`, `pulse`, `oxygen`, `createdAt` (+ `isCritical`, `bloodPressureText`)
4. **`PrescriptionModel` & `MedicineItem` (`prescription_model.dart` — Koleksiyon: `prescriptions`)**
   - Alanlar: `id`, `patientId`, `patientName`, `doctorId`, `doctorName`, `diagnosis`, `medicines` (`List<MedicineItem>`), `doctorNote`, `isApproved`, `createdAt`
5. **`ResultModel` (`result_model.dart` — Koleksiyon: `results`)**
   - Alanlar: `id`, `patientId`, `doctorId`, `doctorName`, `title`, `category` (`radiology` / `lab` / `report`), `summary` (`note`), `fileUrl` (`downloadUrl`), `status`, `isLocalFallback`, `createdAt`
6. **`MessageModel` (`message_model.dart` — Koleksiyon: `messages`)**
   - Alanlar: `id`, `conversationId`, `senderId`, `receiverId`, `patientId`, `doctorId`, `text`, `attachmentUrl`, `isRead`, `createdAt`
7. **`DoctorScheduleModel` & `ProcedurePriceItem` (`doctor_schedule_model.dart` — Koleksiyon: `doctor_schedules`)**
   - Alanlar: `id`, `doctorId`, `workingDays`, `workStart`, `workEnd`, `breakRange`, `slotDurationMinutes`, `timeSlots`, `procedures` (`List<ProcedurePriceItem>`), `updatedAt`

