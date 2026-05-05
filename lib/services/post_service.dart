import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import 'image_upload_service.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'posts';

  /// Create a new post, optionally uploading an image first via Cloudinary.
  Future<DocumentReference> createPost(
      String userId, Map<String, dynamic> postData, String? imagePath) async {
    String? imageUrl;

    if (imagePath != null) {
      imageUrl = await ImageUploadService.uploadImage(imagePath);
    }

    final post = {
      ...postData,
      'userId': userId,
      'imageUrl': imageUrl,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    };

    return await _db.collection(_collection).add(post);
  }

  /// Stream of all posts ordered by creation date.
  /// Filtering by type and category is done client-side to avoid
  /// Firestore composite index requirements (failed-precondition error).
  Stream<List<Post>> getPosts({String? type, String? category}) {
    // Simple query — only orderBy createdAt, no compound where + orderBy
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      var posts = snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();

      // Client-side filtering to avoid Firestore index errors
      if (type != null && type.toLowerCase() != 'all') {
        posts = posts.where((p) => p.type.toLowerCase() == type.toLowerCase()).toList();
      }
      if (category != null && category.toLowerCase() != 'all') {
        posts = posts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
      }

      return posts;
    });
  }

  /// Stream of posts for a specific user.
  /// Uses client-side filtering to avoid Firestore composite index requirement.
  Stream<List<Post>> getUserPosts(String userId) {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromFirestore(doc))
            .where((post) => post.userId == userId)
            .toList());
  }

  /// Get a single post by ID.
  Future<Post?> getPostById(String postId) async {
    final doc = await _db.collection(_collection).doc(postId).get();
    if (doc.exists) {
      return Post.fromFirestore(doc);
    }
    return null;
  }

  /// Delete a post by ID.
  Future<void> deletePost(String postId) {
    return _db.collection(_collection).doc(postId).delete();
  }

  /// Update the status of a post.
  Future<void> updatePostStatus(String postId, String status) {
    return _db.collection(_collection).doc(postId).update({'status': status});
  }
}
