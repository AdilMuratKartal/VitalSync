class UserEntity {
  final String id;
  final String fullName;
  final String role; // 'patient' or 'doctor'
  final String titleOrInfo;
  final String avatarAsset;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.role,
    required this.titleOrInfo,
    required this.avatarAsset,
  });
}

class AppointmentEntity {
  final String id;
  final String title;
  final String subtitle;
  final String doctorOrPatientName;
  final String dateText;
  final String timeText;
  final String status;
  final String priceText;

  const AppointmentEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.doctorOrPatientName,
    required this.dateText,
    required this.timeText,
    required this.status,
    required this.priceText,
  });
}

