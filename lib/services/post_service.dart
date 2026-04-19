import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_model.dart';
import 'image_upload_service.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  /// Stream of posts with optional filters.
  Stream<List<Post>> getPosts({String? type, String? category}) {
    Query query = _db.collection(_collection);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  /// Stream of posts for a specific user.
  Stream<List<Post>> getUserPosts(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
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
