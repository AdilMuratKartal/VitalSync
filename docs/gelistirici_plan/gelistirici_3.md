

# Geliştirici 3 — Firebase & Backend Integration Lead

## 1. Görev

Uygulamanın Firebase bağlantılarını ve temel veri işlemlerini hazırlamak.

## 2. Sorumluluklar

### Firebase Authentication

- Firebase bağlantısının yapılması
- Kullanıcı kayıt işlemi
- Kullanıcı giriş işlemi
- Şifre sıfırlama
- Çıkış yapma
- Kullanıcı rolünün Firestore üzerinden okunması

### Cloud Firestore

- Firestore bağlantısının hazırlanması
- Temel veri okuma ve yazma servislerinin oluşturulması
- Randevu, kullanıcı, sağlık verisi ve reçete işlemleri için gerekli servislerin hazırlanması
- İhtiyaç duyulan yerlerde canlı veri akışının sağlanması

### Firebase Storage

- Gerekli dosya ve görsellerin yüklenmesi
- Dosya bağlantılarının ilgili Firestore kayıtlarında saklanması

## 3. Diğer Geliştiricilerle Bağımlılık

- Geliştirici 4 ile Firestore veri alanları ve koleksiyon yapısı konusunda birlikte çalışır.
- Geliştirici 5, hazırlanan servisleri Cubit içerisinde kullanır.
- Geliştirici 6, ekranlarda Firebase işlemlerini doğrudan yazmak yerine hazırlanan servisleri kullanır.
- Geliştirici 1'in oluşturduğu proje altyapısına Firebase bağlantısını entegre eder.

## 4. Çalışma Kuralları

- Firebase işlemlerini ekran dosyalarına yazma.
- Servisleri basit ve tekrar kullanılabilir hazırla.
- Gereksiz Cloud Functions veya ek backend altyapısı oluşturma.
- Firebase bağlantı ve yapılandırma bilgilerini ekip ile paylaş.
- Gerçek kullanıcı verilerinin birbirine karışmasını önle.

**Öncelik:** Önce Auth ve temel Firestore işlemleri çalışır hale getirilmelidir. Storage ve diğer ek işlemler daha sonra tamamlanabilir.

Proje geliştirilirken kısa, anlamlı ve sade Türkçe yorum satırları eklenebilir.

---

## 5. Uygulama & Entegrasyon Planı

### A. Firebase Console'da Manuel Yapılması Gerekenler (Geliştirici / Ekip Tarafından)

1. **Firebase Projesi Oluşturma:**
   - [Firebase Console](https://console.firebase.google.com/) üzerinden `vitalsync-dentora` adıyla yeni bir proje oluşturun.
2. **FlutterFire CLI ile Uygulamaları Bağlama:**
   - Terminalde `dart pub global activate flutterfire_cli` ve ardından proje kök dizininde `flutterfire configure` komutunu çalıştırarak **Android, iOS, Web ve macOS** platformlarını seçin (`lib/firebase_options.dart` otomatik oluşacaktır).
3. **Authentication (Kimlik Doğrulama) Ayarları:**
   - Firebase Console → **Build → Authentication → Get Started** adımına gidin.
   - **Sign-in method** sekmesinden **Email/Password** sağlayıcısını aktif (`Enable`) hale getirin.
4. **Cloud Firestore Veritabanı Oluşturma:**
   - Firebase Console → **Build → Firestore Database → Create database** adımına tıklayın.
   - Konum olarak `eur3 (europe-west)` seçin ve başlangıç için **Test Mode** (veya giriş yapmış kullanıcılara izin veren kurallar) ile başlatın.
5. **Firebase Storage (Dosya/Röntgen Yükleme) — Spark Planı Notu:**
   - Firebase Storage ilk kurulumda Blaze (ücretli/kart tanımlı) plan istediğinden, proje **ücretsiz Spark planında** tutulmuş ve Console üzerinden Storage etkinleştirilmemiştir. Kod tarafındaki `StorageService`, Storage kapalıyken uygulamanın çökmesini önlemek için güvenli yerel/örnek URL fallback'i ile çalışacak şekilde hazırlanmıştır.

### B. Kod Tarafında Yapılacaklar (Asistan / Geliştirici 3 Kod Görevleri)

1. **Paket Kurulumu ve Başlatma (`pubspec.yaml` & `main.dart`):**
   - `firebase_core`, `firebase_auth`, `cloud_firestore` ve `firebase_storage` paketlerinin eklenmesi ve `main.dart` içinde `Firebase.initializeApp()` ile başlatılması.
2. **Kimlik Doğrulama Servisi (`lib/data/services/auth_service.dart`):**
   - Giriş yapma (`signIn`), kayıt olma (`signUp`), şifre sıfırlama (`sendPasswordResetEmail`), çıkış yapma (`signOut`) ve giriş yapan kullanıcının rolünü (`patient` / `doctor`) Firestore `users` koleksiyonundan okuma işlemlerinin yazılması.
3. **Veritabanı Servisi (`lib/data/services/firestore_service.dart`):**
   - `users`, `appointments`, `tooth_records`, `treatments`, `payments` ve `prescriptions` koleksiyonları için CRUD (ekleme, okuma, güncelleme, silme) ve gerçek zamanlı `Stream` (canlı veri akışı) metotlarının hazırlanması.
4. **Dosya Yükleme Servisi (`lib/data/services/storage_service.dart`):**
   - Hasta röntgen/belge görsellerini yükleyen (Spark planında Firebase Storage kapalıysa güvenli örnek/yerel `downloadUrl` fallback'i döndüren) ve bağlantıyı Firestore'a kaydeden servisin hazırlanması.
5. **ServiceLocator Kaydı (`lib/core/di/service_locator.dart`):**
   - Hazırlanan `AuthService`, `FirestoreService` ve `StorageService` sınıflarının `ServiceLocator` içine kaydedilerek Geliştirici 5 ve 6'nın kullanımına sunulması.

