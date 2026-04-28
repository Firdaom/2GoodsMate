import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/features/chat/providers/chat_provider.dart';
import 'package:anigoods/core/repositories/chat_repository.dart';
import 'package:anigoods/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart'; 

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String sellerId;
  final String sellerName;

  const ChatRoomScreen({
    super.key, 
    required this.sellerId, 
    required this.sellerName,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── ฟังก์ชันส่งข้อความ ─────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    _messageCtrl.clear(); 

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
        currentUserId: currentUser.uid,
        receiverId: widget.sellerId,
        messageText: text,
      );
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.sellerId));
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accent,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(widget.sellerName, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 💬 ส่วนแสดงข้อความ
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon( Icons.sms_outlined,),
                        const SizedBox(height: 10),
                        Text('Start a conversation with ${widget.sellerName}',
                            style: const TextStyle(color: AppTheme.textMuted)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.uid;
                    
                    return _ChatBubble(
                      message: msg.text,
                      isMe: isMe,
                      time: DateFormat('HH:mm').format(msg.timestamp),
                    );
                  },
                );
              },
            ),
          ),

          // ⌨️ ช่องพิมพ์ข้อความ
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border),
                ),
                 child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                   border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false, 
                    fillColor: Colors.transparent,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: const CircleAvatar(
                backgroundColor: AppTheme.accent,
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget ฟองสบู่ข้อความ 
class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;

  const _ChatBubble({required this.message, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.accent : AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: isMe ? null : Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white.withOpacity(0.7) : AppTheme.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}