import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_selection_screen.dart';
import 'chat_screen.dart';
import 'liked_screen.dart';
import 'profile_screen.dart';
import 'user_detail_screen.dart';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String imageUrl;
  final String location;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.imageUrl,
    required this.location,
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
      id: 'user_1',
      name: 'Hasini',
      age: 24,
      bio: 'Coffee lover ☕ | Dog mom 🐶',
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      location: 'Colombo, LK',
    ),
    UserProfile(
      id: 'user_2',
      name: 'Shehan',
      age: 27,
      bio: 'Music producer 🎵 | Foodie',
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      location: 'Negombo, LK',
    ),
    UserProfile(
      id: 'user_3',
      name: 'Malshi',
      age: 22,
      bio: 'Yoga instructor 🧘‍♀️ | Nature lover 🌿',
      imageUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
      location: 'Kandy, LK',
    ),
    UserProfile(
      id: 'user_4',
      name: 'Ashan',
      age: 25,
      bio: 'Tech enthusiast 💻 | Gym freak 💪',
      imageUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
      location: 'Galle, LK',
    ),
    UserProfile(
      id: 'user_5',
      name: 'Ishara',
      age: 23,
      bio: 'Art student 🎨 | Travel enthusiast ✈️',
      imageUrl: 'https://randomuser.me/api/portraits/women/26.jpg',
      location: 'Matara, LK',
    ),
    UserProfile(
      id: 'user_6',
      name: 'Maneesha',
      age: 21,
      bio: 'Bookworm 📚 | Amateur photographer 📸',
      imageUrl: 'https://randomuser.me/api/portraits/women/17.jpg',
      location: 'Kurunegala, LK',
    ),
    UserProfile(
      id: 'user_7',
      name: 'Kasun',
      age: 26,
      bio: 'Software Engineer 🛠️ | Basketball player 🏀',
      imageUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
      location: 'Anuradhapura, LK',
    ),
  ];

  Future<void> _handleLike(UserProfile user) async {
    if (currentUserId == "unknown") return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('liked_users')
        .doc(user.id)
        .set({'likedAt': FieldValue.serverTimestamp()});

    await FirebaseFirestore.instance.collection('users').doc(user.id).set({
      'uid': user.id,
      'name': user.name,
      'profilePic': user.imageUrl,
      'bio': user.bio,
    }, SetOptions(merge: true));

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
        content: const Text("Are you sure you want to logout?",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const LoginSelectionScreen()),
                  (route) => false,
                );
              }
            },
            child:
                const Text("Yes", style: TextStyle(color: Color(0xFFFF4D6D))),
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
        title: const Text("Minggle",
            style: TextStyle(
                color: Color(0xFFFF4D6D),
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _showLogoutDialog)
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDiscoverPage(),
          const LikedScreen(),
          const ChatScreen(),
          const ProfileScreen(),
        ],
      ),
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
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailScreen(user: user),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                        imageUrl: user.imageUrl, fit: BoxFit.cover),
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
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${user.name}, ${user.age}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          Text(user.location,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: const Icon(Icons.close, color: Colors.amber, size: 40),
                  onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut)),
              IconButton(
                  icon: const Icon(Icons.favorite,
                      color: Color(0xFFFF4D6D), size: 50),
                  onPressed: () => _handleLike(user)),
            ],
          )
        ],
      ),
    );
  }
}
