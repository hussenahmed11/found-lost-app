import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String description;
  final String type; // 'lost' or 'found'
  final String category;
  final String location;
  final String? imageUrl;
  final String userId;
  final String status;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.location,
    this.imageUrl,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'lost',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'open',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'userId': userId,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
