

# VitalSync — Architecture & Project Structure

## 1. Mimari Yaklaşım

Projede Clean Architecture yaklaşımı kullanılacaktır. Ancak geliştirme süresi kısa olduğu için mimari mümkün olduğunca sade tutulmalıdır.

Amaç kodları birbirinden ayırmak, anlaşılır bir klasör düzeni oluşturmak ve geliştiricilerin aynı dosyalarda çakışmasını önlemektir.

Gereksiz katman, sınıf veya soyutlama oluşturulmayacaktır.

## 2. Klasör Yapısı

Önerilen temel yapı:

```text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── router/
│   ├── utils/
│   └── widgets/
│
├── data/
│   ├── models/
│   └── services/
│
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   └── data/
│   │
│   ├── patient/
│   │   ├── home/
│   │   ├── appointments/
│   │   ├── results/
│   │   ├── vitals/
│   │   ├── chat/
│   │   └── profile/
│   │
│   └── doctor/
│       ├── agenda/
│       ├── prescriptions/
│       ├── patients/
│       ├── schedule/
│       └── messages/
│
└── main.dart
```

Her feature klasöründe ihtiyaç duyuluyorsa `presentation`, `data` ve `domain` klasörleri oluşturulabilir.

Küçük ve basit özellikler için kullanılmayan klasörler sırf mimariyi tamamlamak amacıyla oluşturulmamalıdır.

## 3. Katmanların Sorumlulukları

### Core

Uygulamanın ortak parçalarını içerir:

- Tema ve renkler
- Router ve yönlendirme
- Sabit değerler
- Ortak yardımcı fonksiyonlar
- Tekrar kullanılabilir widget'lar

### Data

Veri işlemlerinden sorumludur:

- Firebase bağlantıları
- Firestore okuma ve yazma işlemleri
- Modeller ve veri dönüştürme işlemleri
- Gerekli servisler

### Domain

İş kurallarını içerir.

Yalnızca gerçekten ihtiyaç duyulan özelliklerde kullanılmalıdır. Küçük işlemler için gereksiz UseCase sınıfları oluşturulmamalıdır.

### Presentation

Kullanıcının gördüğü ekranları ve ekranların durum yönetimini içerir:

- Screens
- Widgets
- Cubit
- States

## 4. Bağımlılık ve Veri Akışı

Genel veri akışı şu şekilde olmalıdır:

```text
Screen
  ↓
Cubit
  ↓
Repository / Service
  ↓
Firebase veya Firestore
```

Ekranlar doğrudan Firestore işlemleri yapmamalıdır.

Cubit, ekrandaki işlemleri yönetir. Repository veya Service ise veriyi getirir ve kaydeder.

Küçük özelliklerde gereksiz Repository ve UseCase katmanları oluşturulması zorunlu değildir. Ancak Firebase kodları ekranların içine yazılmamalıdır.

## 5. Geliştiriciler Arası Bağımlılıklar

- Geliştirici 1 temel klasör yapısını, tema altyapısını ve yönlendirmeyi hazırlar.
- Geliştirici 2 ortak tasarım bileşenlerini ve tema görünümünü oluşturur.
- Geliştirici 3 Firebase bağlantısını ve temel servisleri hazırlar.
- Geliştirici 4 veri modellerini ve Firestore alanlarını belirler.
- Geliştirici 5 Cubit ve state yönetimi düzenini oluşturur.
- Geliştirici 6 ekranların uygulanması, validasyon ve test süreçlerine destek verir.

Bir geliştirici başka bir geliştiricinin hazırladığı yapıyı kullanmadan önce ilgili dosyaları incelemelidir.

Gerekli bir değişiklik başka bir geliştiricinin sorumluluğundaki dosyayı etkiliyorsa doğrudan değiştirmek yerine ekip ile iletişim kurulmalıdır.

## 6. Kod Düzeni

- Her ekran ayrı bir dosyada bulunmalıdır.
- Çok büyüyen ekranlar küçük widget'lara ayrılmalıdır.
- Aynı kod farklı ekranlarda tekrar tekrar yazılmamalıdır.
- Ortak widget'lar `core/widgets` altında tutulmalıdır.
- Dosya ve sınıf isimleri anlaşılır olmalıdır.
- Mevcut klasör düzeni gerekmedikçe değiştirilmemelidir.
- Her geliştirici kendi sorumluluk alanındaki dosyalarda çalışmalıdır.

## 7. Antigravity Çalışma Kuralları

Antigravity:

- Önce mevcut proje yapısını incelemelidir.
- Var olan kodu anlamadan yeni mimari oluşturmamalıdır.
- Mevcut dosyaları gereksiz yere silmemeli veya yeniden yazmamalıdır.
- Başka geliştiricilerin çalışmalarını bozmamalıdır.
- Gereksiz paket veya katman eklememelidir.
- Değişiklik yaptığı dosyaları ve önemli kararları açıklamalıdır.
- Çalışan mevcut özellikleri korumalıdır.

