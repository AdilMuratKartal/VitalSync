import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

// Firestore 'results' koleksiyonu için tahlil, röntgen ve tıbbi sonuç modeli
class ResultModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String title; // Örn: 'Panoramik Diş Röntgeni'
  final String category; // 'radiology', 'lab', 'report'
  final String summary;
  final String fileUrl; // StorageService hem 'fileUrl' hem 'downloadUrl' yazar
  final String status; // 'ready', 'pending'
  final bool isLocalFallback; // Spark planı yerel görsel kontrolü
  final DateTime createdAt;

  const ResultModel({
    required this.id,
    required this.patientId,
    this.doctorId = '',
    this.doctorName = '',
    required this.title,
    this.category = 'radiology',
    this.summary = '',
    this.fileUrl = AppConstants.defaultXrayFallbackAsset,
    this.status = 'ready',
    this.isLocalFallback = true,
    required this.createdAt,
  });

  bool get isReady => status == 'ready';
  String get downloadUrl => fileUrl;

  factory ResultModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final resolvedUrl =
        (json['fileUrl'] as String?) ??
        (json['downloadUrl'] as String?) ??
        AppConstants.defaultXrayFallbackAsset;
    final resolvedSummary =
        (json['summary'] as String?) ?? (json['note'] as String?) ?? '';

    return ResultModel(
      id: id ?? (json['id'] as String? ?? ''),
      patientId: json['patientId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'radiology',
      summary: resolvedSummary,
      fileUrl: resolvedUrl,
      status: json['status'] as String? ?? 'ready',
      isLocalFallback:
          json['isLocalFallback'] as bool? ?? !resolvedUrl.startsWith('http'),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'title': title,
      'category': category,
      'summary': summary,
      'note': summary,
      'fileUrl': fileUrl,
      'downloadUrl': fileUrl,
      'status': status,
      'isLocalFallback': isLocalFallback,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ResultModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? title,
    String? category,
    String? summary,
    String? fileUrl,
    String? status,
    bool? isLocalFallback,
    DateTime? createdAt,
  }) {
    return ResultModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      title: title ?? this.title,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      isLocalFallback: isLocalFallback ?? this.isLocalFallback,
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

