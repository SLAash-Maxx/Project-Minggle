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
        'uid': 'clone_b1',
        'name': 'Kasun',
        'age': 25,
        'gender': 'male',
        'profilePic':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000',
        'profileCompleted': true,
      },
      {
        'uid': 'clone_b2',
        'name': 'Nuwan',
        'age': 23,
        'gender': 'male',
        'profilePic':
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000',
        'profileCompleted': true,
      },
      {
        'uid': 'clone_b3',
        'name': 'Sahan',
        'age': 24,
        'gender': 'male',
        'profilePic':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000',
        'profileCompleted': true,
      },
      {
        'uid': 'clone_g1',
        'name': 'Dilini',
        'age': 22,
        'gender': 'female',
        'profilePic':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000',
        'profileCompleted': true,
      },
      {
        'uid': 'clone_g2',
        'name': 'Pooja',
        'age': 21,
        'gender': 'female',
        'profilePic':
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=1000',
        'profileCompleted': true,
      },
      {
        'uid': 'clone_g3',
        'name': 'Ishani',
        'age': 24,
        'gender': 'female',
        'profilePic':
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=1000',
        'profileCompleted': true,
      },
      {
        'uid': 'clone_g4',
        'name': 'Kavindi',
        'age': 20,
        'gender': 'female',
        'profilePic':
            'https://images.unsplash.com/photo-1531123897727-8f129e16fd06?q=80&w=1000',
        'profileCompleted': true,
      },
    ];
    for (var userData in dummyUsers) {
      await users.doc(userData['uid']).set(userData, SetOptions(merge: true));
    }
  }

  Future<void> _handleLike(String likedUserUid) async {
    if (currentUserId == "unknown") return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('liked_users')
        .doc(likedUserUid)
        .set({'likedAt': FieldValue.serverTimestamp()});
    var matchCheck = await FirebaseFirestore.instance
        .collection('users')
        .doc(likedUserUid)
        .collection('liked_users')
        .doc(currentUserId)
        .get();
    if (matchCheck.exists) _showMatchDialog();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleUnlike(String likedUserUid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('liked_users')
        .doc(likedUserUid)
        .delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Removed from likes")));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Logout", style: TextStyle(color: Color(0xFFFF4D6D))),
        content: const Text(
          "Are you sure?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
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

  void _showMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("❤️", style: TextStyle(fontSize: 50)),
            const Text(
              "It's a Match!",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Continue"),
            ),
          ],
        ),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.style), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Liked"),
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get(),
      builder: (context, userSnapshot) {
        String interest = "both";
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          var userData = userSnapshot.data!.data() as Map<String, dynamic>;
          interest = userData['interest'] ?? "both";
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('liked_users')
              .snapshots(),
          builder: (context, likedSnapshot) {
            if (!likedSnapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            // Collect IDs of already liked users
            List<String> alreadyLikedUids = likedSnapshot.data!.docs
                .map((doc) => doc.id)
                .toList();

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );

                var users = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  bool isNotMe = doc.id != currentUserId;
                  bool isNotLiked = !alreadyLikedUids.contains(
                    doc.id,
                  ); // Filter out already liked users
                  bool matchesInterest =
                      interest == "both" ||
                      (interest == "girls" && data['gender'] == "female") ||
                      (interest == "boys" && data['gender'] == "male");
                  return isNotMe && isNotLiked && matchesInterest;
                }).toList();

                if (users.isEmpty)
                  return const Center(
                    child: Text(
                      "No more new people!",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );

                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: users.length,
                  itemBuilder: (context, index) => _buildUserCard(
                    users[index].data() as Map<String, dynamic>,
                  ),
                );
              },
            );
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
        if (likedDocs.isEmpty)
          return const Center(
            child: Text(
              "No likes yet!",
              style: TextStyle(color: Colors.white70),
            ),
          );

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
                return GestureDetector(
                  onLongPress: () => _handleUnlike(likedUid),
                  child: Container(
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: NetworkImage(userData['profilePic'] ?? ""),
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
                        const Text(
                          "Sri Lanka",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
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
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Color(0xFFFF4D6D),
                  size: 50,
                ),
                onPressed: () => _handleLike(userData['uid']),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
