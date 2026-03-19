import 'package:flutter/material.dart';
import 'hobbies_screen.dart';

class InterestScreen extends StatefulWidget {
  final String gender;
  const InterestScreen({super.key, required this.gender});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  String? _selectedInterest;

  @override
  Widget build(BuildContext context) {
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
              "Who are you interested in?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildOption("Female", "👩"),
            const SizedBox(height: 15),
            _buildOption("Male", "👨"),
            const SizedBox(height: 15),
            _buildOption("Both", "🌈"),
            const Spacer(),
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
                onPressed: _selectedInterest != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HobbiesScreen(
                              gender: widget.gender,
                              interest: _selectedInterest!.toLowerCase(),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 18,
                    color: _selectedInterest != null
                        ? Colors.white
                        : Colors.white38,
                    fontWeight: FontWeight.bold,
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

  Widget _buildOption(String interest, String emoji) {
    bool isSelected = _selectedInterest == interest;
    return GestureDetector(
      onTap: () => setState(() => _selectedInterest = interest),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4D6D) : const Color(0xFF333333),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.white38 : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 15),
            Text(
              interest,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
