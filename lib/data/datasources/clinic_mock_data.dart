import '../../domain/entities/clinic_entities.dart';

/// UI-only static clinic mock dataset for Clean Architecture data layer compliance.
class ClinicMockData {
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

