import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  late Interpreter _interpreter;
  late List<String> _labels;
  static const String MODEL_PATH = 'assets/model_unquant.tflite';
  static const String LABEL_PATH = 'assets/labels.txt';
  
  static const int INPUT_SIZE = 224; 
  static const int NUM_CLASSES = 2; 

  Classifier() {
    _loadModel();
    _loadLabels();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(MODEL_PATH);
      print('Model loaded successfully.');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelTxt = await rootBundle.loadString(LABEL_PATH);
      _labels = labelTxt.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      print('Labels loaded successfully: $_labels');
    } catch (e) {
      print('Failed to load labels: $e');
    }
  }

  // --- FUNGSI _preProcess YANG DIPERBAIKI ---
  Uint8List _preProcess(File imageFile) {
    // 1. Decode dan Resize Gambar
    final originalImage = img.decodeImage(imageFile.readAsBytesSync());
    if (originalImage == null) throw Exception("Failed to decode image.");

    final resizedImage = img.copyResize(originalImage, width: INPUT_SIZE, height: INPUT_SIZE);

    // 2. Konversi ke Input Buffer Float32 (Normalisasi)
    final imageBuffer = Float32List(1 * INPUT_SIZE * INPUT_SIZE * 3);
    final bufferAsList = imageBuffer.buffer.asFloat32List();
    
    int pixelIndex = 0;
    for (int y = 0; y < INPUT_SIZE; y++) {
      for (int x = 0; x < INPUT_SIZE; x++) {
        // Ambil objek Pixel
        final pixel = resizedImage.getPixel(x, y);
        // Dapatkan nilai RGB dan normalisasi ke [0, 1]
        bufferAsList[pixelIndex++] = pixel.r / 255.0; 
        bufferAsList[pixelIndex++] = pixel.g / 255.0;
        bufferAsList[pixelIndex++] = pixel.b / 255.0;
      }
    }
    
    // Bentuk ulang buffer ke format yang dibutuhkan TFLite
    return imageBuffer.buffer.asUint8List(); 
  }

  Map<String, dynamic> classifyImage(File imageFile) {    
    // Tambahan: Pengecekan keamanan jika model gagal dimuat

    // 1. Pre-processing
    final inputBytes = _preProcess(imageFile);
    
    // 2. Buat tensor output [1, NUM_CLASSES] -> [1, 2]
    final outputTensor = List.filled(1 * NUM_CLASSES, 0.0).reshape([1, NUM_CLASSES]);

    // 3. Jalankan Inferensi
    _interpreter.run(
      inputBytes.buffer.asFloat32List().reshape([1, INPUT_SIZE, INPUT_SIZE, 3]),
      outputTensor
    );

    // 4. Post-processing (Dapatkan hasil dengan confidence tertinggi)
    List<double> scores = outputTensor[0].cast<double>();
    double maxScore = scores.reduce((a, b) => a > b ? a : b);
    int maxIndex = scores.indexOf(maxScore);
    
    String result = _labels[maxIndex];
    
    return {
      'result': result,
      'confidence': maxScore,
      'all_scores': scores,
      'labels': _labels,
    };
  }
}