# VitalSync Doktor Modülü Geliştirme ve İyileştirme Planı (Dev 1)

Bu doküman, kullanıcı tarafından sağlanan ekran tasarımları, hata notları ve geri bildirimler doğrultusunda VitalSync Doktor Modülü üzerinde gerçekleştirilecek geliştirmeleri, mimari kararları ve ekran bazlı yapılacak çalışmaları içermektedir.

---

## 📌 Kullanıcı Özel İstekleri ve Düzeltmeleri
1. **Mesajlaşma Ekranı:** Görüntü (fotoğraf/röntgen) yükleme/ekleme kısmı **olmayacak**. Doğrudan sade metin mesajlaşması ve hazır hekim şablonları yer alacak.
2. **Reçete Ekranı:** SMS gönderme, Medula kutusu veya e-imza gibi harici süreçler **olmayacak**. Butonda sadece **"Reçete Oluştur"** yazacak ve oluşturulan bu reçete hastanın reçetelerim ekranında (`my_results_screen.dart` / reçete listesinde) görüntülenebilir şekilde hasta verisine eklenecek.

---

## 🏥 1. Ekran: Doktor Ajandası (`DoctorAgendaScreen`)
### Mevcut Sorunlar
- **Üst Bar:** Zil ikonuna tıklandığında yalnızca basit bir SnackBar mesajı gösteriliyor. Profil ikonundaki menüde hekimin kendi profili ve çalışma ayarları eksik.
- **Tarih Seçici & Bugün Butonu:** Tarih alanı (`18 Mart 2026, Çarşamba`) ve `Bugün` butonu ile sol/sağ oklar statik; dokunulduğunda tarih değişmiyor ve takvim açılmıyor.
- **Filtre Çipleri:** `Tüm Randevular`, `Aktif / Koltukta`, `Bekleyenler`, `Tamamlananlar` filtreleri statik liste üzerinde çalışmıyor ve sayaçlarla senkronize değil.
- **Detay Görüntüle:** Kartlardaki "Detay Görüntüle" aksiyonu eksik; tıklandığında hastanın klinik detayları açılmıyor.
- **Sayaç Kartları:** Toplam, Tamamlandı, Koltukta, Bekleyen sayıları güncel filtre/veri durumuna göre dinamik hesaplanmıyor.

### Yapılacak Geliştirmeler
1. **Üst Bar (Profil & Bildirim):**
   - Bildirim ikonuna tıklandığında hekime ait klinik bildirimleri (yeni randevu, acil vaka, laboratuvar sonucu hazır bildirimi) listeleyen `DoctorNotificationsSheet` modalı açılacak.
   - Profil ikonuna tıklandığında açılan menüye **"Doktor Profili"** ve **"Klinik Çalışma Ayarları"** seçenekleri eklenecek; tıklandığında hekim bilgilerini ve çalışma saatlerini gösteren modal/sayfa açılacak.
2. **Aktif Tarih Yönetimi:**
   - Seçili tarih `DateTime _selectedDate` olarak yönetilecek.
   - Tarihe tıklandığında `showDatePicker` açılacak.
   - Sol ve sağ butonlar günü 1 gün geri/ileri alacak.
   - `Bugün` butonuna basıldığında anlık tarihe dönecek.
   - Tarih formatı Türkçe olarak dinamik güncellenecek (`DateFormat('d MMMM y, EEEE', 'tr_TR')`).
3. **Randevu Listesi & Filtreleme:**
   - Randevular dinamik bir listede tutulacak (Ahmet Arslan, Canan Demir, Burak Yılmaz, Zeynep Kaya, Mehmet Öztürk, Elif Şahin vb.).
   - Filtre çipleri seçilen kategoriye göre anında listeyi güncelleyecek.
   - Sayaç kutularındaki rakamlar bu listeye göre dinamik hesaplanacak.
4. **Randevu Detay Modalı:**
   - Kartlarda "Detay Görüntüle"ye basıldığında hastanın şikayeti, anamnez bilgisi, planlanan tedavi, alerji uyarısı ve son notları içeren şık bir bottom sheet açılacak.

---

## 📁 2. Ekran: Geçmiş / Tüm Hastalar (`PastPatientsScreen`)
### Mevcut Sorunlar
- Arama ve filtre çipleri kullanıcı notunda belirtildiği üzere eksik/tam senkron değil.
- Hasta kartlarında hastanın son randevu bilgisi yeterince belirgin değil.
- Tedavi geçmişi açıldığında sadece basit iki satır metin var; veritabanı modüllerinden geliyormuş gibi zengin epikriz/detay bilgisi bulunmuyor.

### Yapılacak Geliştirmeler
1. **Arama ve Filtreleme:**
   - Arama kutusu hasta adı, soyadı, TC kimlik numarası ve işlem adına göre anlık filtreleme yapacak.
   - Filtre çipleri (Tüm Hastalar, Bu Ay, İmplant, Cerrahi) ve ek olarak tarihe göre sıralama/filtreleme tam çalışır hale getirilecek.
2. **Hasta Kartında Son Randevu Gösterimi:**
   - Her kartta hastanın son ziyaret tarihi ve yapılan son işlem (ör. *Son Randevu: 14 Mart 2026 - İmplant Kontrolü*) rozet ve açıklama olarak netleştirilecek.
3. **Zengin Tedavi Geçmişi & Epikriz Modalı:**
   - Geçmiş kartı genişletildiğinde veya "Epikriz / Dosya Detayı" butonuna tıklandığında; yapılan müdahale, uygulanan anestezi, hekim klinik notu, reçete edilen ilaçlar ve kontrol tarihi modüler bir şekilde gösterilecek.

---

## 💊 3. Ekran: Reçete Oluştur (`CreatePrescriptionScreen`)
### Mevcut Sorunlar
- Hasta arama kutusu statik, Ahmet Arslan dışında hasta aranamıyor/seçilemiyor. Klavye açılınca taşma ve UI bozulması riski var.
- İlaç dozaj kutusunda "12 Saatte Bir", "8 Saatte Bir" gibi alakasız saat bilgileri bulunuyor.
- Reçete şablonları kısıtlı ve tek tıkla hazır reçete paketi oluşturulamıyor.
- Alt kısımdaki yeşil kalkanlı "Sağlık Bakanlığı Renkli Reçete & Medula Onayı" kutusu görsel kalabalık yaratıyor.
- Gönderme butonu SMS ve e-imza gibi simülasyonlar içeriyor; oluşturulan reçete hasta ekranına yansımıyor.

### Yapılacak Geliştirmeler
1. **Sınırlandırılmış Hasta Arama & Otomatik Seçim:**
   - Hasta arama alanına yazıldığında altta en fazla 2 öneri kartı gösteren, klavye açıkken ekranı kapatmayan `ListView` öneri alanı açılacak.
   - Öneriden bir hasta seçildiğinde:
     - Arama kutusuna adı yerleşecek,
     - Klavye kapanacak ve öneri listesi gizlenecek,
     - Seçilen hastanın yaşı, cinsiyeti, TC'si, protokol no'su, alerji durumu ve ICD-10 tanısı otomatik olarak forma "yapışacak" (aktarılacak).
2. **Dozaj Kutusundaki Saat İfadesinin Kaldırılması:**
   - "12 Saatte Bir", "8 Saatte Bir" gibi uyumsuz saat ifadeleri kaldırılacak.
   - Dozaj alanı sadeleştirilecek: Sıklık (örn: `2x1`), Kullanım (örn: `Tok Karnına`), Tedavi Süresi (örn: `7 Gün`).
3. **Klinik Reçete Şablonları:**
   - Yatay kaydırma düzeltilecek ve popüler klinik şablonları eklenecek:
     - *İmplant Sonrası Profilaksi (Antibiyotik + Ağrı Kesici + Gargara)*
     - *20 Yaş Çekim Sonrası (Ağrı Kesici + Antiseptik)*
     - *Akut Pulpitis & Ağrı (NSAİİ + Mide Koruyucu)*
   - Şablona tıklandığında ilgili ilaç grubu tek dokunuşla listeye eklenecek.
4. **Gereksiz Bilgi Kutusunun Kaldırılması:**
   - Sağlık Bakanlığı / Medula onay kutusu kullanıcı isteği doğrultusunda tamamen kaldırılacak.
5. **"Reçete Oluştur" Butonu ve Hasta Ekranına Yansıma:**
   - Buton metni doğrudan **"Reçete Oluştur"** olarak güncellenecek (SMS ibaresi kaldırılacak).
   - Butona tıklandığında reçete global `ClinicMockData` / Reçete servisine kaydedilecek.
   - Böylece hasta portalına geçildiğinde (`my_results_screen.dart` / Reçetelerim) yeni oluşturulan reçete doğrudan görüntülenebilecek.
   - Hekime şık bir "Reçete başarıyla oluşturuldu ve hasta dosyasına işlendi" onay modalı gösterilecek.

---

## 💬 4. Ekran: Doktor Mesajlar Ekranı (`DoctorMessagesScreen`)
### Mevcut Sorunlar
- Üstte WhatsApp tasarımına uymayan gereksiz filtre çipleri (`Tümü`, `Okunmamış`, `Acil / Ağrı`, `Tedavi Sonrası`) yer alıyor.
- Mesaj kartına tıklanınca yarım sayfalık bir alt modal açılıyor; hekim tam ekran mesajlaşamıyor.
- Yeni hasta mesajı başlatma butonu işlevsel değil; modal üzerinden hasta ve ilk mesaj seçilip gönderilemiyor.

### Yapılacak Geliştirmeler
1. **WhatsApp Sadeliğinde Sohbet Listesi:**
   - Filtre çipleri tamamen kaldırılacak.
   - Sadece arama çubuğu ve son konuşulan hastalar listesi (okunmamış rozeti, son mesaj saati, son mesaj önizlemesi) kalacak.
2. **Tam Sayfa Mesajlaşma Ekranı:**
   - Karta tıklandığında hekim doğrudan tam ekran sohbet sayfasına (`DoctorChatConversationScreen`) yönlendirilecek.
   - Bu ekranda:
     - Hekim ile hasta arasındaki mesaj balonları (gönderen / alan),
     - Gönderim saatleri ve mavi tikler,
     - Hızlı hazır klinik cevap şablonları (*"İlacınızı tok karnına kullanmayı unutmayın"*, *"Şişlik 48 saatte normale dönecektir"*, *"Randevu saatinde klinikte görüşmek üzere"*),
     - Metin giriş alanı ve gönder butonu bulunacak.
     - **Not:** Kullanıcının özel isteği üzerine fotoğraf/görüntü ekleme özelliği olmayacak.
3. **Yeni Hasta Mesajı Başlat Modalı:**
   - "Yeni Hasta Mesajı Başlat" butonuna basıldığında açılan modalda:
     - Hasta adı ve TC Kimlik No ile anlık arama / hasta seçimi,
     - Mesaj metin kutusu,
     - "Mesajı Gönder ve Sohbete Başla" butonu yer alacak.
   - Gönderildiğinde yeni sohbet listeye eklenecek ve doğrudan tam sayfa sohbete geçilecek.

---

## 🚀 Uygulama Adımları ve Sonuç
1. **Adım 1:** Veri tabanı / mock modellerinin ve hasta-doktor veri senkronizasyonunun (`clinic_mock_data.dart`, `prescription_model.dart`, `message_model.dart`) hazırlanması. -> [Tamamlandı]
2. **Adım 2:** `DoctorAgendaScreen` ve `DoctorTopAppBar` bileşenlerinin (tarih seçici, filtreler, bildirimler ve hekim ayarları/profili modalı, detay görüntüleme) tamamlanması. -> [Tamamlandı]
3. **Adım 3:** `PastPatientsScreen` filtrelerinin, aramasının, son randevu gösteriminin ve epikriz detay modalının tamamlanması. -> [Tamamlandı]
4. **Adım 4:** `CreatePrescriptionScreen` arama-seçim, klavye uyumu, saat ifadelerinin temizlenmesi, Medula kutusunun kaldırılması, şablonlar ve hastaya reçetenin yansıtılması işleminin yapılması. -> [Tamamlandı]
5. **Adım 5:** `DoctorMessagesScreen` filtrelerinin kaldırılması, yeni hasta mesajı modalının eklenmesi ve tam ekran `DoctorChatConversationScreen` sayfasının oluşturulup bağlanması (görüntü/ek yükleme butonu olmadan sade metin ve hızlı şablonlar). -> [Tamamlandı]
6. **Adım 6:** Projenin derleme ve test kontrollerinin yapılması. `flutter analyze` ile 0 hata doğrulaması gerçekleştirildi. -> [Tamamlandı]


---

## 🛠️ Ek Düzeltmeler ve Son İyileştirmeler (Hotfix & QA İncelemesi)

Kullanıcı geri bildirimleri ve ekran testleri doğrultusunda `fix/dev1-yapilanlar` dalında gerçekleştirilen ve `develop` dalına birleştirilen ek iyileştirmeler:

### 1. `ListTile` Background / Ink Splash Assertion Düzeltmesi (`create_prescription_screen.dart`)
- **Sorun:** Flutter Web ortamında `ListTile` bileşeni arka plan rengi olan bir `Container` / `DecoratedBox` içine konulduğunda ink splash ve arka plan boyama etkilerinin kaybolabileceğine dair assertion hatası fırlatılıyordu.
- **Çözüm:** Hasta arama açılır öneri listesi (`ListView.separated`) ve ilaç seçim modalındaki kartlar doğrudan kendi `Material(color: Colors.white, borderRadius: BorderRadius.circular(14), clipBehavior: Clip.antiAlias)` katmanına taşındı. Böylece assertion hatası tamamen giderildi, tıklama dalgalanmaları (ink ripple) akıcı hale getirildi.

### 2. Doktor Ajandası Tarih Rozeti ve Güne Göre Randevu Filtreleme (`doctor_agenda_screen.dart`)
- **Tarih Rozeti Dinamizmi:**
  - Seçili tarih durumuna göre rozet metni ve rengi anlık güncellenir:
    - **Bugün (18 Mart):** `Bugün` (Yeşil / Teal klinik rengi)
    - **Gelecek Tarihler (19 Mart ve sonrası):** `Gelecekte` (Mavi ton + Takvim ikonu)
    - **Geçmiş Tarihler (17 Mart ve öncesi):** `Geçmişte` (Gri/Nötr ton + Saat/Tarihçe ikonu)
  - Rozete tıklandığında hekim tek dokunuşla bugünün ajandasına geri döner.
- **Güne Göre Dinamik Randevu Listesi:**
  - Tarih değiştirildiğinde alt kısımdaki randevu listesi ve 4 özet sayaç kutusu (`Toplam`, `Tamamlandı`, `Koltukta`, `Bekleyen`) ile filtre çipleri seçilen günün verilerine göre filtrelenir:
    - **18 Mart 2026 (Bugün):** Canan Demir (09:00), Burak Yılmaz (10:00), Ahmet Arslan (11:15 - Koltukta/Aktif), Zeynep Kaya (13:30), Mehmet Öztürk (14:30), Elif Şahin (16:00).
    - **19 Mart 2026 (Gelecekte / Yarın):** Serdar Koç (09:30), Derya Aydın (11:00), Murat Çelik (14:00), Ayşe Bulut (15:30) randevuları gösterilir. Sayaçlar: `Toplam: 4, Bekleyen: 4, Koltukta: 0, Tamamlandı: 0`.
    - **17 Mart 2026 (Geçmişte / Dün):** Fatma Güler (09:00), Emre Yıldız (10:30), Hasan Akın (13:00), Sevim Yalçın (14:30), Ali Polat (16:00) tamamlanan seansları gösterilir. Sayaçlar: `Toplam: 5, Tamamlandı: 5, Bekleyen: 0, Koltukta: 0`.
    - İlgili filtrede randevu olmadığında şık ve bilgilendirici "Randevu bulunmamaktadır" boş durum kartı (`_buildEmptyNotice`) gösterilir.

### 3. Hasta Portalı Reçete Senkronizasyonu (`my_results_screen.dart`)
- Randevu detayından reçete açma (`initialPrescriptionId`) ile hekimin yeni yazdığı reçetelerin dinamik açılıp kapanması (`Set<String> _expandedRxCodes`) birleştirildi.
- Zorunlu `id` parametresi ve animasyonlu yeşil vurgulama desteği korundu.

### 4. Git & Versiyon Yönetimi
- Tüm geliştirmeler kısa ömürlü `fix/dev1-yapilanlar` dalında tamamlandı.
- Değişiklikler doğrudan `AdilMuratKartal` kimliğiyle commit edildi.
- `develop` dalına başarıyla merge edildi.
- **Doğrulama:** `flutter analyze` ile 0 hata, `flutter test` ile 15/15 test başarısı teyit edildi.
