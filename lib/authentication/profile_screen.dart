import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, String>> _allHobbies = [
    {"name": "Hiking", "emoji": "🥾"},
    {"name": "Coffee", "emoji": "☕"},
    {"name": "Photography", "emoji": "📸"},
    {"name": "Travel", "emoji": "✈️"},
    {"name": "Music", "emoji": "🎵"},
    {"name": "Food", "emoji": "🍕"},
    {"name": "Beach", "emoji": "🏖️"},
    {"name": "Gaming", "emoji": "🎮"},
    {"name": "Art", "emoji": "🎨"},
    {"name": "Reading", "emoji": "📚"},
    {"name": "Plants", "emoji": "🌿"},
    {"name": "Yoga", "emoji": "🧘"},
    {"name": "Cooking", "emoji": "🍳"},
    {"name": "Movies", "emoji": "🎬"},
    {"name": "Sports", "emoji": "🏀"},
    {"name": "Fashion", "emoji": "👗"},
  ];

  final List<String> _whatsappStatuses = const [
    "Available",
    "Busy",
    "At school",
    "At the movies",
    "At work",
    "Battery about to die",
    "Can't talk, Minggle only",
  ];

  void _showEditHobbiesDialog(
      BuildContext context, List<dynamic> currentHobbies, String userId) {
    List<String> selectedHobbies = List<String>.from(currentHobbies);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Hobbies",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(
                "${selectedHobbies.length} selected (minimum 4)",
                style: TextStyle(
                  color: selectedHobbies.length >= 4
                      ? Colors.greenAccent
                      : Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 280,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _allHobbies.length,
                  itemBuilder: (context, index) {
                    String hobbyName = _allHobbies[index]["name"]!;
                    String hobbyEmoji = _allHobbies[index]["emoji"]!;
                    bool isSelected = selectedHobbies.contains(hobbyName);
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          if (isSelected) {
                            selectedHobbies.remove(hobbyName);
                          } else {
                            selectedHobbies.add(hobbyName);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF4D6D)
                              : const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white38
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(hobbyEmoji,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                hobbyName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedHobbies.length >= 4
                      ? const Color(0xFFFF4D6D)
                      : Colors.white10,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: selectedHobbies.length >= 4
                    ? () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .update({'hobbies': selectedHobbies});
                        if (context.mounted) Navigator.pop(context);
                      }
                    : null,
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: selectedHobbies.length >= 4
                        ? Colors.white
                        : Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
              if (context.mounted) {
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

  void _showEditBioDialog(
      BuildContext context, String currentBio, String userId) {
    TextEditingController bioController =
        TextEditingController(text: currentBio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit About",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Select Default",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const Divider(color: Colors.white10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                itemCount: _whatsappStatuses.length,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_whatsappStatuses[index],
                      style: const TextStyle(color: Colors.white70)),
                  onTap: () => bioController.text = _whatsappStatuses[index],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({'bio': bioController.text});
                if (context.mounted)
                  Navigator.pop(context); // Close the sheet after saving
              },
              child: const Text("Save",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF4D6D)));
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};

          // These fetch from what user entered in Sign Up / Profile
          String name = userData['name'] ?? "User";
          String pic =
              userData['profilePic'] ?? "https://via.placeholder.com/150";
          String bio = userData['bio'] ?? "Available";
          String location = userData['location'] ?? "Sri Lanka";

          // Fetch hobbies from Firestore (Ensure they are saved as a List)
          dynamic hobbiesData = userData['hobbies'];
          List<dynamic> hobbies = (hobbiesData is List)
              ? hobbiesData
              : ['Music', 'Travel', 'Coding'];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [Color(0xFFFF4D6D), Colors.orangeAccent]),
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey[900],
                          backgroundImage: NetworkImage(pic),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () =>
                              _showEditBioDialog(context, bio, currentUserId),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Color(0xFFFF4D6D),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  location,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => _showEditBioDialog(context, bio, currentUserId),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("About Me",
                                style: TextStyle(
                                    color: Color(0xFFFF4D6D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            Icon(Icons.edit, color: Colors.white24, size: 16),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(bio,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Hobbies",
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    GestureDetector(
                      onTap: () => _showEditHobbiesDialog(
                          context, hobbies, currentUserId),
                      child: const Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white24, size: 14),
                          SizedBox(width: 4),
                          Text("Edit",
                              style:
                                  TextStyle(color: Colors.white38, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: hobbies
                        .map((h) => Chip(
                              backgroundColor:
                                  const Color(0xFFFF4D6D).withOpacity(0.15),
                              label: Text(h.toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showLogoutDialog(context), // Confirmation dialog
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Logout",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
