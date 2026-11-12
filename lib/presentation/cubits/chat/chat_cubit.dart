import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/message_model.dart';
import '../../../data/services/firestore_service.dart';
import '../cubit_status.dart';
import 'chat_state.dart';

/// Hasta ve doktor arasındaki anlık mesajlaşma süreçlerini yöneten Cubit.
///
/// [FirestoreService] üzerinden gerçek zamanlı konuşma akışını (`streamMessagesByConversation`),
/// tek seferlik konuşma yüklemesini, mesaj gönderimini (`sendMessage`) ve
/// okundu durumu güncellemelerini yönetir.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({FirestoreService? firestoreService})
    : _firestoreService =
          firestoreService ?? ServiceLocator.get<FirestoreService>(),
      super(const ChatState());

  final FirestoreService _firestoreService;

  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;

  int _dataOperationToken = 0;
  int _actionOperationToken = 0;
  int _messagesRevision = 0;

  /// Belirtilen hasta ve doktor arasındaki konuşmayı gerçek zamanlı olarak dinler.
  ///
  /// Önceki konuşma aboneliğini iptal eder ve konuşma değişmişse eski konuşmanın
  /// mesajlarını temizleyerek yeni konuşmaya abone olur.
  void watchConversation({
    required String patientId,
    required String doctorId,
  }) {
    final normalizedPatientId = patientId.trim();
    final normalizedDoctorId = doctorId.trim();
    final validationError = _validateConversationParticipants(
      patientId: normalizedPatientId,
      doctorId: normalizedDoctorId,
    );

    if (validationError != null) {
      _cancelMessagesSubscription();
      _dataOperationToken++;
      if (!isClosed) {
        emit(
          state.copyWith(
            dataStatus: DataStatus.error,
            dataError: validationError,
          ),
        );
      }
      return;
    }

    final targetConversationId = MessageModel.buildConversationId(
      normalizedPatientId,
      normalizedDoctorId,
    );
    final isDifferentConversation =
        state.conversationId != targetConversationId;

    _cancelMessagesSubscription();
    final token = ++_dataOperationToken;

    if (!isClosed) {
      emit(
        state.copyWith(
          dataStatus: DataStatus.loading,
          conversationId: targetConversationId,
          patientId: normalizedPatientId,
          doctorId: normalizedDoctorId,
          messages: isDifferentConversation
              ? const <MessageModel>[]
              : state.messages,
          clearDataError: true,
        ),
      );
    }

    _messagesSubscription = _firestoreService
        .streamMessagesByConversation(targetConversationId)
        .listen(
          (rawList) {
            if (isClosed || token != _dataOperationToken) return;
            _messagesRevision++;
            final items = _parseAndNormalizeMessages(rawList);
            emit(
              state.copyWith(
                dataStatus: items.isEmpty
                    ? DataStatus.empty
                    : DataStatus.success,
                conversationId: targetConversationId,
                patientId: normalizedPatientId,
                doctorId: normalizedDoctorId,
                messages: items,
                clearDataError: true,
              ),
            );
          },
          onError: (Object error) {
            if (isClosed || token != _dataOperationToken) return;
            emit(
              state.copyWith(
                dataStatus: DataStatus.error,
                dataError: _mapFirestoreError(
                  error,
                  fallback: 'Mesajlar yüklenirken bir hata oluştu.',
                ),
              ),
            );
          },
        );
  }

  /// Belirtilen hasta ve doktor arasındaki konuşma geçmişini tek seferlik yükler.
  ///
  /// Aktif bir stream aboneliği varsa iptal eder ve konuşmayı tek seferlik sorgular.
  Future<void> loadConversation({
    required String patientId,
    required String doctorId,
  }) async {
    final normalizedPatientId = patientId.trim();
    final normalizedDoctorId = doctorId.trim();
    final validationError = _validateConversationParticipants(
      patientId: normalizedPatientId,
      doctorId: normalizedDoctorId,
    );

    if (validationError != null) {
      _cancelMessagesSubscription();
      _dataOperationToken++;
      if (!isClosed) {
        emit(
          state.copyWith(
            dataStatus: DataStatus.error,
            dataError: validationError,
          ),
        );
      }
      return;
    }

    final targetConversationId = MessageModel.buildConversationId(
      normalizedPatientId,
      normalizedDoctorId,
    );
    final isDifferentConversation =
        state.conversationId != targetConversationId;

    _cancelMessagesSubscription();
    final token = ++_dataOperationToken;

    if (!isClosed) {
      emit(
        state.copyWith(
          dataStatus: DataStatus.loading,
          conversationId: targetConversationId,
          patientId: normalizedPatientId,
          doctorId: normalizedDoctorId,
          messages: isDifferentConversation
              ? const <MessageModel>[]
              : state.messages,
          clearDataError: true,
        ),
      );
    }

    try {
      final rawList = await _firestoreService.getCollection(
        AppConstants.messagesCollection,
        filterField: 'conversationId',
        isEqualTo: targetConversationId,
        orderByField: 'createdAt',
        descending: false,
      );
      if (isClosed || token != _dataOperationToken) return;

      _messagesRevision++;
      final items = _parseAndNormalizeMessages(rawList);
      emit(
        state.copyWith(
          dataStatus: items.isEmpty ? DataStatus.empty : DataStatus.success,
          conversationId: targetConversationId,
          patientId: normalizedPatientId,
          doctorId: normalizedDoctorId,
          messages: items,
          clearDataError: true,
        ),
      );
    } catch (error) {
      if (isClosed || token != _dataOperationToken) return;
      emit(
        state.copyWith(
          dataStatus: DataStatus.error,
          dataError: _mapFirestoreError(
            error,
            fallback: 'Mesaj geçmişi yüklenirken bir hata oluştu.',
          ),
        ),
      );
    }
  }

  /// Hasta ile doktor arasındaki konuşmaya yeni bir mesaj gönderir.
  ///
  /// Başarılı olursa oluşturulan mesajın belge kimliğini (`id`), hata durumunda `null` döner.
  /// Mesaj gönderimi sırasında veya hata oluştuğunda mevcut mesaj listesi korunur.
  Future<String?> sendMessage({
    required String patientId,
    required String doctorId,
    required String senderId,
    required String receiverId,
    required String text,
    String? attachmentUrl,
  }) async {
    final normalizedPatientId = patientId.trim();
    final normalizedDoctorId = doctorId.trim();
    final normalizedSenderId = senderId.trim();
    final normalizedReceiverId = receiverId.trim();
    final normalizedText = text.trim();
    final normalizedAttachment = attachmentUrl?.trim();
    final hasAttachment =
        normalizedAttachment != null && normalizedAttachment.isNotEmpty;

    final participantError = _validateMessageParticipants(
      patientId: normalizedPatientId,
      doctorId: normalizedDoctorId,
      senderId: normalizedSenderId,
      receiverId: normalizedReceiverId,
    );
    if (participantError != null) {
      _emitActionValidationError(participantError);
      return null;
    }

    if (normalizedText.isEmpty && !hasAttachment) {
      _emitActionValidationError('Boş mesaj gönderilemez.');
      return null;
    }

    final targetConversationId = MessageModel.buildConversationId(
      normalizedPatientId,
      normalizedDoctorId,
    );

    final token = ++_actionOperationToken;
    final revisionBefore = _messagesRevision;

    if (!isClosed) {
      emit(
        state.copyWith(
          actionStatus: ActionStatus.submitting,
          clearActionError: true,
          clearActionSuccessMessage: true,
        ),
      );
    }

    try {
      final now = DateTime.now();
      final messageDraft = MessageModel(
        id: '',
        conversationId: targetConversationId,
        senderId: normalizedSenderId,
        receiverId: normalizedReceiverId,
        patientId: normalizedPatientId,
        doctorId: normalizedDoctorId,
        text: normalizedText,
        attachmentUrl: hasAttachment ? normalizedAttachment : null,
        isRead: false,
        createdAt: now,
      );

      final docId = await _firestoreService.sendMessage(messageDraft.toJson());
      if (isClosed || token != _actionOperationToken) return docId;

      final savedMessage = messageDraft.copyWith(id: docId);
      final isSameActiveConversation =
          state.conversationId == targetConversationId ||
          state.conversationId == null;
      final canApplyLocalUpdate =
          isSameActiveConversation && revisionBefore == _messagesRevision;

      final updatedMessages = canApplyLocalUpdate
          ? _mergeAndSortMessages(state.messages, savedMessage)
          : state.messages;

      emit(
        state.copyWith(
          conversationId: state.conversationId ?? targetConversationId,
          patientId: state.patientId ?? normalizedPatientId,
          doctorId: state.doctorId ?? normalizedDoctorId,
          dataStatus: canApplyLocalUpdate
              ? DataStatus.success
              : state.dataStatus,
          messages: updatedMessages,
          actionStatus: ActionStatus.succeeded,
          actionSuccessMessage: 'Mesaj başarıyla gönderildi.',
          clearActionError: true,
        ),
      );
      return docId;
    } catch (error) {
      if (isClosed || token != _actionOperationToken) return null;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: _mapFirestoreError(
            error,
            fallback: 'Mesaj gönderilirken bir hata oluştu.',
          ),
          clearActionSuccessMessage: true,
        ),
      );
      return null;
    }
  }

  /// Tek bir mesajı okundu (`isRead: true`) olarak işaretler.
  ///
  /// Mesaj zaten okundu olarak işaretlenmişse gereksiz Firestore yazımı yapmaz.
  Future<bool> markMessageAsRead(String messageId) async {
    final normalizedId = messageId.trim();
    if (normalizedId.isEmpty) {
      _emitActionValidationError('Okundu işaretlenecek mesaj kimliği geçersiz.');
      return false;
    }

    final existingIndex = state.messages.indexWhere(
      (message) => message.id == normalizedId,
    );
    if (existingIndex != -1 && state.messages[existingIndex].isRead) {
      return true;
    }

    final token = ++_actionOperationToken;
    final revisionBefore = _messagesRevision;

    try {
      await _firestoreService.updateDocument(
        AppConstants.messagesCollection,
        normalizedId,
        <String, dynamic>{'isRead': true},
      );
      if (isClosed || token != _actionOperationToken) return true;

      if (revisionBefore == _messagesRevision && existingIndex != -1) {
        final updatedList = state.messages
            .map(
              (message) => message.id == normalizedId
                  ? message.copyWith(isRead: true)
                  : message,
            )
            .toList(growable: false);

        emit(state.copyWith(messages: updatedList));
      }
      return true;
    } catch (error) {
      if (isClosed || token != _actionOperationToken) return false;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: _mapFirestoreError(
            error,
            fallback: 'Mesaj okundu bilgisi güncellenemedi.',
          ),
          clearActionSuccessMessage: true,
        ),
      );
      return false;
    }
  }

  /// Aktif konuşmada belirtilen alıcıya (`receiverId`) gelen tüm okunmamış
  /// mesajları okundu (`isRead: true`) olarak işaretler.
  Future<bool> markConversationReadForReceiver(String receiverId) async {
    final normalizedReceiverId = receiverId.trim();
    if (normalizedReceiverId.isEmpty) {
      _emitActionValidationError('Alıcı kullanıcı kimliği boş olamaz.');
      return false;
    }

    final unreadForUser = state.unreadMessagesForUser(normalizedReceiverId);
    if (unreadForUser.isEmpty) {
      return true;
    }

    final token = ++_actionOperationToken;
    final revisionBefore = _messagesRevision;
    final unreadIds = unreadForUser
        .map((message) => message.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    if (unreadIds.isEmpty) {
      return true;
    }

    try {
      for (final messageId in unreadIds) {
        await _firestoreService.updateDocument(
          AppConstants.messagesCollection,
          messageId,
          <String, dynamic>{'isRead': true},
        );
      }
      if (isClosed || token != _actionOperationToken) return true;

      if (revisionBefore == _messagesRevision) {
        final updatedList = state.messages
            .map(
              (message) => unreadIds.contains(message.id)
                  ? message.copyWith(isRead: true)
                  : message,
            )
            .toList(growable: false);

        emit(state.copyWith(messages: updatedList));
      }
      return true;
    } catch (error) {
      if (isClosed || token != _actionOperationToken) return false;
      emit(
        state.copyWith(
          actionStatus: ActionStatus.failed,
          actionError: _mapFirestoreError(
            error,
            fallback: 'Okunmamış mesajlar güncellenirken bir hata oluştu.',
          ),
          clearActionSuccessMessage: true,
        ),
      );
      return false;
    }
  }

  /// Yalnızca aksiyon durumunu (`actionStatus`, `actionError`, `actionSuccessMessage`) sıfırlar.
  void clearActionState() {
    if (isClosed) return;
    emit(
      state.copyWith(
        actionStatus: ActionStatus.idle,
        clearActionError: true,
        clearActionSuccessMessage: true,
      ),
    );
  }

  /// Aktif konuşma aboneliğini iptal eder ve tüm mesajlaşma durumunu sıfırlar.
  ///
  /// Oturum kapatıldığında veya aktif konuşmadan tamamen çıkıldığında çağrılmalıdır.
  Future<void> reset() async {
    _dataOperationToken++;
    _actionOperationToken++;
    _messagesRevision++;
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
    if (!isClosed) {
      emit(const ChatState());
    }
  }

  String? _validateConversationParticipants({
    required String patientId,
    required String doctorId,
  }) {
    if (patientId.isEmpty) {
      return 'Hasta kimliği boş olamaz.';
    }
    if (doctorId.isEmpty) {
      return 'Doktor kimliği boş olamaz.';
    }
    if (patientId == doctorId) {
      return 'Hasta ve doktor kimliği aynı olamaz.';
    }
    return null;
  }

  String? _validateMessageParticipants({
    required String patientId,
    required String doctorId,
    required String senderId,
    required String receiverId,
  }) {
    final conversationError = _validateConversationParticipants(
      patientId: patientId,
      doctorId: doctorId,
    );
    if (conversationError != null) {
      return conversationError;
    }
    if (senderId.isEmpty) {
      return 'Gönderen kullanıcı kimliği boş olamaz.';
    }
    if (receiverId.isEmpty) {
      return 'Alıcı kullanıcı kimliği boş olamaz.';
    }
    if (senderId == receiverId) {
      return 'Gönderen ve alıcı kimliği aynı olamaz.';
    }

    final isPatientToDoctor =
        senderId == patientId && receiverId == doctorId;
    final isDoctorToPatient =
        senderId == doctorId && receiverId == patientId;

    if (!isPatientToDoctor && !isDoctorToPatient) {
      return 'Gönderen ve alıcı kimlikleri aktif konuşmanın hasta ve doktoru ile eşleşmelidir.';
    }

    return null;
  }

  List<MessageModel> _parseAndNormalizeMessages(
    List<Map<String, dynamic>> rawList,
  ) {
    final byId = <String, MessageModel>{};
    final withoutId = <MessageModel>[];

    for (final raw in rawList) {
      final model = MessageModel.fromJson(raw);
      final normalizedId = model.id.trim();
      if (normalizedId.isEmpty) {
        withoutId.add(model);
      } else {
        byId[normalizedId] = model;
      }
    }

    final combined = <MessageModel>[...byId.values, ...withoutId]
      ..sort((a, b) {
        final timeComparison = a.createdAt.compareTo(b.createdAt);
        if (timeComparison != 0) return timeComparison;
        return a.id.compareTo(b.id);
      });

    return List<MessageModel>.unmodifiable(combined);
  }

  List<MessageModel> _mergeAndSortMessages(
    List<MessageModel> existing,
    MessageModel added,
  ) {
    final byId = <String, MessageModel>{};
    final withoutId = <MessageModel>[];

    for (final message in existing) {
      final normalizedId = message.id.trim();
      if (normalizedId.isEmpty) {
        withoutId.add(message);
      } else {
        byId[normalizedId] = message;
      }
    }

    final addedId = added.id.trim();
    if (addedId.isEmpty) {
      withoutId.add(added);
    } else {
      byId[addedId] = added;
    }

    final combined = <MessageModel>[...byId.values, ...withoutId]
      ..sort((a, b) {
        final timeComparison = a.createdAt.compareTo(b.createdAt);
        if (timeComparison != 0) return timeComparison;
        return a.id.compareTo(b.id);
      });

    return List<MessageModel>.unmodifiable(combined);
  }

  void _emitActionValidationError(String message) {
    if (isClosed) return;
    emit(
      state.copyWith(
        actionStatus: ActionStatus.failed,
        actionError: message,
        clearActionSuccessMessage: true,
      ),
    );
  }

  void _cancelMessagesSubscription() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  String _mapFirestoreError(Object error, {required String fallback}) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Bu konuşmaya erişim veya mesaj gönderme yetkiniz bulunmuyor.';
        case 'unavailable':
          return 'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.';
        case 'not-found':
          return 'İlgili mesaj veya konuşma kaydı bulunamadı.';
        default:
          return error.message ?? fallback;
      }
    }
    return fallback;
  }

  @override
  Future<void> close() async {
    _dataOperationToken++;
    _actionOperationToken++;
    await _messagesSubscription?.cancel();
    return super.close();
  }
}

