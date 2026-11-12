

# Geliştirici 5 — State Management & Logic Lead

## 1. Görev

Uygulamanın Cubit tabanlı durum yönetimini oluşturmak ve ekranların veri akışını düzenlemek.

Amaç, ekranların Firebase işlemlerini doğrudan yapmasını önlemek ve verilerin kontrollü şekilde güncellenmesini sağlamaktır.

## 2. Sorumluluklar

- `flutter_bloc` paketinin Cubit yapısının hazırlanması
- Feature'lara göre Cubit düzeninin belirlenmesi
- Gerekli State sınıflarının oluşturulması
- Loading, Error, Empty ve Success durumlarının yönetilmesi
- Firebase servisleriyle Cubit arasındaki bağlantının kurulması
- Randevu, sağlık verisi ve reçete gibi temel işlemlerin state akışının hazırlanması
- Firestore'dan gelen değişikliklerin ilgili ekranlara aktarılması

## 3. Kullanılacak Temel Durumlar

Veri kullanan ekranlarda gerektiğinde:

- Initial
- Loading
- Error
- Empty
- Success

durumları kullanılabilir.

Her ekranda gereksiz state sınıfları oluşturulmamalıdır.

## 4. Diğer Geliştiricilerle Bağımlılık

- Geliştirici 1'in hazırladığı klasör yapısına uyar.
- Geliştirici 3'ün hazırladığı Firebase servislerini kullanır.
- Geliştirici 4'ün hazırladığı modeller üzerinden çalışır.
- Geliştirici 6, ekranlarını hazırlanan Cubit ve State yapılarına bağlar.

**Önemli:** Temel state yönetimi düzenini oluşturur ve diğer geliştiricilerin bu düzene uygun çalışmasını sağlar.

## 5. Çalışma Kuralları

- BLoC Event yapısı yerine Cubit kullan.
- Gereksiz Cubit ve State sınıfları oluşturma.
- Firebase kodlarını Cubit içine doğrudan yazmak yerine servisleri kullan.
- Basit UI işlemlerini gereksiz yere Cubit'e taşıma.
- Ekran geliştiricilerine kullanacakları Cubit fonksiyonlarını açıkça bildir.

Proje geliştirilirken kısa, anlamlı ve sade Türkçe yorum satırları eklenebilir.

