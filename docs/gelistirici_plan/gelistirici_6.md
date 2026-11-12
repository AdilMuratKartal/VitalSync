

# Geliştirici 6 — Feature Screens & QA / Test Lead

## 1. Görev

Uygulama ekranlarının geliştirilmesine destek olmak, formların doğru çalışmasını sağlamak ve temel test süreçlerini yürütmek.


## 2. Sorumluluklar

### Ekran Geliştirme

- Kendisine atanan feature ekranlarını geliştirmek
- Ekranları ortak tema ve widget yapısına uygun hazırlamak
- Ekranları ilgili Cubit yapılarına bağlamak
- Kullanıcı işlemlerinin doğru çalışmasını sağlamak
- Ekranlar arasında gerekli yönlendirmeleri yapmak

### Form Validasyonu

Formlarda temel kontrolleri uygulamak:

- Boş alan kontrolü
- E-posta formatı kontrolü
- Şifre kontrolü
- Gerekli alanların doğru girilmesi
- Hatalı girişlerde kullanıcıya açıklayıcı mesaj gösterilmesi

> **Not:** Giriş (`/login`) ve Kayıt Ol (`/register`) ekranlarında kullanıcı yazdıkça altta dinamik olarak açılan ve kurallar sağlandıkça tik (`✓`) olan UI düzeyindeki form/şifre validasyonları tamamlanmıştır.

### Dört Durum Kontrolü

Veri kullanan ekranlarda ihtiyaç duyulduğunda:

- Loading
- Error
- Empty
- Success

durumlarının doğru görüntülenmesini kontrol etmek.

### Test ve Son Kontrol

- Temel Unit Test örneklerini hazırlamak
- Önemli ekranlar için Widget Test yazmak
- Form validasyonlarını kontrol etmek
- Ekranların açılıp açılmadığını kontrol etmek
- Ekran taşmalarını ve belirgin UI hatalarını kontrol etmek
- Hasta ve doktor akışlarının birlikte çalıştığını test etmek

## 3. Diğer Geliştiricilerle Bağımlılık

- Geliştirici 1'in hazırladığı Router ve Core yapısını kullanır.
- Geliştirici 2'nin hazırladığı ortak widget ve tasarımları kullanır.
- Geliştirici 3'ün Firebase servislerini kullanır.
- Geliştirici 4'ün modellerine uygun veri gösterir.
- Geliştirici 5'in hazırladığı Cubit ve State yapılarını kullanır.

Eksik veya uyumsuz bir yapı varsa ilgili geliştiriciyle iletişime geçmelidir.

## 4. Test Sorumluluğu Paylaşımı

Geliştirici 6 bütün ekranları tek başına test etmek zorunda değildir.

- Her ekranı geliştiren kişi kendi ekranını kontrol eder.
- Geliştirici 6 genel test kontrol listesini hazırlar.
- Kritik kullanıcı akışları birlikte test edilir.
- Bulunan hatalar ilgili ekranın geliştiricisine iletilir.

## 5. Çalışma Kuralları

- Mevcut mimariyi değiştirme.
- Başka geliştiricilerin dosyalarını izinsiz düzenleme.
- Gereksiz test veya validasyon yapıları oluşturma.
- Öncelikle uygulamanın temel akışlarının çalışmasına odaklan.
- Testleri mümkün olduğunca kısa ve anlaşılır tut.

**Öncelik:** Uygulamanın giriş, randevu, doktor ajandası ve reçete gibi temel akışlarının hatasız çalışmasını sağlamak.

Proje geliştirilirken kısa, anlamlı ve sade Türkçe yorum satırları eklenebilir.

