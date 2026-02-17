import 'package:flutter/material.dart';

class HobbiesScreen extends StatefulWidget {
  const HobbiesScreen({super.key});

  @override
  State<HobbiesScreen> createState() => _HobbiesScreenState();
}

class _HobbiesScreenState extends State<HobbiesScreen> {
  // List of 12 hobbies
  final List<String> _hobbies = [
    "Music",
    "Travel",
    "Cooking",
    "Gaming",
    "Sports",
    "Reading",
    "Dancing",
    "Movies",
    "Art",
    "Photography",
    "Fashion",
    "Pets",
  ];

  final List<String> _selectedHobbies = [];

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else {
        if (_selectedHobbies.length < 4) {
          _selectedHobbies.add(hobby);
        } else {
          // You can change this to allow more, but you asked for 4
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can select up to 4 hobbies.")),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your hobbies",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Select at least 4 hobbies (${_selectedHobbies.length}/4)",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Grid of hobbies
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _hobbies.length,
                itemBuilder: (context, index) {
                  String hobby = _hobbies[index];
                  bool isSelected = _selectedHobbies.contains(hobby);
                  return GestureDetector(
                    onTap: () => _toggleHobby(hobby),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF4D6D)
                            : const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          hobby,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D6D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _selectedHobbies.length == 4
                    ? () {
                        // Navigate to Region selection screen
                      }
                    : null, // Disable button if not exactly 4 selected
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
