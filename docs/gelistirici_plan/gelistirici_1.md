

# Geliştirici 1 — Team Lead & Core Architecture

## 1. Görev

Projenin temel altyapısını kurmak ve tüm geliştiricilerin aynı proje düzeninde çalışmasını sağlamak.

Bu geliştirici, diğer özelliklerin üzerine kurulacağı temel yapıyı hazırlar.

## 2. Sorumluluklar

- `core/` klasörünün oluşturulması
- Temel proje klasör yapısının hazırlanması
- Ortak tema altyapısının kurulması
- Açık ve koyu tema tanımlarının hazırlanması
- GoRouter temel yapılandırmasının yapılması
- Hasta ve doktor ana sayfaları için temel yönlendirme düzeninin kurulması
- Gerekliyse basit Dependency Injection yapısının hazırlanması

## 3. Diğer Geliştiricilerle Bağımlılık

- Geliştirici 2, tema altyapısını ve ortak proje düzenini kullanır.
- Geliştirici 3, Firebase bağlantısını ana projeye entegre eder.
- Geliştirici 5, Cubit yapılarını mevcut klasör düzenine göre oluşturur.
- Geliştirici 6, ekranlarını mevcut Router ve Core yapısına göre geliştirir.

**Öncelik:** Diğer geliştiriciler çalışmaya başlamadan önce temel klasör yapısı, tema ve yönlendirme altyapısı hazır olmalıdır.

## 4. Çalışma Kuralları

- Gereksiz mimari karmaşa oluşturma.
- Diğer geliştiricilerin feature klasörlerine müdahale etme.
- Projenin genel düzenini koru.
- Yapılan değişikliklerin diğer geliştiricilerin kodlarıyla uyumlu olmasını sağla.

Proje geliştirilirken kısa, anlamlı ve sade Türkçe yorum satırları eklenebilir.

