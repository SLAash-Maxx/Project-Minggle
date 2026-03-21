import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'home_screen.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,
      enableLandmarks: false,
      enableContours: false,
      minFaceSize: 0.2,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller =
        CameraController(front, ResolutionPreset.medium, enableAudio: false);

    try {
      await _controller!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _verifyAndGo() async {
    if (!_isCameraInitialized || _controller == null) return;

    setState(() => _isProcessing = true);

    try {
      final XFile imageFile = await _controller!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      final List<Face> faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        _showResultDialog(
            'Face not detected', 'No face found. Please try again.');
      } else if (faces.length > 1) {
        _showResultDialog('Multiple faces detected',
            'Please ensure only your face is in the frame.');
      } else {
        final Face face = faces.first;
        final double? smileProb = face.smilingProbability;
        final bool isGoodMatch = smileProb != null ? smileProb > 0.2 : true;

        if (isGoodMatch) {
          _showResultDialog('Verified', 'Face verification successful',
              onOk: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          });
        } else {
          _showResultDialog('Not confident',
              'Please smile and try again for better verification.');
        }
      }
    } catch (e) {
      _showResultDialog('Error', 'Face verification failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  void _showResultDialog(String title, String message,
      {void Function()? onOk}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFFFF4D6D))),
          )
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text("Skip Verification",
                style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Face Verification",
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "Position your face in the center and click Verify.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF4D6D), width: 4),
                ),
                child: ClipOval(
                  child: _isCameraInitialized
                      ? AspectRatio(
                          aspectRatio: 1,
                          child: CameraPreview(_controller!),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFF4D6D))),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _isProcessing ? null : _verifyAndGo,
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify Now",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
