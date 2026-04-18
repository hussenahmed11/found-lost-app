import '../models/post_model.dart';

/// Basic keyword matching system for lost and found items.

double calculateMatchScore(Post post1, Post post2) {
  // Only match if types are different (Lost vs Found)
  if (post1.type == post2.type) return 0;

  double score = 0;

  // 1. Category match (High weight)
  if (post1.category.toLowerCase() == post2.category.toLowerCase()) {
    score += 50;
  }

  // 2. Title matching (Keyword based)
  final title1Keywords = post1.title.toLowerCase().split(RegExp(r'\s+'));
  final title2Keywords = post2.title.toLowerCase().split(RegExp(r'\s+'));

  final commonKeywords = title1Keywords
      .where((word) => word.length > 3 && title2Keywords.contains(word));

  score += commonKeywords.length * 20;

  // 3. Location matching (Basic string match)
  if (post1.location.toLowerCase().contains(post2.location.toLowerCase()) ||
      post2.location.toLowerCase().contains(post1.location.toLowerCase())) {
    score += 30;
  }

  return score;
}

List<Post> findPotentialMatches(Post newPost, List<Post> allPosts) {
  final scored = allPosts
      .map((post) => MapEntry(post, calculateMatchScore(newPost, post)))
      .where((entry) => entry.value > 40) // Threshold for a "match"
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return scored.map((entry) => entry.key).toList();
}
