import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class SavedPostsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Toggle saved status for a post.
  Future<void> toggleSaved(String userId, String postId) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('savedPosts')
        .doc(postId);

    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'postId': postId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Check if a post is saved by the user.
  Future<bool> isSaved(String userId, String postId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('savedPosts')
        .doc(postId)
        .get();
    return doc.exists;
  }

  /// Stream of saved post IDs for a user.
  Stream<List<String>> getSavedPostIds(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('savedPosts')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Stream of saved posts (full Post objects) for a user.
  Stream<List<Post>> getSavedPosts(String userId) {
    return getSavedPostIds(userId).asyncMap((postIds) async {
      if (postIds.isEmpty) return <Post>[];

      final List<Post> posts = [];
      // Firestore 'whereIn' supports max 10 items per query
      for (var i = 0; i < postIds.length; i += 10) {
        final chunk = postIds.sublist(
            i, i + 10 > postIds.length ? postIds.length : i + 10);
        final snapshot = await _db
            .collection('posts')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        posts.addAll(
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
      }
      return posts;
    });
  }

  /// Remove a post from saved.
  Future<void> removeSaved(String userId, String postId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('savedPosts')
        .doc(postId)
        .delete();
  }
}
