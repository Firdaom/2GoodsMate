import 'package:flutter/material.dart';
import 'package:anigoods/core/theme/app_theme.dart';

class ChatRoomScreen extends StatelessWidget {
  final String sellerName;

  const ChatRoomScreen({super.key, required this.sellerName});

  @override
  Widget build(BuildContext context) {
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
            Text(sellerName, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 💬 ส่วนแสดงข้อความ (Mockup Messages)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
              ],
            ),
          ),

          // ⌨️ ช่องพิมพ์ข้อความ (Mockup Input)
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
            const CircleAvatar(
              backgroundColor: AppTheme.accent,
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget ฟองสบู่ข้อความ ──────────────────────────────
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
          crossAxisAlignment: CrossAxisAlignment.end,
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