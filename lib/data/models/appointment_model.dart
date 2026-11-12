import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore 'appointments' koleksiyonu için randevu veri modeli
class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String serviceName;
  final int price;
  final String date; // Örn: '2026-05-15'
  final String time; // Örn: '10:30'
  final String status; // 'pending', 'approved', 'completed', 'cancelled'
  final String note;
  final DateTime createdAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    this.patientName = '',
    required this.doctorId,
    this.doctorName = '',
    required this.serviceName,
    this.price = 0,
    required this.date,
    required this.time,
    this.status = 'pending',
    this.note = '',
    required this.createdAt,
  });

  // Durum kontrol yardımcıları (FirestoreService çakışma kontrolü ile uyumlu)
  bool get isCancelled =>
      status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'iptal';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isActive => !isCancelled && !isCompleted;

  factory AppointmentModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return AppointmentModel(
      id: id ?? (json['id'] as String? ?? ''),
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      note: json['note'] as String? ?? '',
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
      'serviceName': serviceName,
      'price': price,
      'date': date,
      'time': time,
      'status': status,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? serviceName,
    int? price,
    String? date,
    String? time,
    String? status,
    String? note,
    DateTime? createdAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      note: note ?? this.note,
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

