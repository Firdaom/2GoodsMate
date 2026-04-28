import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/core/repositories/chat_repository.dart';
import 'package:anigoods/features/auth/providers/auth_provider.dart';
import 'package:anigoods/models/message_model.dart';


final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, otherUserId) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  
  // ดึงข้อมูล User ปัจจุบันจาก authStateProvider 
  final currentUser = ref.watch(authStateProvider).value;
  
  if (currentUser == null) return Stream.value([]);
  
  return chatRepo.getMessagesStream(
    currentUserId: currentUser.uid,
    otherUserId: otherUserId,
  );
});