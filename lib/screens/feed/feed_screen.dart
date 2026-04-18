import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Sample data matching the React Native version
  final List<Post> _posts = [
    Post(
      id: '1',
      title: 'Lost iPhone 13 Pro',
      description: 'Lost my iPhone 13 Pro near the main library entrance.',
      type: 'lost',
      location: 'Main Library',
      category: 'Electronics',
      imageUrl:
          'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?auto=format&fit=crop&q=80&w=400',
      userId: 'user1',
      status: 'open',
      createdAt: DateTime.now(),
    ),
    Post(
      id: '2',
      title: 'Found Blue Backpack',
      description: 'Found a blue backpack at the Student Center.',
      type: 'found',
      location: 'Student Center',
      category: 'Bags',
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&q=80&w=400',
      userId: 'user2',
      status: 'open',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostCard(
            post: post,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/item-details',
                arguments: post,
              );
            },
          );
        },
      ),
    );
  }
}
