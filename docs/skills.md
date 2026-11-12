
# VitalSync — Technical Skills & Development Rules

Bu dosya, projede kullanılacak Flutter teknolojilerini ve Antigravity'nin uyması gereken teknik kuralları açıklar.

Amaç kısa sürede anlaşılır, çalışan ve bakımı kolay bir uygulama geliştirmektir.

## 1. Flutter & Dart

- Flutter ve Dart kullanılacaktır.
- Null Safety kurallarına uyulmalıdır.
- Widget yapısı sade tutulmalıdır.
- Ekranlar gereksiz yere büyük dosyalara dönüştürülmemelidir.
- Controller ve listener gibi kaynaklar uygun yerde dispose edilmelidir.
- Asenkron işlemlerden sonra gerekli `mounted` kontrolleri yapılmalıdır.

## 2. State Management — Cubit

Projede **flutter_bloc paketinin Cubit yapısı** kullanılacaktır.

BLoC Event yapısı tercih edilmeyecektir. Daha basit ve hızlı geliştirme için Cubit yeterlidir.

Cubit şu işlemlerden sorumludur:

- Ekrandaki verileri yönetmek
- Kullanıcı işlemlerini gerçekleştirmek
- Loading, Error, Empty ve Success durumlarını kontrol etmek
- Repository veya Service üzerinden veri almak ve kaydetmek

Basit ve geçici UI işlemlerinde `setState` kullanılabilir. Ancak Firebase'den gelen verilerin ve temel iş mantığının yönetimi Cubit üzerinden yapılmalıdır.

## 3. Firebase

### Firebase Authentication

- Kayıt olma
- Giriş yapma
- Şifre sıfırlama
- Çıkış yapma

Kullanıcının rolü Firestore üzerindeki kullanıcı profilinden okunmalıdır.

### Cloud Firestore

Uygulamanın temel verileri Firestore üzerinde tutulacaktır.

Örnek koleksiyonlar:

- `users`
- `appointments`
- `vitals`
- `prescriptions`
- `messages`
- `results`
- `doctor_schedules`

Veriler kullanıcı ve doktor ilişkisine uygun şekilde kaydedilmelidir.

Firestore işlemleri ekranların içine yazılmamalıdır. Service veya Repository üzerinden yürütülmelidir.

Canlı güncelleme gereken yerlerde Firestore Stream kullanılabilir.

### Firebase Storage

Yalnızca gerçekten ihtiyaç duyulan dosya ve görseller için kullanılmalıdır.

Örneğin profil fotoğrafı veya hasta tarafından gönderilen görsel.

## 4. Navigation — GoRouter

- Ekranlar arası geçişte GoRouter kullanılacaktır.
- Hasta ve doktor için ayrı portal yönlendirmeleri bulunmalıdır.
- Giriş yapan kullanıcı rolüne göre doğru ana ekrana yönlendirilmelidir.
- Alt navigasyon kullanılan ekranlarda ShellRoute tercih edilebilir.
- Gereksiz karmaşık yönlendirme yapıları oluşturulmamalıdır.

## 5. UI — Material 3

- Material 3 kullanılmalıdır.
- Açık ve koyu tema desteklenmelidir.
- Renkler ve yazı stilleri ortak tema üzerinden yönetilmelidir.
- Ortak buton, kart ve input tasarımları tekrar kullanılmalıdır.
- Ekranlar farklı cihaz boyutlarında taşma yapmamalıdır.
- Tasarımlar mevcut Stitch referanslarına uygun olmalıdır.

## 6. Form Validasyonu

Formlarda Flutter'ın `Form`, `GlobalKey<FormState>` ve `TextFormField` yapıları kullanılmalıdır.

Temel kontroller:

- Zorunlu alanların boş bırakılmaması
- E-posta formatının kontrol edilmesi
- Şifre alanının kontrol edilmesi
- Gerekli alanların doğru formatta girilmesi

Her form için gereksiz karmaşık Regex yapıları oluşturulmamalıdır.

## 7. Dört Temel Ekran Durumu

Veri getiren ekranlarda ihtiyaç duyulduğunda dört durum gösterilmelidir:

- **Loading:** Veri yüklenirken
- **Error:** Veri alınamadığında
- **Empty:** Gösterilecek veri bulunmadığında
- **Success:** Veri başarıyla geldiğinde

Örneğin randevular ekranında:

- Yükleniyor → Loading
- Hata oluştu → Error
- Randevu yok → Empty
- Randevular geldi → Success

Her ekranın bu dört durumu göstermesi zorunlu değildir. Veri kullanan ve liste gösteren ekranlarda uygulanmalıdır.

## 8. Test

Zaman kısıtlı olduğu için öncelikle temel ve önemli işlemler test edilmelidir.

- Unit Test: İş mantığının veya küçük fonksiyonların doğruluğunu kontrol eder.
- Widget Test: Ekrandaki temel widget'ların doğru çalıştığını kontrol eder.

Öncelikli test alanları:

- Form validasyonu
- Randevu çakışması kontrolü
- Kritik vital değer kontrolü
- Temel ekranların açılması

## 9. Kod Kalitesi

- Anlaşılır ve kısa kod yazılmalıdır.
- Gereksiz paket eklenmemelidir.
- Aynı işlevi yapan tekrar eden fonksiyonlar oluşturulmamalıdır.
- Ekranlarda overflow hatası olmamalıdır.
- Hata durumlarında kullanıcıya anlaşılır mesaj gösterilmelidir.
- Firebase verileri doğru kullanıcıyla ilişkilendirilmelidir.
- Gerçek veri gereken yerlerde rastgele sabit veriler kullanılmamalıdır.

## 10. Genel Kural

**Basitlik önceliklidir.**

Bir işlev daha kolay ve güvenilir bir yöntemle yapılabiliyorsa gereksiz yere karmaşıklaştırılmamalıdır. Projenin temel işlevleri çalışır durumda olmalı, mevcut kod düzeni korunmalı ve teslim süresi dikkate alınmalıdır.

