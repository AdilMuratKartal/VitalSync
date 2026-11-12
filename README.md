# VitalSync (Dentora) — Diş Kliniği Randevu ve Hasta Takip Sistemi

VitalSync (Dentora), diş hekimleri ile hastalar arasındaki randevu, tedavi planlaması, interaktif diş şeması (odontogram), ödeme ve klinik süreçlerini dijitalleştiren **Flutter** tabanlı mobil/web sağlık uygulamasıdır.

---

## 🏗️ Mimari Yapı (Clean Architecture — 3 Katmanlı)

Proje **Geliştirici 1 (Team Lead & Core Architecture)** tarafından kurulan 3 katmanlı mimari (`core/`, `data/`, `presentation/`) üzerinde çalışmaktadır:

```text
lib/
├── main.dart                     # Uygulama giriş noktası (DI + ThemeMode + GoRouter)
├── core/                         # [Geliştirici 1] Ortak Çekirdek Katmanı
│   ├── constants/
│   │   └── app_constants.dart    # Uygulama sabitleri, Firestore koleksiyon adları, demo hesaplar
│   ├── di/
│   │   └── service_locator.dart  # Basit Dependency Injection (ServiceLocator) kayıt merkezi
│   ├── router/
│   │   └── app_router.dart       # GoRouter merkezi rota yönetimi (/splash, /welcome, /login, /patient/*, /doctor/*)
│   ├── theme/
│   │   ├── app_colors.dart       # The Ethereal Clinic renk paleti
│   │   └── app_theme.dart        # Light & Dark ThemeData (Plus Jakarta Sans & Inter)
│   ├── utils/
│   │   └── validators.dart       # TC Kimlik, E-posta, Telefon ve Canlı Şifre Kriter Validatörleri
│   └── widgets/
│       └── common_widgets.dart   # Ortak paylaşılan bileşen ihracı (DentoraLogo, AppBar vb.)
├── data/                         # [Geliştirici 3 & 4] Veri Katmanı
│   ├── models/
│   │   └── models.dart           # Veri modelleri giriş noktası
│   └── services/
│       └── services.dart         # Firebase / Repository servisleri giriş noktası
└── presentation/                 # [Geliştirici 1, 2, 5, 6] Sunum Katmanı (UI)
    ├── screens/
    │   ├── splash/               # Animasyonlu Splash Ekranı (/splash)
    │   ├── welcome/              # Sağa Kaydırmalı (Slide-to-Start) Karşılama Ekranı (/welcome)
    │   ├── auth/                 # Giriş (/login - Hızlı Demo destekli), Kayıt (/register), Şifre Sıfırlama
    │   ├── patient/              # Hasta Paneli (Ana Sayfa, Randevu Al, Diş Şeması, Belgeler, Ödemeler, Profil)
    │   └── doctor/               # Doktor Paneli (Dashboard, Ajanda, Hasta Detay, Fiyat & Mesai, Analitik, Profil)
    └── widgets/                  # Özel UI bileşenleri ve Shell navigasyon barları
```

---

## 🌿 Git-Flow & Branch Kuralları (Geliştirici 1)

6 kişilik geliştirici ekibinin çakışma (merge conflict) yaşamaması için aşağıdaki dal (branch) kuralları uygulanır:

- `main`: Sadece test edilmiş, kararlı (production-ready) sürümlerin bulunduğu ana dal. Doğrudan commit atılmaz.
- `develop`: Tüm ekip üyelerinin özellik dallarının (feature branch) birleştirildiği entegrasyon dalı.
- `feat/<isim>-<modul>`: Her geliştirici kendi görevini bu isimlendirme ile açtığı dalda geliştirir (Örn: `feat/dev1-core`, `feat/dev2-auth`, `feat/dev3-models`, `feat/dev4-services`, `feat/dev5-patient`, `feat/dev6-doctor`).

---

## 🚀 Çalıştırma Komutları

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
