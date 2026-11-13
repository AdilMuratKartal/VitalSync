import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';

class DoctorChatScreen extends StatefulWidget {
  final String patientName;
  final String patientAvatar;
  final String tag;

  const DoctorChatScreen({
    super.key,
    required this.patientName,
    required this.patientAvatar,
    required this.tag,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'isDoctor': false,
        'text': 'Hocam merhaba, dün yapılan işlem sonrası hafif bir sızı ve şişlik var. Buz kompresine devam edeyim mi?',
        'time': '10:40',
        'isRead': true,
      },
      {
        'isDoctor': true,
        'text': 'Merhaba ${widget.patientName}, geçmiş olsun. İlk 24-48 saatte hafif ödem ve sızı cerrahi işlemlerden sonra beklediğimiz normal bir tablodur.',
        'time': '10:42',
        'isRead': true,
      },
      {
        'isDoctor': true,
        'text': 'Reçete ettiğim ağrı kesicinizi tok karnına kullanmaya devam edin ve dışarıdan 10 dk aralıklarla soğuk kompres uygulayın. Sıcak gıdalardan kaçının.',
        'time': '10:43',
        'isRead': true,
      },
    ];
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickText]) {
    final text = (quickText ?? _textController.text).trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'isDoctor': true,
        'text': text,
        'time': timeStr,
        'isRead': false,
      });
      if (quickText == null) {
        _textController.clear();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // WhatsApp / clean chat bg
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 44,
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.patientAvatar,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 38,
                      height: 38,
                      color: AppColors.secondaryFixedDoctor,
                      alignment: Alignment.center,
                      child: Text(
                        widget.patientName.isNotEmpty ? widget.patientName[0] : 'H',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.emeraldOnline,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.patientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceDoctor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.tag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(' • ', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                      const Text(
                        'Çevrimiçi',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF047857),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Klinik Bilgi',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.patientName} için klinik dosya senkronize.'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Symbols.info, color: AppColors.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Safe Encryption Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Color(0x080B1C30), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.lock, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Mesajlar KVKK & Sağlık Bakanlığı standartlarında şifrelenmektedir.',
                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  final msg = _messages[i];
                  final isDoctor = msg['isDoctor'] as bool;
                  return _buildMessageBubble(
                    text: msg['text'] as String,
                    time: msg['time'] as String,
                    isDoctor: isDoctor,
                    isRead: msg['isRead'] as bool? ?? false,
                  );
                },
              ),
            ),

            // Quick Clinical Templates Row (Hekim Hızlı Yanıtları)
            Container(
              height: 42,
              color: Colors.white.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickReplyChip('İlacınızı tok karnına alın'),
                  _buildQuickReplyChip('Şişlik 48 saatte inmeye başlar'),
                  _buildQuickReplyChip('Sıcak gıdalardan kaçının'),
                  _buildQuickReplyChip('Randevu saatinde görüşmek üzere'),
                ],
              ),
            ),

            // Bottom Input Bar (NO image upload as requested!)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.doctorSurfaceContainerHigh),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _textController,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceDoctor),
                        decoration: const InputDecoration(
                          hintText: 'Mesajınızı yazın...',
                          hintStyle: TextStyle(fontSize: 13, color: AppColors.outline),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Symbols.send, size: 20, color: Colors.white),
                      onPressed: () => _sendMessage(),
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

  Widget _buildQuickReplyChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
        backgroundColor: AppColors.secondaryFixedDoctor,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required String time,
    required bool isDoctor,
    required bool isRead,
  }) {
    return Align(
      alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: isDoctor ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isDoctor ? 16 : 4),
            bottomRight: Radius.circular(isDoctor ? 4 : 16),
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x0A0B1C30), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: isDoctor ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: isDoctor ? Colors.white : AppColors.onSurfaceDoctor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDoctor ? Colors.white.withValues(alpha: 0.75) : AppColors.onSurfaceVariant,
                  ),
                ),
                if (isDoctor) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Symbols.done_all,
                    size: 14,
                    color: isRead ? const Color(0xFF67E8F9) : Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
