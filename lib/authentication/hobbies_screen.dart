import 'package:flutter/material.dart';
import 'region_screen.dart';

class HobbiesScreen extends StatefulWidget {
  final String gender;
  final String interest;

  const HobbiesScreen({
    super.key,
    required this.gender,
    required this.interest,
  });

  @override
  State<HobbiesScreen> createState() => _HobbiesScreenState();
}

class _HobbiesScreenState extends State<HobbiesScreen> {
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
        _selectedHobbies.add(hobby);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canProceed = _selectedHobbies.length >= 4;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
              "Select at least 4 hobbies (${_selectedHobbies.length} selected)",
              style: TextStyle(
                color: canProceed ? Colors.greenAccent : Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
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
                        border: Border.all(
                          color: isSelected
                              ? Colors.white38
                              : Colors.transparent,
                        ),
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D6D),
                  disabledBackgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: canProceed
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegionScreen(
                              gender: widget.gender,
                              interest: widget.interest,
                              hobbies: List.from(_selectedHobbies),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: canProceed ? Colors.white : Colors.white38,
                  ),
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
