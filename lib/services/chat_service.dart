import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _chatsCollection = 'chats';
  static const String _messagesCollection = 'messages';

  /// Create or get an existing chat between two users.
  Future<String> createOrGetChat(String user1Id, String user2Id) async {
    final participants = [user1Id, user2Id]..sort();
    final chatId = participants.join('_');

    final chatRef = _db.collection(_chatsCollection).doc(chatId);
    final chatSnap = await _db
        .collection(_chatsCollection)
        .where('participants', isEqualTo: participants)
        .get();

    if (chatSnap.docs.isEmpty) {
      await chatRef.set({
        'chatId': chatId,
        'participants': participants,
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  /// Send a message in a chat.
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final messageData = {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Add message to subcollection
    await _db
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesCollection)
        .add(messageData);

    // Update last message in chat metadata
    await _db.collection(_chatsCollection).doc(chatId).set({
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream of messages in a chat, ordered by creation time.
  Stream<List<Message>> listenToMessages(String chatId) {
    return _db
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  /// Stream of chats for a user, ordered by last update.
  Stream<List<Chat>> getUserChats(String userId) {
    return _db
        .collection(_chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList());
  }
}
