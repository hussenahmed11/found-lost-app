import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _chatsCollection = 'chats';
  static const String _messagesCollection = 'messages';

  /// Generate a deterministic chat ID from two user IDs.
  /// Sorting ensures both users always get the same ID.
  String getChatId(String user1Id, String user2Id) {
    final ids = [user1Id, user2Id]..sort();
    return ids.join('_');
  }

  /// Create or get an existing chat between two users.
  /// Uses deterministic chatId so both users always share the same thread.
  Future<String> createOrGetChat(String user1Id, String user2Id) async {
    final participants = [user1Id, user2Id]..sort();
    final chatId = participants.join('_');

    final chatRef = _db.collection(_chatsCollection).doc(chatId);
    final chatSnap = await chatRef.get();

    if (!chatSnap.exists) {
      await chatRef.set({
        'chatId': chatId,
        'participants': participants,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  /// Send a message in a chat.
  /// Also creates the chat document if it doesn't exist (edge case safety).
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final chatRef = _db.collection(_chatsCollection).doc(chatId);

    // Use a batch to atomically write message + update chat metadata
    final batch = _db.batch();

    // Add message to subcollection
    final messageRef = chatRef.collection(_messagesCollection).doc();
    batch.set(messageRef, {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update chat metadata (merge to create if missing)
    batch.set(chatRef, {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// Send the first message when contacting an owner.
  /// Creates the chat AND sends the initial message atomically.
  Future<String> sendFirstMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final participants = [senderId, receiverId]..sort();
    final chatId = participants.join('_');

    final chatRef = _db.collection(_chatsCollection).doc(chatId);
    final batch = _db.batch();

    // Ensure chat document exists with all required fields
    batch.set(chatRef, {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Add the first message
    final messageRef = chatRef.collection(_messagesCollection).doc();
    batch.set(messageRef, {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return chatId;
  }

  /// Stream of messages in a chat, ordered by creation time.
  /// Uses onSnapshot for real-time updates.
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

  /// Stream of chats for a user, ordered by last message time.
  /// Uses arrayContains to find all chats where user is a participant.
  /// Falls back to client-side sorting if composite index is not set up.
  Stream<List<Chat>> getUserChats(String userId) {
    // Use simple query without orderBy to avoid needing a composite index.
    // Sorting is done client-side for reliability.
    return getUserChatsSimple(userId);
  }

  /// Alternative getUserChats that doesn't require a composite index.
  /// Use this if Firestore composite index is not set up.
  Stream<List<Chat>> getUserChatsSimple(String userId) {
    return _db
        .collection(_chatsCollection)
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final chats =
          snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();
      // Sort client-side by lastMessageTime descending
      chats.sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime(2000);
        final bTime = b.lastMessageTime ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      return chats;
    });
  }

  /// Delete a chat and all its messages.
  Future<void> deleteChat(String chatId) async {
    final chatRef = _db.collection(_chatsCollection).doc(chatId);

    // Delete all messages in the subcollection
    final messages = await chatRef.collection(_messagesCollection).get();
    final batch = _db.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    // Delete the chat document
    batch.delete(chatRef);
    await batch.commit();
  }

  /// Check if a chat exists between two users.
  Future<bool> chatExists(String user1Id, String user2Id) async {
    final chatId = getChatId(user1Id, user2Id);
    final doc = await _db.collection(_chatsCollection).doc(chatId).get();
    return doc.exists;
  }
}
