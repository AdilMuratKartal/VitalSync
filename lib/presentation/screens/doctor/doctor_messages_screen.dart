import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/dentora_logo.dart';

class DoctorMessagesScreen extends StatefulWidget {
  const DoctorMessagesScreen({super.key});

  @override
  State<DoctorMessagesScreen> createState() => _DoctorMessagesScreenState();
}

class _DoctorMessagesScreenState extends State<DoctorMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _chats = [
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
    if (q.isEmpty) return _chats;
    return _chats.where((c) {
      final hay = '${c['name']} ${c['tag']} ${c['preview']}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  void _openNewPatientMessageModal() {
    final searchCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    Map<String, dynamic>? selectedPatient;

    final allClinicPatients = [
      {
        'name': 'Ahmet Arslan',
        'tc': '428••••••14',
        'fullTc': '42819204914',
        'tag': '#46 İmplant Sonrası',
        'avatar': 'assets/images/patient_ahmet_chat.png',
      },
      {
        'name': 'Canan Demir',
        'tc': '298••••••19',
        'fullTc': '29810482019',
        'tag': 'Zirkonyum Kaplama Prova',
        'avatar': 'assets/images/patient_canan_chat.png',
      },
      {
        'name': 'Zeynep Kaya',
        'tc': '348••••••29',
        'fullTc': '34891204829',
        'tag': 'Kanal Tedavisi Kontrol',
        'avatar': 'assets/images/patient_zeynep_chat.png',
      },
      {
        'name': 'Burak Yılmaz',
        'tc': '512••••••12',
        'fullTc': '51290384712',
        'tag': 'Diş Taşı Temizliği',
        'avatar': 'assets/images/patient_burak_chat.png',
      },
      {
        'name': 'Mehmet Öztürk',
        'tc': '619••••••29',
        'fullTc': '61928471029',
        'tag': '20 Yaş Çekimi',
        'avatar': 'assets/images/patient_mehmet_past.png',
      },
      {
        'name': 'Elif Şahin',
        'tc': '184••••••72',
        'fullTc': '18492048172',
        'tag': 'Şeffaf Plak Kontrol',
        'avatar': 'assets/images/patient_canan_past.png',
      },
    ];

    selectedPatient = allClinicPatients.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final query = searchCtrl.text.trim().toLowerCase();
          final filtered = allClinicPatients.where((p) {
            if (query.isEmpty) return true;
            return (p['name'] as String).toLowerCase().contains(query) ||
                (p['fullTc'] as String).contains(query);
          }).toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.78,
            decoration: const BoxDecoration(
              color: AppColors.doctorSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Yeni Hasta Mesajı Başlat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceDoctor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Symbols.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Search field by Name or TC
                TextField(
                  controller: searchCtrl,
                  onChanged: (_) => setModalState(() {}),
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceDoctor),
                  decoration: InputDecoration(
                    hintText: 'Hasta adı veya TC Kimlik No ile arayın...',
                    prefixIcon: const Icon(Symbols.search, size: 20, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.doctorSurfaceContainerHigh),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.doctorSurfaceContainerHigh),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Patients list (choose patient)
                const Text(
                  'HASTA SEÇİN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryDoctor,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (ctx, i) {
                      final p = filtered[i];
                      final isSelected = selectedPatient?['name'] == p['name'];
                      return InkWell(
                        onTap: () => setModalState(() => selectedPatient = p),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondaryFixedDoctor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.doctorSurfaceContainerHigh,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(p['avatar'] as String, width: 28, height: 28, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${p['name']} (TC: ${p['tc']})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: AppColors.onSurfaceDoctor,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Symbols.check_circle, size: 18, color: AppColors.primary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Initial Message Field
                const Text(
                  'İLK MESAJINIZ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryDoctor,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: messageCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceDoctor),
                  decoration: InputDecoration(
                    hintText: 'Hastaya iletmek istediğiniz mesajı yazın...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.doctorSurfaceContainerHigh),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.doctorSurfaceContainerHigh),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (selectedPatient == null) return;
                      Navigator.pop(ctx);
                      context.push('/doctor/chat', extra: {
                        'name': selectedPatient!['name'],
                        'avatar': selectedPatient!['avatar'],
                        'tag': selectedPatient!['tag'],
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Symbols.send, size: 18),
                    label: const Text('Mesajı Gönder ve Sohbete Başla', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
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
                        // Search Bar (Clean WhatsApp style)
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceDoctor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Hasta adı, protokol no veya mesaj ara...',
                            prefixIcon: const Icon(
                              Symbols.search,
                              size: 20,
                              color: AppColors.outline,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(Symbols.close, size: 18, color: AppColors.outline),
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.surfaceContainerLowest,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.doctorSurfaceContainerHigh,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.doctorSurfaceContainerHigh,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MESAJLAR & SOHBETLER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${list.length} Sohbet',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Conversation List
                        if (list.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.doctorSurfaceContainerHigh,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Symbols.search_off,
                                  size: 32,
                                  color: AppColors.outline,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Aramanızla eşleşen mesaj bulunamadı.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
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

            // Floating Action Button: Yeni Hasta Mesajı Başlat (opens modal!)
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
                  onPressed: _openNewPatientMessageModal,
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

  Widget _buildChatCard(Map<String, dynamic> chat) {
    final isUnread = chat['isUnread'] as bool;
    final online = chat['online'] as bool;
    final unreadCount = chat['unreadCount'] as String?;
    final tagIcon = chat['tagIcon'] as IconData?;
    final extraTag = chat['extraTag'] as String?;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push(
        '/doctor/chat',
        extra: {
          'name': chat['name'],
          'avatar': chat['avatar'],
          'tag': chat['tag'],
        },
      ),
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
                                  fontSize: 11,
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
                  const SizedBox(height: 4),
                  Row(
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
                      if (extraTag != null) ...[
                        const SizedBox(width: 6),
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
