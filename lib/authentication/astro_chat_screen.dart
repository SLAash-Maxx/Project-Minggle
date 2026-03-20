import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AstroChatScreen extends StatefulWidget {
  const AstroChatScreen({super.key});

  @override
  State<AstroChatScreen> createState() => _AstroChatScreenState();
}

class _AstroChatScreenState extends State<AstroChatScreen> {
  final String apiKey = "AIzaSyDAOLwRLla_ofoTxJ5BN5vWkJixyqlMvkU";

  DateTime girlDate = DateTime(2000, 1, 1, 10, 30);
  DateTime boyDate = DateTime(1998, 5, 15, 14, 20);

  bool _isLoading = false;
  String? _aiResponse;

  Future<void> _pickDateTime(bool isGirl) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isGirl ? girlDate : boyDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isGirl ? girlDate : boyDate),
      );

      if (pickedTime != null) {
        setState(() {
          DateTime finalDate = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
          if (isGirl) {
            girlDate = finalDate;
          } else {
            boyDate = finalDate;
          }
        });
      }
    }
  }

  Future<void> _checkCompatibility() async {
    setState(() {
      _isLoading = true;
      _aiResponse = null;
    });

    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$apiKey";

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Vedic Astrology matching for Minggle dating app. Girl: ${girlDate.toString()}, Boy: ${boyDate.toString()}. Give a compatibility score out of 10 and 3 brief points about their matching status in simple English."
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        });
      } else {
        setState(() {
          _aiResponse =
              "Error ${response.statusCode}: ${data['error']?['message'] ?? 'Unknown Error'}";
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = "Connection failed: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text("Minggle Astro Matching",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF4D6D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputCard("Girl's Birth Details", girlDate, true),
            _buildInputCard("Boy's Birth Details", boyDate, false),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _isLoading ? null : _checkCompatibility,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Check Compatibility",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
            ),
            if (_aiResponse != null) _buildAiResult(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(String title, DateTime date, bool isGirl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFFFF4D6D), fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _pickDateTime(isGirl),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat("yyyy-MM-dd  |  HH:mm").format(date),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                  const Icon(Icons.calendar_month, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiResult() {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              const Text("Astro Insight",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Text(
            _aiResponse!,
            style:
                const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }
}
