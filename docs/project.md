
# VitalSync — Project Overview

## 1. Proje Tanımı

**VitalSync**, hastalar ile diş hekimlerini bir araya getiren, randevu yönetimi ve temel sağlık takibi sağlayan mobil uygulamadır.

Uygulama iki farklı kullanıcı rolüne sahiptir:

- **Hasta:** Randevu alır, randevularını takip eder, sağlık verilerini görüntüler, reçete ve sonuçlarına ulaşır, doktoruyla iletişim kurar.
- **Doktor:** Günlük randevularını yönetir, hasta geçmişini inceler, reçete oluşturur, çalışma saatlerini ve hizmet ücretlerini düzenler, mesajları görüntüler.

Uygulamanın arayüz tasarımlarında Dentora diş kliniği konsepti kullanılmaktadır.

## 2. Projenin Amacı

Kısa geliştirme süresi içerisinde iki farklı kullanıcı rolüyle çalışabilen, Firebase bağlantısı bulunan, ekranları birbiriyle ilişkili ve temel işlevleri çalışan bir Flutter uygulaması ortaya çıkarmak.

**Önceliğimiz:** Karmaşık ve tamamlanması zor özellikler yerine, çalışan ve sunumda gösterilebilen bir uygulama geliştirmektir.

## 3. Kullanılacak Temel Teknolojiler

- Flutter ve Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage (dosya veya görsel yükleme gereken yerlerde)
- Flutter BLoC / Cubit
- GoRouter
- Material 3

Teknik kullanım kuralları `skills.md` dosyasında açıklanmıştır.

## 4. Kullanıcı Rolleri

### Hasta Portalı

Hasta aşağıdaki işlemleri gerçekleştirebilir:

- Hesap oluşturma ve giriş yapma
- Ana sayfada yaklaşan randevusunu görüntüleme
- Doktor ve hizmet seçerek randevu oluşturma
- Randevularını görüntüleme, iptal etme
- Sağlık değerlerini kaydetme ve geçmiş değerlerini inceleme
- Reçete ve tahlil sonuçlarını görüntüleme
- Doktoruyla mesajlaşma
- Profil ve bildirim tercihlerini düzenleme

### Doktor Portalı

Doktor aşağıdaki işlemleri gerçekleştirebilir:

- Giriş yapma
- Günlük randevuları görüntüleme ve durumlarını değiştirme
- Hasta bilgilerini ve geçmiş kayıtlarını inceleme
- Reçete oluşturma
- Çalışma saatlerini ve hizmet ücretlerini düzenleme
- Hasta mesajlarını görüntüleme ve yanıt verme

## 5. Uygulama Ekranları

### Başlangıç ve Kimlik Doğrulama

1. Splash Screen
2. Login Screen
3. Register Screen
4. Forgot Password Screen

### Hasta Portalı

5. Patient Home Screen
6. Book Appointment Screen
7. Book Appointment Calendar Screen
8. My Appointments Screen
9. My Results Screen
10. My Vitals Screen
11. Patient Chat Screen
12. Profile Settings Screen

### Doktor Portalı

13. Doctor Agenda Screen
14. Create Prescription Screen
15. Past Patients Screen
16. Schedule Pricing Screen
17. Doctor Messages Screen

## 6. Temel İş Kuralları

- Kullanıcı giriş yaptığında rolüne göre doğru portala yönlendirilmelidir.
- Hasta yalnızca kendi randevularını, sağlık verilerini ve reçetelerini görmelidir.
- Doktor yalnızca kendi kliniğiyle ilişkili hasta ve randevu kayıtlarını görmelidir.
- Dolu bir randevu saati başka bir hasta tarafından tekrar alınamamalıdır.
- Hasta yeni sağlık değeri girdiğinde değerler kaydedilmeli ve ekranda güncellenmelidir.
- Kritik sağlık değerlerinde kullanıcıya uyarı gösterilmelidir.
- Doktorun oluşturduğu reçete hastanın sonuçlar ekranında görüntülenmelidir.
- Onaylanmış reçete sonradan değiştirilmemelidir.
- Doktorun çalışma saatleri ve hizmet ücretleri hasta tarafındaki ilgili ekranlara yansımalıdır.

## 7. Geliştirme Süresini Kısaltma Kararları

Projenin teslim süresi kısıtlıdır. Bu nedenle aşağıdaki sadeleştirmeler uygulanmalıdır:

- Gerçek sağlık cihazı veya IoT bağlantısı kurulmayacaktır. Sağlık değerleri kullanıcı tarafından girilecektir.
- TC kimlik doğrulaması gibi ek kimlik sistemleri geliştirilmeyecektir. Basit e-posta ve şifre girişi yeterlidir.
- Kullanıcı rolü Firestore üzerindeki kullanıcı kaydından okunacaktır.
- Gereksiz gelişmiş güvenlik, özel sunucu veya Cloud Functions altyapısı oluşturulmayacaktır.
- Randevu çakışması kontrolü mümkün olduğunca basit tutulacak; kayıt öncesinde mevcut slot kontrol edilecektir. Desteklenebiliyorsa Firestore Transaction kullanılacaktır.
- Bildirimler için öncelikle uygulama içi bildirim veya yerel bildirim tercih edilecektir. Tam otomatik sunucu zamanlaması zorunlu değildir.
- Mesajlaşma temel metin mesajlarıyla sınırlandırılabilir. Görsel gönderimi zaman kalırsa eklenir.
- PDF oluşturma, SMS gönderimi, gerçek e-reçete entegrasyonu ve harici sağlık sistemi bağlantıları zorunlu değildir.
- Tasarımdaki her detayın birebir uygulanması yerine ekranın temel görünümü ve işlevi korunmalıdır.
- Aynı işlemi yapan iki ekran varsa ortak mantık ve bileşenler kullanılmalıdır.

## 8. Geliştirme Önceliği

Öncelik sırası:

1. Uygulamanın açılması ve rol bazlı giriş
2. Hasta ve doktor ana ekranları
3. Randevu oluşturma ve randevu yönetimi
4. Doktor ajandası ve reçete oluşturma
5. Sağlık verileri ve profil
6. Mesajlaşma, sonuçlar ve diğer yardımcı özellikler
7. Testler ve son düzenlemeler

**Temel kural:** Çalışan bir özellik, tamamlanmamış karmaşık bir özellikten daha değerlidir.

