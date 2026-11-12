import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

// Firestore 'users' koleksiyonu için kullanıcı veri modeli
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String tcNo;
  final String role; // 'patient' veya 'doctor'
  final String titleOrInfo; // Uzmanlık alanı veya kan grubu/alerji bilgisi
  final String avatarUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.tcNo = '',
    this.role = AppConstants.rolePatient,
    this.titleOrInfo = '',
    this.avatarUrl = AppConstants.defaultAvatarFallbackAsset,
    required this.createdAt,
  });

  // Rol kontrol yardımcıları
  bool get isDoctor => role == AppConstants.roleDoctor;
  bool get isPatient => role == AppConstants.rolePatient;

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final resolvedId =
        id ?? (json['id'] as String?) ?? (json['uid'] as String?) ?? '';
    final resolvedAvatar =
        (json['avatarUrl'] as String?) ??
        (json['photoUrl'] as String?) ??
        AppConstants.defaultAvatarFallbackAsset;

    return UserModel(
      id: resolvedId,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      tcNo: json['tcNo'] as String? ?? '',
      role: json['role'] as String? ?? AppConstants.rolePatient,
      titleOrInfo: json['titleOrInfo'] as String? ?? '',
      avatarUrl: resolvedAvatar,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'tcNo': tcNo,
      'role': role,
      'titleOrInfo': titleOrInfo,
      'avatarUrl': avatarUrl,
      'photoUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? tcNo,
    String? role,
    String? titleOrInfo,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      tcNo: tcNo ?? this.tcNo,
      role: role ?? this.role,
      titleOrInfo: titleOrInfo ?? this.titleOrInfo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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

