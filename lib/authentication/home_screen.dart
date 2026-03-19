import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String imageUrl;
  final String location;
  final List<String> interests;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.imageUrl,
    required this.location,
    required this.interests,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final String currentUserId =
      FirebaseAuth.instance.currentUser?.uid ?? "unknown";

  final List<UserProfile> discoveryProfiles = const [
    UserProfile(
      id: '1',
      name: 'Anika',
      age: 24,
      bio:
          'Coffee lover ☕ | Dog mom 🐶 | Hiking enthusiast. Looking for someone to explore trails and try new cafés with.',
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      location: 'Colombo, LK',
      interests: ['Hiking', 'Coffee', 'Photography', 'Travel'],
    ),
    UserProfile(
      id: '2',
      name: 'Rayan',
      age: 27,
      bio:
          'Music producer 🎵 | Foodie | Beach bum on weekends. Let\'s grab kottu and talk about life.',
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      location: 'Negombo, LK',
      interests: ['Music', 'Food', 'Beach', 'Gaming'],
    ),
    UserProfile(
      id: '3',
      name: 'Nisha',
      age: 22,
      bio:
          'Art student 🎨 | Book worm 📚 | Plant parent 🌿. Swipe right if you can handle my painting mess.',
      imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
      location: 'Kandy, LK',
      interests: ['Art', 'Reading', 'Plants', 'Yoga'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleLike(String likedUserUid) async {
    if (currentUserId == "unknown") return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('liked_users')
        .doc(likedUserUid)
        .set({'likedAt': FieldValue.serverTimestamp()});

    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Logout", style: TextStyle(color: Color(0xFFFF4D6D))),
        content:
            const Text("Are you sure?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Minggle",
          style: TextStyle(
            color: Color(0xFFFF4D6D),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDiscoverPage()
          : const Center(
              child:
                  Text("Coming Soon", style: TextStyle(color: Colors.white))),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFFFF4D6D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.style), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Liked"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Chats"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDiscoverPage() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: discoveryProfiles.length,
      itemBuilder: (context, index) => _buildUserCard(discoveryProfiles[index]),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(25)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: user.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.white),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8)
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user.name}, ${user.age}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(user.location,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 10),
                        Text(
                          user.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.amber, size: 40),
                onPressed: () {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite,
                    color: Color(0xFFFF4D6D), size: 50),
                onPressed: () => _handleLike(user.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
