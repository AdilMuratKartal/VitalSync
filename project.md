---
proje: egitim
tur: 6sarli_teslim_projesi
grup: "4. Grup"
proje_adi: "VitalSync — Teletıp, Akıllı Sağlık Takibi, Hasta & Klinik Randevu Ekosistemi"
sektor: "MedTech, Akıllı Sağlık & Klinik Yönetim Sistemleri"
teslim_tarihi: 2026-11-13
durum: aktif_gelistirme
uye_sayisi: 6
tags:
  - proje/egitim
  - teslim_projesi
  - buyuk_grup
  - flutter
  - softito
  - firebase
---

# 🚀 SoftITO 4. Dönem Mobil — 4. Grup Büyük Teslim Projesi

> **Grup Adı:** **4. Grup (6 Kişilik Büyük Teslim Proje Takımı)**  
> **Ekip Üyeleri:** Adil Murat Kartal, Emirhan Mahmut Sapmaz, Aygen Yıldırım, Zelal Dartan, Şüheda Mazlum, Murat Özcan  
> **Proje Başlığı:** **VitalSync — Teletıp, Akıllı Sağlık Takibi, Hasta & Klinik Randevu Ekosistemi**  
> **Sektörel Alan:** `MedTech, Akıllı Sağlık & Klinik Yönetim Sistemleri`  
> **Mimari Standart:** Flutter SDK & Clean Architecture + Full Firebase Entegrasyonu  
> **Çift Yönlü Rol Modeli:** Zorunlu (Rol 1: Kullanıcı Portalı vs Rol 2: Yönetici/Sağlayıcı Portalı)  
> **Büyük Teslim & Demo Day:** 13 Kasım 2026 Cuma (Canlı Jüri Sunumu)

---

## 🧭 Hızlı Navigasyon & Bağlantılar
- 📋 **Büyük Teslim Grupları Komuta Paneli:** [[02_PROJELER/egitim/ogrenci_projeleri/6sarli_teslim_projeleri/README|🚀 4 Büyük Teslim Grubu Komuta Merkezi]]
- 👥 **Öğrenci Takip Paneli:** [[02_PROJELER/egitim/ogrenciler|👥 SoftITO Öğrenci Listesi]]
- 🎓 **22 Bireysel Bitirme Projeleri:** [[02_PROJELER/egitim/ogrenci_projeleri/bireysel_bitirme_projeleri/README|🎓 Bireysel Bitirme Projeleri]]
- ⚡ **Eğitim Master Context:** [[02_PROJELER/egitim/egitim|⚡ Eğitim Master Context]]

---

## 🎯 1. Proje Açıklaması & Kapsamı

### 🌟 Projenin Amacı ve Vizyonu
Hastalar ile uzman hekimleri ve klinikleri buluşturan; poliklinik randevusu alma, sağlık sensörlerinden (tansiyon, şeker, nabız, EKG) gelen verileri grafiklerle takip etme, doktora online konsültasyon danışma ve dijital reçete yönetimini tek çatı altında toplayan çift yönlü MedTech platformu.

Bu proje; 6 kişilik bir yazılım mühendisliği ekibinin 1 hafta boyunca tam zamanlı çalışarak uçtan uca, store kalitesinde, kurumsal mimariyle ve çift taraflı rol yönetimiyle geliştireceği büyük ölçekli bir bitirme ürünüdür.

---

### 🎭 Çift Yönlü Rol Modeli (Role-Based Dual Mode)

Uygulama iki farklı kullanıcı tipine hizmet verecek şekilde tasarlanacaktır. Giriş yapan kullanıcının rolüne göre arayüz, yetkiler ve dashboard dinamik olarak değişecektir:

#### 👤 1. Modül: Hasta / Danışan Portalı (Bireysel Sağlık Asistanı)
- **Branş & Doktor Arama / Filtreleme:** Uzmanlık (Kardiyoloji, Nöroloji, Dahiliye, Çocuk Sağlığı), hastane/klinik, doktor unvanı, hasta puanı ve muayene ücretine göre dinamik filtreler.
- **Akıllı Randevu Takvimi:** Doktorun haftalık takviminden uygun gün ve 15'er dakikalık boş saat slotunu seçip tek dokunuşla randevu onaylama.
- **Vital Verilerim & IoT Sağlık Günlüğü:** Günlük Tansiyon (Büyük/Küçük), Açlık Şekeri, Nabız (BPM) ve Oksijen (SpO2) değerleri girişi, tarihsel çizgi grafikleri ve kritik sınır alarmları.
- **E-Reçete & İlaç Hatırlatıcı Takvimi:** Doktorun yazdığı aktif ilaçlar, günlük kullanım sıklığı (Sabah 1 Tok, Akşam 1 Aç) ve telefonun bildirim saatiyle senkronize ilaç içme sayacı.
- **Tahlil & Radyoloji Sonuçları Arşivi:** Kan tahlili, MR, röntgen PDF/görsellerinin saklandığı kişisel sağlık dosyası.
- **Doktorla Canlı Danışma / Mesajlaşma:** Randevu öncesi veya tahlil sonrası doktora soru sorma ve dosya iletme alanı.

#### 🏢 2. Modül: Hekim & Klinik Yönetici Portalı (Klinik Komuta Masası)
- **Günlük Muayene Ajandası & Hasta Sırası:** O günün saat saat randevu kuyruğu, gelen hastayı 'Muayenede', 'Tamamlandı' veya 'Gelmedi' olarak işaretleme.
- **Hasta Anamnez & Tıbbi Geçmiş Kartı:** Hastanın geçmiş hastalıkları, alerjileri, daha önce geçirdiği operasyonlar ve tahlil arşivi.
- **Canlı Kritik Vital Alarm Paneli:** Takip edilen kronik hastaların girdiği tansiyon/şeker değerlerinde tehlikeli bir fırlama (Örn: Nabız > 130 veya Şeker > 250) olduğunda doktorun paneline anlık kırmızı acil bildirim düşmesi.
- **E-Reçete & Tanı (ICD-10) Yazma Masası:** Hastaya tanı koyma, ilaç seçimi, kullanım dozu ve periyodu belirleyip hastanın sistemine tek tıkla reçete gönderme formu.
- **Klinik Çalışma Saatleri & Slot Yönetimi:** Doktorun izinli günlerini, muayene aralıklarını ve randevu ücretlerini belirlediği takvim yönetim aracı.

---

### ⚙️ Temel İş Kuralları & Kritik Mantık Akışları (Business Rules)
6 kişilik ekibin 1 hafta boyunca kodlayacağı kritik iş mantıkları şunlardır:

1. **Çift Rezervasyon (Overbooking) Kalkanı:** Bir hekimin belirli bir saat slotu (örneğin 14:15 - 14:30) bir hasta tarafından rezerve edildiği anda, eşzamanlı diğer tüm hasta ekranlarında o slot reaktif olarak 'KAPALI / DOLU' durumuna geçmelidir.
2. **Kritik Sağlık Değer Eşik Sistemi:** Hasta tansiyon veya şeker girdiğinde, sistem anlık eşik kontrolü yapar (Sistolik > 140 veya Diastolik > 90 ise 'Hipertansiyon Uyarısı' verir ve doktora Firestore event'i tetikler).
3. **Tıbbi Mahremiyet & İzin Kuralı:** Bir doktor, yalnızca kendisinden aktif veya geçmiş randevusu bulunan hastaların anamnez ve tahlil sonuçlarını görüntüleyebilir.
4. **Otomatik Randevu Hatırlatıcı (FCM):** Randevu saatine 2 saat kala hastaya otomatik yerel bildirim fırlatılır.
5. **Reçete Bütünlüğü:** Hekim reçeteyi onaylayıp imzaladıktan sonra üzerinde değişiklik yapılamaz (Immutability).

---

## 🛠️ 2. İstediğim Teknolojiler & Mimari Standartlar

Projede derste kapsamlı olarak işlediğimiz kurumsal mobil geliştirme teknolojileri ve standartları eksiksiz kullanılacaktır:

- **Mobil Framework & Dil:** Flutter SDK (En güncel kararlı sürüm) & Dart (Strict Type Safety, Null Safety)
- **Mimari Disiplin:** Kurumsal Clean Architecture (`core`, `data`, `domain`, `presentation`) & Katmanlı Klasör Düzeni
- **Kimlik Doğrulama (Auth):** Firebase Authentication (Email/Şifre, opsiyonel Google Sign-In, Rol tabanlı Custom Claims / Profil eşleme)
- **Veritabanı & Canlı Veri:** Cloud Firestore (NoSQL, Realtime Streams, Subcollections, Composite Queries, Atomik Transactions & Batch Writes)
- **Medya & Belge Saklama:** Firebase Storage (Profil fotoğrafları, makbuz/fiş/rapor/ödev dosyaları, ImagePicker, Yükleme Stream'i & İlerleme Barı)
- **Push Bildirimleri & Uyarılar:** Firebase Cloud Messaging (FCM) & `flutter_local_notifications` (Ön plan, arka plan, topic tabanlı toplu duyurular)
- **Hata Takibi & Analitik:** Firebase Crashlytics & Firebase Analytics (Kritik kullanıcı aksiyonları, özel event logları)
- **State Management:** BLoC / Cubit veya Provider / Riverpod (Tek bir kurumsal standart seçilmeli, spagetti setState yasaktır)
- **Navigasyon Mimarisi:** GoRouter (ShellRoute ile kalıcı BottomNavigationBar, Deep Linking, Rol bazlı Route Guards / Yönlendirme Kalkanı)
- **Yerel Depolama (Offline Cache):** SharedPreferences veya Hive / SQLite (Oturum token'ı, çevrimdışı taslaklar, tema tercihleri)
- **Tasarım Sistemi & UI/UX:** Material 3 (ColorScheme.fromSeed, Açık ve Koyu Tema, Akıcı Mikro Animasyonlar, Hero, CustomPainter grafikler)
- **Form & Validasyon Güvencesi:** `Form` & `GlobalKey<FormState>`, Regex validatörleri, InputFormatters, TextEditingController yaşam döngüsü (`dispose`)
- **Kalite & Güvenilirlik:** Sıfır `RenderFlex overflow` (sarı-siyah taşma) kuralı, asenkron `mounted` kontrolleri, Unit & Widget testleri
- **Versiyon Kontrol & Git-Flow:** `main` (Stabil), `develop` (Entegrasyon) ve `feat/<isim>-<modul>` feature branch'leri, PR (Pull Request) onay mekanizması

---

## 📋 3. Ekip Tarafından Tamamlanacak Çalışma Alanı

> [!NOTE]
> Bu bölüm projenin teknik şartnamesi doğrultusunda **6 kişilik öğrenci ekibi tarafından** doldurulacak, mimari kararlar, ekran tasarımları, DTO modelleri ve GitHub repo ilerlemeleri burada belgelenecektir.

### 👥 3.1. Takım İçi 6 Kişilik Görev Dağılımı ve Sorumluluk Matrisi
*(Ekip üyeleri mimari katmanlara ve ekranlara göre görev dağılımını buraya işleyecektir)*

- [ ] **Geliştirici 1 (Team Lead & Core Architecture):** Core katmanı, Base sınıflar, Git branch kuralları, Theme & Dependency Injection.
- [ ] **Geliştirici 2 (UI / UX & Design System Lead):** Material 3 teması, Renk paleti, Custom Widgets, Splash Screen, App Icon.
- [ ] **Geliştirici 3 (Network, API & Firebase Lead):** Firebase Auth, Firestore servisleri, Storage bağlantısı, FCM altyapısı.
- [ ] **Geliştirici 4 (Data Models & DTO Lead):** Entity ve DTO modelleri (`fromJson`, `toJson`, `copyWith`), Firestore veri şeması.
- [ ] **Geliştirici 5 (State Management & Logic Lead):** BLoC / Cubit / Riverpod akışları, Event/State sınıfları, Reaktif dinleyiciler.
- [ ] **Geliştirici 6 (Feature Screens & QA / Test Lead):** Form validasyonları, 4 durum yönetimi (Loading, Error, Empty, Success), Unit/Widget testleri.

### 📱 3.2. Ekran Listesi ve Kullanıcı Akış Şeması
*(Ekip geliştireceği en az 8-10 kurumsal ekranın listesini ve akış haritasını buraya çıkaracaktır)*

### 🗄️ 3.3. Cloud Firestore Veri Şeması (Koleksiyon & Döküman Tasarımı)
*(Koleksiyonlar, alt koleksiyonlar ve belge alanları burada şematize edilecektir)*

### 🔗 3.4. GitHub Repository & Sprint Takip Bilgileri
- **GitHub Repo Linki:** *[Repo URL buraya eklenecek]*
- **Sprint 1 (09 - 10 Kasım):** Mimari kurulum, modeller, auth ve temel ekran iskeletleri.
- **Sprint 2 (11 - 12 Kasım):** Çift yönlü rollerin canlı bağlanması, Storage, FCM, 4 durum kalkanı ve testler.
- **Demo Day (13 Kasım):** Canlı emülatör/cihaz sunumu ve jüri değerlendirmesi.

---
*Belge Oluşturuldu: 2026-11-09 — Antigravity E-Mektep & SoftITO Mobil Büyük Teslim Projeleri Sistemi*
