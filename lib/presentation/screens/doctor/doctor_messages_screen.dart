import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/clinic_mock_data.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/chat/chat_cubit.dart';
import '../../widgets/dentora_logo.dart';

class DoctorMessagesScreen extends StatefulWidget {
  const DoctorMessagesScreen({super.key});

  @override
  State<DoctorMessagesScreen> createState() => _DoctorMessagesScreenState();
}

class _DoctorMessagesScreenState extends State<DoctorMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  static const List<Map<String, dynamic>> _chats = [
    {
      'name': 'Ahmet Arslan',
      'time': '10:42',
      'unreadCount': '1',
      'online': true,
      'avatar': 'assets/images/patient_ahmet_chat.png',
      'tag': '#46 İmplant Sonrası',
      'tagIcon': Symbols.dentistry,
      'tagBg': AppColors.secondaryFixedDoctor,
      'tagFg': AppColors.onSecondaryFixedVariantDoctor,
      'extraTag': 'Röntgen Eklendi',
      'preview':
          'Hocam dün yapılan implant sonrası hafif bir şişlik var, buz kompresine devam edeyim mi?',
      'category': 'urgent',
      'isUnread': true,
    },
    {
      'name': 'Canan Demir',
      'time': '09:15',
      'unreadCount': '1',
      'online': true,
      'avatar': 'assets/images/patient_canan_chat.png',
      'tag': 'Zirkonyum Kaplama Prova',
      'tagIcon': Symbols.radiology,
      'tagBg': AppColors.tertiaryFixedDoctor,
      'tagFg': AppColors.tertiaryDoctor,
      'extraTag': null,
      'preview':
          'Selin Hanım merhaba, yarınki 14:30 randevumu 16:00\'ya çekme şansımız olur mu?',
      'category': 'postop',
      'isUnread': true,
    },
    {
      'name': 'Zeynep Kaya',
      'time': 'Dün',
      'unreadCount': null,
      'online': false,
      'avatar': 'assets/images/patient_zeynep_chat.png',
      'tag': 'Kanal Tedavisi Kontrol',
      'tagIcon': null,
      'tagBg': AppColors.doctorSurfaceContainerLow,
      'tagFg': AppColors.onSurfaceVariant,
      'extraTag': null,
      'preview':
          'Siz: Yazdığım antibiyotiği sabah akşam tok karnına 5 gün boyunca aksatmadan kullanın lütfen.',
      'category': 'postop',
      'isUnread': false,
    },
    {
      'name': 'Burak Yılmaz',
      'time': '14 Eki',
      'unreadCount': null,
      'online': false,
      'avatar': 'assets/images/patient_burak_chat.png',
      'tag': 'Diş Taşı Temizliği & Bleaching',
      'tagIcon': null,
      'tagBg': AppColors.doctorSurfaceContainerLow,
      'tagFg': AppColors.onSurfaceVariant,
      'extraTag': null,
      'preview':
          'Çok teşekkür ederim doktor hanım, hassasiyetim tamamen geçti.',
      'category': 'all',
      'isUnread': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredChats {
    final q = _searchController.text.trim().toLowerCase();
    return _chats.where((c) {
      if (_selectedFilter == 'unread' && c['isUnread'] != true) return false;
      if (_selectedFilter == 'urgent' && c['category'] != 'urgent') {
        return false;
      }
      if (_selectedFilter == 'postop' && c['category'] != 'postop') {
        return false;
      }
      if (q.isEmpty) return true;
      final hay = '${c['name']} ${c['tag']} ${c['preview']}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  void _openPatientReplyModal(Map<String, dynamic> chat) {
    final replyCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    chat['avatar'] as String,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceDoctor,
                        ),
                      ),
                      Text(
                        chat['tag'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Symbols.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.doctorSurfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                chat['preview'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.onSurfaceDoctor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replyCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Hastaya klinik yanıtınızı yazın...',
                filled: true,
                fillColor: AppColors.doctorSurfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final replyText = replyCtrl.text.trim();
                  if (replyText.isNotEmpty) {
                    final doctorId = context.read<AuthCubit>().state.user?.id ?? ClinicMockData.sampleDoctor.id;
                    final patientId = ClinicMockData.samplePatient.id;
                    await context.read<ChatCubit>().sendMessage(
                      patientId: patientId,
                      doctorId: doctorId,
                      senderId: doctorId,
                      receiverId: patientId,
                      text: replyText,
                    );
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${chat['name']} adlı hastaya yanıtınız iletildi.',
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Symbols.send, size: 18),
                label: const Text(
                  'Yanıtı Gönder',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredChats;

    return Scaffold(
      backgroundColor: AppColors.doctorSurface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const DoctorTopAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search & Filter Bar
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceDoctor,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Hasta adı, protokol no veya işlem ara...',
                                  prefixIcon: const Icon(
                                    Symbols.search,
                                    size: 20,
                                    color: AppColors.outline,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceContainerLowest,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color:
                                          AppColors.doctorSurfaceContainerHigh,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color:
                                          AppColors.doctorSurfaceContainerHigh,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.doctorSurfaceContainerHigh,
                                ),
                              ),
                              child: const Icon(
                                Symbols.tune,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Quick Filter Pills
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterPill('all', 'Tümü', badge: '4'),
                              const SizedBox(width: 8),
                              _buildFilterPill(
                                'unread',
                                'Okunmamış',
                                badge: '2',
                                badgeRed: true,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterPill('urgent', 'Acil / Ağrı'),
                              const SizedBox(width: 8),
                              _buildFilterPill('postop', 'Tedavi Sonrası'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Encryption Banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.doctorSurfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.doctorSurfaceContainerHigh,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Symbols.verified_user,
                                    size: 18,
                                    fill: 1,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Dentora Şifreli Hekim-Hasta Hattı',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurfaceDoctor,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'KVKK Uyumlu',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Patient Conversation List
                        for (final chat in list) ...[
                          _buildChatCard(chat),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Button
            Positioned(
              right: 16,
              bottom: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _openPatientReplyModal(_chats.first),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(
                    Symbols.edit_square,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Yeni Hasta Mesajı Başlat',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(
    String key,
    String label, {
    String? badge,
    bool badgeRed = false,
  }) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? null
              : Border.all(color: AppColors.doctorSurfaceContainerHigh),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : (badgeRed
                            ? AppColors.errorContainer
                            : AppColors.doctorSurfaceContainerLow),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (badgeRed ? AppColors.error : AppColors.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    final isUnread = chat['isUnread'] as bool;
    final online = chat['online'] as bool;
    final unreadCount = chat['unreadCount'] as String?;
    final tagIcon = chat['tagIcon'] as IconData?;
    final extraTag = chat['extraTag'] as String?;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openPatientReplyModal(chat),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.doctorSurfaceContainerHigh,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0B1C30),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    chat['avatar'] as String,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: online
                          ? AppColors.emeraldOnline
                          : AppColors.outlineVariant,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceDoctor,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            chat['time'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isUnread
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (unreadCount != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: chat['tagBg'] as Color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tagIcon != null) ...[
                              Icon(
                                tagIcon,
                                size: 12,
                                color: chat['tagFg'] as Color,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              chat['tag'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: chat['tagFg'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (extraTag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            extraTag,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onErrorContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (!isUnread) ...[
                        const Icon(
                          Symbols.done_all,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat['preview'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isUnread
                                ? AppColors.onSurfaceDoctor
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

