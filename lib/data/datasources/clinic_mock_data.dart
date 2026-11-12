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
}
