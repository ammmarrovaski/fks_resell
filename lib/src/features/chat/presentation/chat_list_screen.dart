import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';
import 'chat_detail_screen.dart';

class _ChatColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color accent = Color(0xFFD4A574);
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatRepo = ChatRepository();
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: _ChatColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _ChatColors.bordo.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.forum_rounded,
                      color: _ChatColors.bordo,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Poruke',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _ChatColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Razgovori sa prodavcima i kupcima',
                          style: TextStyle(
                            fontSize: 13,
                            color: _ChatColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Chat list
            Expanded(
              child: StreamBuilder<List<ChatRoom>>(
                stream: chatRepo.getChatRooms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _ChatColors.bordo),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: _ChatColors.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'Greska pri ucitavanju',
                            style: TextStyle(color: _ChatColors.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  final chatRooms = snapshot.data ?? [];

                  if (chatRooms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _ChatColors.cardBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _ChatColors.textMuted.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 44,
                              color: _ChatColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Nema poruka',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _ChatColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 48),
                            child: Text(
                              'Kada kontaktirate prodavca ili vas neko kontaktira, razgovori ce se pojaviti ovdje.',
                              style: TextStyle(fontSize: 14, color: _ChatColors.textMuted, height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: chatRooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      return _buildChatRoomTile(
                        context,
                        chatRooms[index],
                        currentUid,
                        chatRepo,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRoomTile(
    BuildContext context,
    ChatRoom room,
    String currentUid,
    ChatRepository chatRepo,
  ) {
    // Get the other person's name
    final otherName = room.participantNames.entries
        .where((e) => e.key != currentUid)
        .map((e) => e.value)
        .firstOrNull ?? 'Korisnik';

    final unreadCount = room.unreadCounts[currentUid] ?? 0;
    final hasUnread = unreadCount > 0;
    final isMyLastMessage = room.lastMessageSenderId == currentUid;

    // Format time
    String timeText = '';
    if (room.lastMessageTime != null) {
      final now = DateTime.now();
      final diff = now.difference(room.lastMessageTime!);
      if (diff.inMinutes < 1) {
        timeText = 'Sad';
      } else if (diff.inHours < 1) {
        timeText = '${diff.inMinutes}m';
      } else if (diff.inDays < 1) {
        timeText = '${diff.inHours}h';
      } else if (diff.inDays < 7) {
        timeText = '${diff.inDays}d';
      } else {
        timeText = '${room.lastMessageTime!.day}.${room.lastMessageTime!.month}.';
      }
    }

    return Dismissible(
      key: Key(room.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 26),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _ChatColors.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Obrisi razgovor?',
              style: TextStyle(color: _ChatColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Ovaj razgovor i sve poruke ce biti trajno obrisani.',
              style: TextStyle(color: _ChatColors.textSecondary, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Odustani', style: TextStyle(color: _ChatColors.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Obrisi', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) {
        chatRepo.deleteChatRoom(room.id);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  chatRoomId: room.id,
                  otherUserName: otherName,
                  productTitle: room.productTitle,
                  productImageUrl: room.productImageUrl,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: hasUnread ? _ChatColors.bordo.withOpacity(0.06) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _ChatColors.bordo.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasUnread
                              ? _ChatColors.bordo.withOpacity(0.5)
                              : _ChatColors.textMuted.withOpacity(0.15),
                          width: hasUnread ? 2 : 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: _ChatColors.bordo,
                        size: 26,
                      ),
                    ),
                    if (hasUnread)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _ChatColors.bordo,
                            shape: BoxShape.circle,
                            border: Border.all(color: _ChatColors.background, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              otherName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                color: _ChatColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            timeText,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasUnread ? _ChatColors.bordo : _ChatColors.textMuted,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Product tag
                      if (room.productTitle != null && room.productTitle!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _ChatColors.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            room.productTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _ChatColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // Last message
                      Row(
                        children: [
                          if (isMyLastMessage)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.done_all_rounded,
                                size: 14,
                                color: _ChatColors.textMuted,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              room.lastMessage ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: hasUnread
                                    ? _ChatColors.textSecondary
                                    : _ChatColors.textMuted,
                                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
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
        ),
      ),
    );
  }
}
