import 'package:cloud_firestore/cloud_firestore.dart';

// Reçete içindeki tekil ilaç kalemi modeli
class MedicineItem {
  final String name;
  final String dosage; // Örn: '1000 mg'
  final String frequency; // Örn: 'Günde 2 kez (2x1)'
  final String duration; // Örn: '5 Gün'
  final String instructions; // Örn: 'Tok karnına'

  const MedicineItem({
    required this.name,
    this.dosage = '',
    this.frequency = '',
    this.duration = '',
    this.instructions = '',
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }

  MedicineItem copyWith({
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    return MedicineItem(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }
}

// Firestore 'prescriptions' koleksiyonu için reçete veri modeli
class PrescriptionModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String diagnosis;
  final List<MedicineItem> medicines;
  final String doctorNote;
  final bool isApproved; // Onaylanmış reçete değiştirilemez (project.md kuralı)
  final DateTime createdAt;

  const PrescriptionModel({
    required this.id,
    required this.patientId,
    this.patientName = '',
    required this.doctorId,
    this.doctorName = '',
    required this.diagnosis,
    this.medicines = const [],
    this.doctorNote = '',
    this.isApproved = true,
    required this.createdAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final rawMedicines = json['medicines'] as List<dynamic>? ?? const [];
    final parsedMedicines = rawMedicines.map((item) {
      if (item is Map<String, dynamic>) {
        return MedicineItem.fromJson(item);
      }
      if (item is String) {
        return MedicineItem(name: item);
      }
      return const MedicineItem(name: '');
    }).toList();

    return PrescriptionModel(
      id: id ?? (json['id'] as String? ?? ''),
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      diagnosis: json['diagnosis'] as String? ?? '',
      medicines: parsedMedicines,
      doctorNote: json['doctorNote'] as String? ?? '',
      isApproved: json['isApproved'] as bool? ?? true,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'diagnosis': diagnosis,
      'medicines': medicines.map((m) => m.toJson()).toList(),
      'doctorNote': doctorNote,
      'isApproved': isApproved,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PrescriptionModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? diagnosis,
    List<MedicineItem>? medicines,
    String? doctorNote,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      diagnosis: diagnosis ?? this.diagnosis,
      medicines: medicines ?? this.medicines,
      doctorNote: doctorNote ?? this.doctorNote,
      isApproved: isApproved ?? this.isApproved,
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

