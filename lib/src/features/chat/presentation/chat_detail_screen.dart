import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';

class _MsgColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color myBubble = Color(0xFF722F37);
  static const Color otherBubble = Color(0xFF2E2E2E);
  static const Color accent = Color(0xFFD4A574);
}

class ChatDetailScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;
  final String? productTitle;
  final String? productImageUrl;

  const ChatDetailScreen({
    Key? key,
    required this.chatRoomId,
    required this.otherUserName,
    this.productTitle,
    this.productImageUrl,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _chatRepo = ChatRepository();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening
    _chatRepo.markAsRead(widget.chatRoomId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _chatRepo.sendMessage(widget.chatRoomId, text);
      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greska: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: _MsgColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: _MsgColors.background,
              border: Border(
                bottom: BorderSide(color: _MsgColors.textMuted.withOpacity(0.12)),
              ),
            ),
            child: Row(
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _MsgColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, size: 20, color: _MsgColors.textPrimary),
                  ),
                ),

                const SizedBox(width: 4),

                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _MsgColors.bordo.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: _MsgColors.bordo, size: 22),
                ),

                const SizedBox(width: 12),

                // Name + product
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.otherUserName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _MsgColors.textPrimary,
                        ),
                      ),
                      if (widget.productTitle != null && widget.productTitle!.isNotEmpty)
                        Text(
                          widget.productTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _MsgColors.accent,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Product context banner
          if (widget.productTitle != null && widget.productTitle!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _MsgColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _MsgColors.accent.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 16, color: _MsgColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Razgovor o: ${widget.productTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _MsgColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatRepo.getMessages(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _MsgColors.bordo),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _MsgColors.cardBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.waving_hand_rounded,
                            size: 36,
                            color: _MsgColors.accent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Zapocni razgovor!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _MsgColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Posaljite poruku korisniku ${widget.otherUserName}',
                          style: const TextStyle(fontSize: 14, color: _MsgColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                // Mark as read whenever new messages come in
                _chatRepo.markAsRead(widget.chatRoomId);

                // Auto scroll to bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUid;

                    // Show date separator
                    bool showDate = false;
                    if (index == 0) {
                      showDate = true;
                    } else {
                      final prev = messages[index - 1];
                      if (msg.timestamp != null && prev.timestamp != null) {
                        showDate = msg.timestamp!.day != prev.timestamp!.day;
                      }
                    }

                    return Column(
                      children: [
                        if (showDate && msg.timestamp != null)
                          _buildDateSeparator(msg.timestamp!),
                        _buildMessageBubble(msg, isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16, 12, 8,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: _MsgColors.cardBg,
              border: Border(
                top: BorderSide(color: _MsgColors.textMuted.withOpacity(0.12)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: _MsgColors.inputBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _MsgColors.textMuted.withOpacity(0.15)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(color: _MsgColors.textPrimary, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Napisi poruku...',
                        hintStyle: TextStyle(color: _MsgColors.textMuted, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _MsgColors.bordo,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _MsgColors.bordo.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    String text;

    if (diff.inDays == 0) {
      text = 'Danas';
    } else if (diff.inDays == 1) {
      text = 'Jucer';
    } else {
      final months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'avg', 'sep', 'okt', 'nov', 'dec'];
      text = '${date.day}. ${months[date.month - 1]} ${date.year}.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: _MsgColors.textMuted.withOpacity(0.15))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: _MsgColors.textMuted, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Divider(color: _MsgColors.textMuted.withOpacity(0.15))),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    final timeText = msg.timestamp != null
        ? '${msg.timestamp!.hour.toString().padLeft(2, '0')}:${msg.timestamp!.minute.toString().padLeft(2, '0')}'
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 6,
          left: isMe ? 48 : 0,
          right: isMe ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? _MsgColors.myBubble : _MsgColors.otherBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : _MsgColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white.withOpacity(0.6) : _MsgColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
