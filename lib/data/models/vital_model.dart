import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore 'vitals' koleksiyonu için sağlık değerleri (tansiyon, şeker, nabız, SpO2) modeli
class VitalModel {
  final String id;
  final String patientId;
  final int systolic; // Büyük tansiyon (mmHg)
  final int diastolic; // Küçük tansiyon (mmHg)
  final int bloodSugar; // Kan şekeri (mg/dL)
  final int pulse; // Nabız (bpm)
  final int oxygen; // SpO2 oksijen doygunluğu (%)
  final DateTime createdAt;

  const VitalModel({
    required this.id,
    required this.patientId,
    required this.systolic,
    required this.diastolic,
    required this.bloodSugar,
    required this.pulse,
    required this.oxygen,
    required this.createdAt,
  });

  // Kritik sağlık değeri kontrolü (project.md iş kuralı)
  bool get isCritical =>
      systolic >= 140 ||
      diastolic >= 90 ||
      bloodSugar >= 180 ||
      bloodSugar < 70 ||
      pulse > 110 ||
      pulse < 50 ||
      oxygen < 94;

  // Formatlı tansiyon metni (Örn: '120/80')
  String get bloodPressureText => '$systolic/$diastolic';

  factory VitalModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return VitalModel(
      id: id ?? (json['id'] as String? ?? ''),
      patientId: json['patientId'] as String? ?? '',
      systolic: (json['systolic'] as num?)?.toInt() ?? 120,
      diastolic: (json['diastolic'] as num?)?.toInt() ?? 80,
      bloodSugar: (json['bloodSugar'] as num?)?.toInt() ?? 95,
      pulse: (json['pulse'] as num?)?.toInt() ?? 72,
      oxygen: (json['oxygen'] as num?)?.toInt() ?? 98,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'systolic': systolic,
      'diastolic': diastolic,
      'bloodSugar': bloodSugar,
      'pulse': pulse,
      'oxygen': oxygen,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  VitalModel copyWith({
    String? id,
    String? patientId,
    int? systolic,
    int? diastolic,
    int? bloodSugar,
    int? pulse,
    int? oxygen,
    DateTime? createdAt,
  }) {
    return VitalModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      pulse: pulse ?? this.pulse,
      oxygen: oxygen ?? this.oxygen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}

