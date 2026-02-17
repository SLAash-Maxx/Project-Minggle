import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _addCloneUsers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _addCloneUsers() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    List<Map<String, dynamic>> dummyUsers = [
      {
        'uid': 'clone1',
        'name': 'Dilini',
        'age': 22,
        'profilePic':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000',
        'profileCompleted': true,
      },
      {
        'uid': 'clone2',
        'name': 'Kasun',
        'age': 25,
        'profilePic':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000',
        'profileCompleted': true,
      },
      {
        'uid': 'clone3',
        'name': 'Pooja',
        'age': 21,
        'profilePic':
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=1000',
        'profileCompleted': true,
      },
    ];

    for (var userData in dummyUsers) {
      await users.doc(userData['uid']).set(userData, SetOptions(merge: true));
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(
              color: Color(0xFFFF4D6D),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLike(String likedUserUid) async {
    if (currentUserId == "unknown") return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('liked_users')
        .doc(likedUserUid)
        .set({'likedAt': FieldValue.serverTimestamp()});

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _handleDislike() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
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
            letterSpacing: 1.2,
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
          : _selectedIndex == 1
          ? _buildLikedUsersPage()
          : const Center(
              child: Text("Coming Soon", style: TextStyle(color: Colors.white)),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFFFF4D6D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.style), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explore"),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverPage() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF4D6D)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No users found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        var users = snapshot.data!.docs
            .where((doc) => doc.id != currentUserId)
            .toList();

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: users.length,
          itemBuilder: (context, index) {
            var userData = users[index].data();
            return _buildUserCard(userData);
          },
        );
      },
    );
  }

  Widget _buildLikedUsersPage() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('liked_users')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        var likedDocs = snapshot.data!.docs;
        if (likedDocs.isEmpty) {
          return const Center(
            child: Text(
              "No likes yet!",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: likedDocs.length,
          itemBuilder: (context, index) {
            String likedUid = likedDocs[index].id;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(likedUid)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData)
                  return Container(color: Colors.grey[900]);
                var data = userSnapshot.data!.data() as Map<String, dynamic>;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(data['profilePic'] ?? ""),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      data['name'] ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData) {
    String userUid = userData['uid'] ?? "";
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: NetworkImage(
                    userData['profilePic'] ?? "https://via.placeholder.com/400",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${userData['name'] ?? 'User'}, ${userData['age'] ?? '??'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Color(0xFFFF4D6D),
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Sri Lanka",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
              GestureDetector(
                onTap: _handleDislike,
                child: _buildActionButton(Icons.close, Colors.amber, 60),
              ),
              GestureDetector(
                onTap: () => _handleLike(userUid),
                child: _buildActionButton(
                  Icons.favorite,
                  const Color(0xFFFF4D6D),
                  80,
                ),
              ),
              _buildActionButton(Icons.star, Colors.blue, 60),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
