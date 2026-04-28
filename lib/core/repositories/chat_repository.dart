import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/models/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(firestore: FirebaseFirestore.instance);
});

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  
  String getChatRoomId(String currentUserId, String otherUserId) {
    List<String> ids = [currentUserId, otherUserId];
    ids.sort(); 
    return ids.join('_'); 
  }

  // ─── ฟังก์ชันส่งข้อความ ─────────────────────────────────
  Future<void> sendMessage({
    required String currentUserId,
    required String receiverId,
    required String messageText,
  }) async {
    try {
      final chatRoomId = getChatRoomId(currentUserId, receiverId);

      // สร้างข้อความใหม่
      final newMessage = MessageModel(
        id: '', 
        senderId: currentUserId,
        receiverId: receiverId,
        text: messageText,
        timestamp: DateTime.now(),
      );

      // โยนขึ้น Firebase 
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toFirestore());

    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // ───  ฟังก์ชันดึงข้อความแบบ Real-time 
  Stream<List<MessageModel>> getMessagesStream({
    required String currentUserId,
    required String otherUserId,
  }) {
    final chatRoomId = getChatRoomId(currentUserId, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
    });
  }
}