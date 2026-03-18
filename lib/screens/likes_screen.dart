// lib/screens/likes_screen.dart
// Shows profiles you have liked, with the ability to un-like from here too.
// If you already have a likes_screen.dart, REPLACE it with this file.

import 'package:flutter/material.dart';
import '../models/app_data.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  final _state = AppState.instance;

  @override
  Widget build(BuildContext context) {
    final liked = _state.likedProfiles;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Your Likes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: liked.isEmpty
          ? _EmptyLikes()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: liked.length,
              itemBuilder: (context, index) {
                return _LikedCard(
                  profile: liked[index],
                  onUnlike: () => setState(() => _state.toggleLike(liked[index].id)),
                );
              },
            ),
    );
  }
}

class _LikedCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onUnlike;

  const _LikedCard({required this.profile, required this.onUnlike});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Profile image
          Image.network(
            profile.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFF0E6FF),
              child: const Icon(Icons.person, size: 60, color: Color(0xFF7B2FF7)),
            ),
          ),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),

          // Name + unlike button
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${profile.age}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),

                // Unlike button
                GestureDetector(
                  onTap: () {
                    onUnlike();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed like for ${profile.name}'),
                        backgroundColor: Colors.grey[700],
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E8C),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLikes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded, size: 44, color: Color(0xFFE91E8C)),
          ),
          const SizedBox(height: 16),
          const Text('No likes yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 6),
          Text('Go to Discover and like some profiles!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
