import '../../../data/models/message_model.dart';
import '../cubit_status.dart';

/// Hasta ve doktor arasındaki mesajlaşma sürecinin durumunu (State) temsil eder.
///
/// Konuşma geçmişinin yüklenme/dinlenme durumu ([dataStatus]) ile mesaj gönderme ve
/// okundu işaretleme işlemlerinin durumu ([actionStatus]) birbirinden bağımsız yönetilir.
class ChatState {
  const ChatState({
    this.dataStatus = DataStatus.initial,
    this.actionStatus = ActionStatus.idle,
    this.conversationId,
    this.patientId,
    this.doctorId,
    this.messages = const <MessageModel>[],
    this.dataError,
    this.actionError,
    this.actionSuccessMessage,
  });

  /// Aktif konuşma mesajlarının yüklenme / dinlenme durumu.
  final DataStatus dataStatus;

  /// Mesaj gönderme veya okundu güncelleme gibi aksiyonların durumu.
  final ActionStatus actionStatus;

  /// Aktif konuşma kimliği (`${patientId}_${doctorId}`).
  final String? conversationId;

  /// Aktif konuşmadaki hasta kimliği.
  final String? patientId;

  /// Aktif konuşmadaki doktor kimliği.
  final String? doctorId;

  /// Aktif konuşmaya ait mesaj listesi.
  final List<MessageModel> messages;

  /// Mesaj listesi yüklenirken veya dinlenirken oluşan hata mesajı.
  final String? dataError;

  /// Mesaj gönderme veya okundu işaretleme sırasında oluşan hata mesajı.
  final String? actionError;

  /// Başarılı aksiyon sonrası isteğe bağlı bilgilendirme mesajı.
  final String? actionSuccessMessage;

  /// Aktif olarak seçilmiş/dinlenen geçerli bir konuşma olup olmadığını döner.
  bool get hasActiveConversation =>
      conversationId != null && conversationId!.trim().isNotEmpty;

  /// Konuşma listesinde görüntülenmeye hazır mesaj olup olmadığını döner.
  bool get hasMessages => messages.isNotEmpty;

  /// Mesajları eskiden yeniye (`createdAt` artan) kronolojik sırayla döner.
  ///
  /// Sohbet ekranlarında mesaj balonlarının doğru akışta gösterilmesi için kullanılır.
  /// Aynı zaman damgasına sahip mesajlarda deterministik sıralama için `id` kullanılır.
  List<MessageModel> get chronologicalMessages {
    if (messages.isEmpty) return const <MessageModel>[];
    final sorted = List<MessageModel>.from(messages)
      ..sort((a, b) {
        final timeComparison = a.createdAt.compareTo(b.createdAt);
        if (timeComparison != 0) return timeComparison;
        return a.id.compareTo(b.id);
      });
    return List<MessageModel>.unmodifiable(sorted);
  }

  /// Mesajları yeniden eskiye (`createdAt` azalan) sırayla döner.
  ///
  /// `reverse: true` kullanan `ListView` bileşenleri için yardımcıdır.
  List<MessageModel> get newestFirstMessages {
    if (messages.isEmpty) return const <MessageModel>[];
    final sorted = List<MessageModel>.from(messages)
      ..sort((a, b) {
        final timeComparison = b.createdAt.compareTo(a.createdAt);
        if (timeComparison != 0) return timeComparison;
        return b.id.compareTo(a.id);
      });
    return List<MessageModel>.unmodifiable(sorted);
  }

  /// Konuşmadaki en son (en güncel) mesajı döner; mesaj yoksa `null` döner.
  MessageModel? get lastMessage {
    final ordered = chronologicalMessages;
    return ordered.isEmpty ? null : ordered.last;
  }

  /// Konuşmadaki tüm okunmamış (`isRead == false`) mesajları döner.
  List<MessageModel> get unreadMessages => List<MessageModel>.unmodifiable(
    chronologicalMessages.where((message) => !message.isRead),
  );

  /// Konuşmadaki toplam okunmamış mesaj sayısı.
  int get unreadCount => unreadMessages.length;

  /// Belirli bir alıcıya (`receiverId`) gelen ve henüz okunmamış mesajları döner.
  List<MessageModel> unreadMessagesForUser(String receiverId) {
    final normalizedReceiverId = receiverId.trim();
    if (normalizedReceiverId.isEmpty) return const <MessageModel>[];
    return List<MessageModel>.unmodifiable(
      chronologicalMessages.where(
        (message) =>
            !message.isRead && message.receiverId.trim() == normalizedReceiverId,
      ),
    );
  }

  /// Belirli bir alıcıya (`receiverId`) ait okunmamış mesaj sayısını döner.
  int unreadCountForUser(String receiverId) =>
      unreadMessagesForUser(receiverId).length;

  ChatState copyWith({
    DataStatus? dataStatus,
    ActionStatus? actionStatus,
    String? conversationId,
    bool clearConversationId = false,
    String? patientId,
    bool clearPatientId = false,
    String? doctorId,
    bool clearDoctorId = false,
    List<MessageModel>? messages,
    String? dataError,
    bool clearDataError = false,
    String? actionError,
    bool clearActionError = false,
    String? actionSuccessMessage,
    bool clearActionSuccessMessage = false,
  }) {
    return ChatState(
      dataStatus: dataStatus ?? this.dataStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      conversationId: clearConversationId
          ? null
          : (conversationId ?? this.conversationId),
      patientId: clearPatientId ? null : (patientId ?? this.patientId),
      doctorId: clearDoctorId ? null : (doctorId ?? this.doctorId),
      messages: messages != null
          ? List<MessageModel>.unmodifiable(messages)
          : this.messages,
      dataError: clearDataError ? null : (dataError ?? this.dataError),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      actionSuccessMessage: clearActionSuccessMessage
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }
}

