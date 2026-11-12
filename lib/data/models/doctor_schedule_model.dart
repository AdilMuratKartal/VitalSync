import 'package:cloud_firestore/cloud_firestore.dart';

// Doktorun sunduğu tekil dental işlem ve ücret kalemi
class ProcedurePriceItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final int price;
  final int durationMinutes;
  final bool isActive;

  const ProcedurePriceItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.category = '',
    required this.price,
    this.durationMinutes = 30,
    this.isActive = true,
  });

  factory ProcedurePriceItem.fromJson(Map<String, dynamic> json) {
    return ProcedurePriceItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
      isActive: (json['isActive'] as bool?) ?? (json['active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'price': price,
      'durationMinutes': durationMinutes,
      'isActive': isActive,
      'active': isActive,
    };
  }

  ProcedurePriceItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    int? price,
    int? durationMinutes,
    bool? isActive,
  }) {
    return ProcedurePriceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Firestore 'doctor_schedules' koleksiyonu için doktor çalışma saatleri, mola ve fiyat modeli
class DoctorScheduleModel {
  final String id;
  final String doctorId;
  final List<bool> workingDays; // Pzt..Paz (7 elemanlı)
  final String workStart; // Örn: '09:00'
  final String workEnd; // Örn: '18:00'
  final String breakRange; // Örn: '12:30 - 13:30'
  final int slotDurationMinutes; // 30, 45, 60
  final Map<String, String> timeSlots; // Saat -> 'open' | 'break' | 'closed'
  final List<ProcedurePriceItem> procedures; // 12 dental işlem kalemi
  final DateTime updatedAt;

  const DoctorScheduleModel({
    required this.id,
    required this.doctorId,
    this.workingDays = const [true, true, true, true, true, true, false],
    this.workStart = '09:00',
    this.workEnd = '18:00',
    this.breakRange = '12:30 - 13:30',
    this.slotDurationMinutes = 30,
    this.timeSlots = const {},
    this.procedures = const [],
    required this.updatedAt,
  });

  // Yalnızca aktif (randevuya açık) işlemleri döndürür
  List<ProcedurePriceItem> get activeProcedures =>
      procedures.where((p) => p.isActive).toList();

  factory DoctorScheduleModel.fromJson(
    Map<String, dynamic> json, {
    String? id,
  }) {
    final rawDays = json['workingDays'] as List<dynamic>?;
    final parsedDays = rawDays != null && rawDays.length == 7
        ? rawDays.map((e) => e == true).toList()
        : const [true, true, true, true, true, true, false];

    final rawSlots = json['timeSlots'] as Map<String, dynamic>? ?? const {};
    final parsedSlots = rawSlots.map(
      (key, value) => MapEntry(key, value?.toString() ?? 'open'),
    );

    final rawProcedures =
        json['procedures'] as List<dynamic>? ?? const <dynamic>[];
    final parsedProcedures = rawProcedures
        .whereType<Map<String, dynamic>>()
        .map(ProcedurePriceItem.fromJson)
        .toList();

    final resolvedDocId = json['doctorId'] as String? ?? '';
    return DoctorScheduleModel(
      id: id ?? (json['id'] as String? ?? resolvedDocId),
      doctorId: resolvedDocId,
      workingDays: parsedDays,
      workStart: json['workStart'] as String? ?? '09:00',
      workEnd: json['workEnd'] as String? ?? '18:00',
      breakRange: json['breakRange'] as String? ?? '12:30 - 13:30',
      slotDurationMinutes: (json['slotDurationMinutes'] as num?)?.toInt() ?? 30,
      timeSlots: parsedSlots,
      procedures: parsedProcedures,
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'workingDays': workingDays,
      'workStart': workStart,
      'workEnd': workEnd,
      'breakRange': breakRange,
      'slotDurationMinutes': slotDurationMinutes,
      'timeSlots': timeSlots,
      'procedures': procedures.map((p) => p.toJson()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DoctorScheduleModel copyWith({
    String? id,
    String? doctorId,
    List<bool>? workingDays,
    String? workStart,
    String? workEnd,
    String? breakRange,
    int? slotDurationMinutes,
    Map<String, String>? timeSlots,
    List<ProcedurePriceItem>? procedures,
    DateTime? updatedAt,
  }) {
    return DoctorScheduleModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      workingDays: workingDays ?? this.workingDays,
      workStart: workStart ?? this.workStart,
      workEnd: workEnd ?? this.workEnd,
      breakRange: breakRange ?? this.breakRange,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      timeSlots: timeSlots ?? this.timeSlots,
      procedures: procedures ?? this.procedures,
      updatedAt: updatedAt ?? this.updatedAt,
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

