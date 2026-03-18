// lib/screens/home_screen.dart
// Replace your existing home_screen.dart with this file.
// Shows exactly 3 discovery profiles; heart button toggles like / unlike.

import 'package:flutter/material.dart';
import '../models/app_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _state = AppState.instance;

  @override
  Widget build(BuildContext context) {
    final profiles = _state.discoveryProfiles;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'ming',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE91E8C),
                ),
              ),
              TextSpan(
                text: 'gle',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7B2FF7),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFFE91E8C)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          return _ProfileCard(
            profile: profiles[index],
            onLikeToggled: () => setState(() {}),
          );
        },
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onLikeToggled;

  const _ProfileCard({required this.profile, required this.onLikeToggled});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final liked = state.isLiked(profile.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  profile.imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 300,
                    color: const Color(0xFFF0E6FF),
                    child: const Icon(Icons.person, size: 80, color: Color(0xFF7B2FF7)),
                  ),
                ),
                // Like badge overlay
                if (liked)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E8C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Liked', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Info section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profile.name}, ${profile.age}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Color(0xFF9B59B6)),
                            const SizedBox(width: 2),
                            Text(
                              profile.location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9B59B6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ── Heart / Unlike button ───────────────────────────────
                    GestureDetector(
                      onTap: () {
                        state.toggleLike(profile.id);
                        onLikeToggled();
                        final isNowLiked = state.isLiked(profile.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isNowLiked
                                  ? 'You liked ${profile.name}! ❤️'
                                  : 'Like removed for ${profile.name}',
                            ),
                            backgroundColor:
                                isNowLiked ? const Color(0xFFE91E8C) : Colors.grey[600],
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: liked ? const Color(0xFFE91E8C) : Colors.white,
                          border: Border.all(
                            color: liked ? const Color(0xFFE91E8C) : const Color(0xFFDDD0E8),
                            width: 2,
                          ),
                          boxShadow: liked
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFE91E8C).withOpacity(0.35),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  )
                                ]
                              : [],
                        ),
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.white : const Color(0xFFE91E8C),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text(
                  profile.bio,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                ),
                const SizedBox(height: 12),

                // Interest chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: profile.interests
                      .map((tag) => _InterestChip(label: tag))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  const _InterestChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4F3), Color(0xFFEEE0FF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF7B2FF7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
