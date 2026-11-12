import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore 'messages' koleksiyonu için hasta-doktor mesajlaşma modeli
class MessageModel {
  final String id;
  final String conversationId; // FirestoreService sorgu alanı
  final String senderId;
  final String receiverId;
  final String patientId;
  final String doctorId;
  final String text;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.patientId,
    required this.doctorId,
    required this.text,
    this.attachmentUrl,
    this.isRead = false,
    required this.createdAt,
  });

  // Hasta ve doktor kimliğinden standart sohbet kimliği üretir
  static String buildConversationId(String patientId, String doctorId) =>
      '${patientId}_$doctorId';

  factory MessageModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final patId = json['patientId'] as String? ?? '';
    final docId = json['doctorId'] as String? ?? '';
    final convId =
        (json['conversationId'] as String?) ??
        buildConversationId(patId, docId);

    return MessageModel(
      id: id ?? (json['id'] as String? ?? ''),
      conversationId: convId,
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      patientId: patId,
      doctorId: docId,
      text: json['text'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'patientId': patientId,
      'doctorId': doctorId,
      'text': text,
      'attachmentUrl': attachmentUrl,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? patientId,
    String? doctorId,
    String? text,
    String? attachmentUrl,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      text: text ?? this.text,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRead: isRead ?? this.isRead,
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

