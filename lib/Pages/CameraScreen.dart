import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart'; 
import 'dart:io';

// Impor model logic dan halaman hasil
import '../utils/Classifier.dart'; 
import 'ResultScreen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();
  
  // 1. Inisialisasi Classifier
  late Classifier _classifier;
  bool _isAnalyzing = false; // State untuk loading/analisis

  @override
  void initState() {
    super.initState();
    _classifier = Classifier(); // Objek classifier dibuat
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("Tidak ada kamera yang ditemukan di perangkat ini.");
      }
      final firstCamera = cameras.first; 

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium, 
        enableAudio: false, 
      );

      _initializeControllerFuture = _controller.initialize();
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menginisialisasi kamera: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- 2. Logika Utama Klasifikasi (Dipanggil setelah ambil/pilih gambar) ---
  void _analyzeAndNavigate(File imageFile) {
    if (!mounted) return;
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // 2a. Lakukan Klasifikasi TFLite
      final result = _classifier.classifyImage(imageFile);
      
      // 2b. Navigasi ke Halaman Hasil
      // Menggunakan Get.to untuk navigasi dengan GetX
      Get.off(
        ResultScreen(
          imageFile: imageFile,
          classificationResult: result,
        ),
      );

    } catch (e) {
      Get.snackbar("Error Analisis", "Gagal memproses gambar: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // Logika pengambilan gambar (Foto dari kamera)
  Future<void> _takePicture() async {
    if (_isAnalyzing) return; // Mencegah klik ganda saat loading
    try {
      await _initializeControllerFuture;
      final XFile image = await _controller.takePicture();
      
      // Gantikan Placeholder
      _analyzeAndNavigate(File(image.path));

    } catch (e) {
      Get.snackbar("Error Kamera", "Gagal mengambil foto: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Logika pengambilan gambar dari galeri
  void _pickImageFromGallery() async {
    if (_isAnalyzing) return; // Mencegah klik ganda saat loading
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Gantikan Placeholder
      _analyzeAndNavigate(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cameraFrameSize = screenWidth - 32.0; 

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DTomato', 
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildCameraLayout(cameraFrameSize);
          } else {
            // Tampilkan loading screen sementara kamera dimuat
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildCameraLayout(double cameraFrameSize) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // --- 1. Bingkai Preview Kamera (Live Feed) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: cameraFrameSize,
              width: cameraFrameSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller), // Live Feed
              ),
            ),
          ),
          
          const SizedBox(height: 50),

          // --- 2. Kontrol Tombol ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Galeri (Kotak)
              SizedBox(
                width: 60,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _pickImageFromGallery, // Disable saat menganalisis
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: const Icon(Icons.photo_library, size: 30, color: Colors.black54),
                ),
              ),
              
              const SizedBox(width: 40),

              // Tombol Potret (Lingkaran)
              SizedBox(
                width: 80,
                height: 80,
                child: FloatingActionButton(
                  onPressed: _isAnalyzing ? null : _takePicture, // Disable saat menganalisis
                  backgroundColor: _isAnalyzing ? Colors.grey : Colors.red,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.black, width: 3.0),
                  ),
                  child: _isAnalyzing 
                      ? const CircularProgressIndicator(color: Colors.white) // Tampilkan Loading
                      : const Icon(Icons.camera, size: 40),
                ),
              ),
              
              const SizedBox(width: 40),
              
              const SizedBox(width: 60, height: 60), 
            ],
          ),
        ],
      ),
    );
  }
}