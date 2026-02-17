import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  const OTPVerificationScreen({super.key, required this.verificationId});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to verify the OTP code entered by the user
  void _verifyOTP() async {
    String smsCode = _otpController.text.trim();

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );

    try {
      // Sign the user in with the credential
      await _auth.signInWithCredential(credential);

      // If successful, navigate to the Home Screen
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login Successful!")));
        // Navigator.pushReplacementNamed(context, '/home'); // Uncomment when Home is ready
      }
    } catch (e) {
      // Handle incorrect OTP or other errors
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Invalid OTP: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Enter the 6-digit code sent to your phone"),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "OTP Code"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text("Verify & Login"),
            ),
          ],
        ),
      ),
    );
  }
}
