import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Scan Kamera'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Aplikasi Kamera Akan Dimuat di Sini',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}