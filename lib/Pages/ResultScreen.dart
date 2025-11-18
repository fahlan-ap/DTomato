import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final Map<String, dynamic> classificationResult;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.classificationResult,
  });

  @override
  Widget build(BuildContext context) {
    final String result = classificationResult['result'] as String;
    final List<double> allScores = classificationResult['all_scores'] as List<double>;
    final List<String> labels = classificationResult['labels'] as List<String>;

    final bool isHealthy = result.contains('Sehat');
    final String keterangan = isHealthy
        ? "Tanaman Tomat Anda dalam keadaan SEHAT"
        : "Tanamat Tomat anda terjangkit LATE BLIGHT";
    final Color resultColor = isHealthy ? Colors.green : Colors.red;
    
    String cleanLabel(String label) {
        return label.replaceFirst(RegExp(r'^\d\s'), ''); 
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        backgroundColor: Color(0xFFffffff),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            
            // 1. Preview Gambar (Sesuai Wireframe)
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 2. Kontainer Hasil Persentase
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Persentase Analisis:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  
                  // Tampilkan Persentase untuk setiap kelas
                  ...List.generate(labels.length, (index) {
                    final label = cleanLabel(labels[index]);
                    final score = allScores[index];
                    final percent = (score * 100).toStringAsFixed(2);
                    final isMaxScore = (result == labels[index]);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$label:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isMaxScore ? FontWeight.bold : FontWeight.normal,
                              color: isMaxScore ? resultColor : Colors.black87,
                            ),
                          ),
                          Text(
                            '$percent %',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isMaxScore ? resultColor : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 3. Teks Keterangan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: resultColor),
              ),
              child: Text(
                keterangan,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: resultColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}