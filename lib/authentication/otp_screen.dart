import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'profile_picture_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String? userName;
  final String? birthday;
  final String? gender;
  final List<String>? selectedHobbies;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.userName,
    this.birthday,
    this.gender,
    this.selectedHobbies,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _start = 59;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _start = 59;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer?.cancel();
          _canResend = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> _verifyOTP() async {
    String otp = _controllers.map((e) => e.text).join();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full 6-digit code.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    debugPrint("DEBUG: Verification started...");

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      debugPrint("DEBUG: Signing in with credential...");
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      User? user = userCredential.user;
      debugPrint("DEBUG: User signed in: ${user?.uid}");

      if (user != null && mounted) {
        debugPrint("DEBUG: Attempting to save to Firestore...");

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'phoneNumber': widget.phoneNumber,
                'name': widget.userName ?? "New User",
                'birthday': widget.birthday ?? "",
                'gender': widget.gender ?? "",
                'hobbies': widget.selectedHobbies ?? [],
                'profileCompleted': false,
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true))
              .timeout(const Duration(seconds: 10));

          debugPrint("DEBUG: Firestore save successful");
        } catch (firestoreError) {
          debugPrint(
            "DEBUG: Firestore Error (Likely Rules or Database ID): $firestoreError",
          );
        }

        if (mounted) {
          setState(() => _isLoading = false);
          debugPrint("DEBUG: Navigating to ProfilePictureScreen");

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfilePictureScreen(),
            ),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      debugPrint("DEBUG: Auth Exception: ${e.message}");
      String errorMessage = "Invalid OTP. Please try again.";
      if (e.code == 'invalid-verification-code') {
        errorMessage = "The code you entered is incorrect.";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("DEBUG: General Exception: $e");

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePictureScreen()),
          (route) => false,
        );
      }
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _handleKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Verify Code",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter the 6-digit code we sent to\n${widget.phoneNumber}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) => _handleKeyEvent(event, index),
                  child: SizedBox(
                    width: 52,
                    height: 65,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFFF4D6D),
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF333333),
                      ),
                      onChanged: (value) => _onChanged(value, index),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: _canResend ? () => _startTimer() : null,
                child: Text(
                  _canResend
                      ? "Didn't receive code? Resend"
                      : "Resend code in 0:${_start.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: _canResend ? const Color(0xFFFF4D6D) : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Spacer(),

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
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Verify & Finish",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
