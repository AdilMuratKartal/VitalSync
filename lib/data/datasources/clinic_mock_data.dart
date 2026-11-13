import '../models/models.dart';

// Uygulama içi varsayılan örnek veri seti (Geliştirici 4 modelleriyle uyumlu)
class ClinicMockData {
  ClinicMockData._();

  static final UserModel samplePatient = UserModel(
    id: 'PAT-4829',
    fullName: 'Zeynep Demir',
    email: 'zeynep.demir@eposta.com',
    phone: '05324102030',
    tcNo: '34891204829',
    role: 'patient',
    titleOrInfo: 'A Rh+ • Penisilin Alerjisi',
    avatarUrl: 'assets/images/zeynep_demir_profile.png',
    createdAt: DateTime(2026, 1, 15),
  );

  static final UserModel sampleDoctor = UserModel(
    id: 'DOC-101',
    fullName: 'Dr. Selin Yılmaz',
    email: 'selin.yilmaz@dentora.com',
    phone: '05339001020',
    tcNo: '10948271650',
    role: 'doctor',
    titleOrInfo: 'Ağız, Diş ve Çene Cerrahisi',
    avatarUrl: 'assets/images/dr_selin_home.png',
    createdAt: DateTime(2025, 9, 1),
  );

  // Geriye dönük uyumluluk için mevcut sabitler korunur
  static const UserEntity currentPatient = UserEntity(
    id: 'PAT-4829',
    fullName: 'Zeynep Demir',
    role: 'patient',
    titleOrInfo: 'A Rh+ • Penisilin Alerjisi',
    avatarAsset: 'assets/images/zeynep_demir_profile.png',
  );

  static const UserEntity currentDoctor = UserEntity(
    id: 'DOC-101',
    fullName: 'Dr. Selin Yılmaz',
    role: 'doctor',
    titleOrInfo: 'Ağız, Diş ve Çene Cerrahisi',
    avatarAsset: 'assets/images/dr_selin_home.png',
  );

  // Ortak Reçete Veri Havuzu (Doktor oluşturduğunda hastada anında görünür)
  static final List<Map<String, dynamic>> patientPrescriptions = [
    {
      'id': 'REC-2026-89412',
      'code': '#REC-2026-89412',
      'statusBadge': 'Aktif Tedavi',
      'dateText': '14 Mart 2026',
      'title': 'Kanal Tedavisi & Akut Apikal Periodontitis',
      'subtitle': 'Dt. Selin Yılmaz • 3 Kalem İlaç',
      'patientName': 'Ahmet Arslan',
      'doctorName': 'Dr. Selin Yılmaz',
      'medications': [
        {
          'name': 'Augmentin-BID 1000 mg Film Tablet',
          'sub': 'Antibiyotik • 14 Tablet (1 Kutu)',
          'freq': 'Günde 2x1',
          'usage': 'Sabah / Akşam',
          'meal': 'Tok Karnına • 7 Gün Boyunca',
        },
        {
          'name': 'Apranax Fort 550 mg Film Tablet',
          'sub': 'Ağrı Kesici & Anti-inflamatuar • 10 Tablet',
          'freq': 'Günde 2x1',
          'usage': 'Ağrı oldukça (Maks. 2 adet)',
          'meal': 'Tok Karnına • Bol su ile',
        },
        {
          'name': 'Kloroben %0.12 + %0.15 Gargara',
          'sub': 'Oral Antiseptik Solüsyon • 200 ml',
          'freq': 'Günde 3x1',
          'usage': 'Diş fırçalama sonrası 30 sn çalkalama',
          'meal': 'Haricen Gargara • 30 dk bir şey yenmemeli',
        },
      ],
      'note':
          'Antibiyotik kullanımını ağrınız geçse dahi 7. günün sonuna kadar tamamlayınız. Sıcak gıda ve içeceklerden 48 saat kaçınınız.',
    },
    {
      'id': 'REC-2025-44109',
      'code': '#REC-2025-44109',
      'statusBadge': 'Tamamlandı',
      'dateText': '18 Kasım 2025',
      'title': 'Gömülü 20 Yaş Dişi Çekimi Sonrası',
      'subtitle': 'Prof. Dr. Kerem Aydın • 2 Kalem İlaç',
      'patientName': 'Zeynep Demir',
      'doctorName': 'Prof. Dr. Kerem Aydın',
      'medications': [
        {
          'name': 'Klamoks-BID 1000 mg Tablet',
          'sub': 'Antibiyotik • 10 Tablet',
          'freq': 'Günde 2x1',
          'usage': 'Sabah / Akşam',
          'meal': 'Tok Karnına • 5 Gün',
        },
        {
          'name': 'Arveles 25 mg Film Tablet',
          'sub': 'Analjezik • 20 Tablet',
          'freq': 'Günde 2x1',
          'usage': 'Sabah / Akşam',
          'meal': 'Tok Karnına',
        },
      ],
      'note': null,
    },
  ];

  static void addPrescription(Map<String, dynamic> prescription) {
    patientPrescriptions.insert(0, prescription);
  }
}
