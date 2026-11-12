
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

