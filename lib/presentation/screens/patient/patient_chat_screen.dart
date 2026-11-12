import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/clinic_mock_data.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/chat/chat_cubit.dart';
import '../../widgets/dentora_logo.dart';

class PatientChatScreen extends StatefulWidget {
  const PatientChatScreen({super.key});

  @override
  State<PatientChatScreen> createState() => _PatientChatScreenState();
}

class _PatientChatScreenState extends State<PatientChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasAttachedPhoto = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text':
          'Merhaba Ahmet Bey, dün gerçekleştirdiğimiz sol alt çene implant operasyonunuz sonrasında genel durumunuz nasıl? Ağrı veya şişlik kontrolünüz yolunda mı?',
      'time': '09:42',
    },
    {
      'isMe': true,
      'text':
          'Merhaba Selin Hanım, buz kompresini tarif ettiğiniz gibi uyguladım. Ağrım oldukça azaldı fakat dikiş bölgesinde hafif bir beyazlık fark ettim, normal midir?',
      'time': '09:45',
    },
    {
      'isMe': false,
      'text':
          'İyileşme dokusu (fibrin tabakası) oluştuğu için dikiş çevresinde beyazımsı bir görünüm çok normaldir. İsterseniz net bir fotoğraf çekip buradan paylaşın, hemen kontrol edeyim.',
      'time': '09:47',
      'prescriptionTag': 'Augmentin 1000mg & Klorhex Gargara (Günde 2x1)',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final patientId = context.read<AuthCubit>().state.user?.id ?? ClinicMockData.samplePatient.id;
      final doctorId = ClinicMockData.sampleDoctor.id;
      context.read<ChatCubit>().watchConversation(patientId: patientId, doctorId: doctorId);
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty && !_hasAttachedPhoto) return;

    final msgText = text.isNotEmpty
        ? text
        : 'Sol alt çene dikiş bölgesi fotoğrafını ekledim hocam.';

    final patientId = context.read<AuthCubit>().state.user?.id ?? ClinicMockData.samplePatient.id;
    final doctorId = ClinicMockData.sampleDoctor.id;

    setState(() {
      _messages.add({
        'isMe': true,
        'text': msgText,
        'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'hasPhoto': _hasAttachedPhoto,
      });
      _msgController.clear();
      _hasAttachedPhoto = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    await context.read<ChatCubit>().sendMessage(
      patientId: patientId,
      doctorId: doctorId,
      senderId: patientId,
      receiverId: doctorId,
      text: msgText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = context.watch<ChatCubit>().state;
    final patientId = context.watch<AuthCubit>().state.user?.id ?? ClinicMockData.samplePatient.id;
    final realMessages = chatState.chronologicalMessages;
    final canSend =
        _msgController.text.trim().isNotEmpty || _hasAttachedPhoto;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const PatientTopAppBar(),

            // Doctor Conversation Sub-Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceContainerHigh),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/dr_selin_chat.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldOnline,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Dt. Selin Yılmaz',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Symbols.verified,
                                    size: 15,
                                    fill: 1,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                              Text(
                                'Çene Cerrahisi & İmplantoloji • Çevrimiçi',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      _buildCircleActionButton(Symbols.call),
                      const SizedBox(width: 6),
                      _buildCircleActionButton(Symbols.more_vert),
                    ],
                  ),
                ],
              ),
            ),

            // Chat Message Stream
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  // Date Divider Pill
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'BUGÜN, 24 EKİM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (chatState.dataStatus.isLoading && realMessages.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  if (realMessages.isNotEmpty) ...[
                    for (final msg in realMessages) ...[
                      _buildMessageBubble({
                        'isMe': msg.senderId == patientId,
                        'text': msg.text,
                        'time': '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                      }),
                      const SizedBox(height: 14),
                    ],
                  ] else ...[
                    for (final msg in _messages) ...[
                      _buildMessageBubble(msg),
                      const SizedBox(height: 14),
                    ],
                  ],

                  // Interactive Media Attachment Preview Card
                  if (_hasAttachedPhoto)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 280,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(4),
                          ),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D131B2E),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/tooth_photo.png',
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RANDEVU ÖNCESİ GÖRSEL',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    'sol_alt_cene_dikis.jpg',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '1.8 MB • Gönderime Hazır',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _hasAttachedPhoto = false),
                              icon: const Icon(
                                Symbols.close,
                                size: 18,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Message Composer Area
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.surfaceContainerHigh),
                ),
              ),
              child: Row(
                children: [
                  // Camera / Photo Attach Button
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      setState(() {
                        _hasAttachedPhoto = !_hasAttachedPhoto;
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _hasAttachedPhoto
                            ? AppColors.secondaryFixed
                            : AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.add_a_photo,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Input Pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _sendMessage(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Hekiminize mesaj yazın...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.outline.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const Icon(
                            Symbols.attach_file,
                            size: 20,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Dynamic Mic / Send Button
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: canSend
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryContainer,
                                ],
                              )
                            : null,
                        color: canSend ? null : AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        canSend ? Symbols.send : Symbols.mic,
                        size: 20,
                        fill: canSend ? 1 : 0,
                        color: canSend ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleActionButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: AppColors.primary),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] as bool;
    final text = msg['text'] as String;
    final time = msg['time'] as String;
    final prescriptionTag = msg['prescriptionTag'] as String?;
    final hasPhoto = (msg['hasPhoto'] as bool?) ?? false;

    if (!isMe) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/dr_selin_chat.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(
                      color: AppColors.surfaceContainerHigh.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A131B2E),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (prescriptionTag != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Symbols.medication,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AKTİF REÇETE HATIRLATMASI',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      prescriptionTag,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F006574),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasPhoto) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/tooth_photo.png',
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Symbols.done_all, size: 14, color: AppColors.primary),
          ],
        ),
      ],
    );
  }
}
