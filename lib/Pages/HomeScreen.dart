import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CameraScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<String> _tomatoTypes = [
    'Tomat Cherry', 
    'Tomat Beefsteak', 
    'Tomat Plum', 
    'Tomat Anggur', 
    'Tomat Hijau'
  ];
  
  final List<String> _tomatoDescriptions = [
    'Kecil, bulat, dan manis. Sempurna untuk salad dan camilan karena ukurannya yang pas sekali makan.',
    'Besar, berdaging tebal, dan berair. Cocok untuk irisan sandwich, burger, dan pemanggangan.',
    'Berbentuk lonjong, padat, dan memiliki sedikit biji. Ideal untuk saus, pasta, dan pengalengan karena kandungan airnya yang rendah.',
    'Berbentuk lonjong kecil menyerupai anggur, lebih padat dari tomat cherry, dan memiliki rasa yang sangat manis.',
    'Tomat yang dipanen sebelum matang (masih mentah), memiliki rasa asam yang khas. Populer untuk digoreng atau diasamkan.',
  ];

  
  void _navigatePage(bool forward) {
    if (forward && _currentPage < _tomatoTypes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (!forward && _currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  // --- Widget yang Diperbarui: _buildTomatoCardItem ---
  Widget _buildTomatoCardItem(int index) {
    String type = _tomatoTypes[index];
    String description = _tomatoDescriptions[index];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 10),

              // Placeholder Gambar Tomat
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.white),
                ),
              ),
              
              // Deskripsi Singkat Tomat
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                maxLines: 4, 
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),

              // Tidak perlu placeholder garis lagi karena sudah ada deskripsi
            ],
          ),
        ),
      ),
    );
  }

  // _buildTopCarouselCard tidak perlu diubah secara struktural
  Widget _buildTopCarouselCard() {
    return Column(
      children: [
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _tomatoTypes.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildTomatoCardItem(index);
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: _currentPage > 0 ? () => _navigatePage(false) : null,
                color: _currentPage > 0 ? Colors.green[700] : Colors.grey,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              
              Text(
                '${_currentPage + 1} / ${_tomatoTypes.length}',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                onPressed: _currentPage < _tomatoTypes.length - 1 ? () => _navigatePage(true) : null,
                color: _currentPage < _tomatoTypes.length - 1 ? Colors.green[700] : Colors.grey,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Widget yang Dioptimalkan: _buildScanActionCard ---
  Widget _buildScanActionCard() {
    return Card(
      elevation: 2,
      color: Colors.grey[100], 
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Optimasi Teks: Gunakan Column tunggal dengan CrossAxisAlignment.start
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                const Text(
                  "Analisis",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700), // Ukuran dibuat lebih besar
                ),
                const Text(
                  "deteksi jika tomat sehat atau berpenyakit",
                  style: TextStyle(fontSize: 14, color: Colors.black54), // Dibuat sedikit redup
                ),
              ],
            ),
            
            const SizedBox(height: 16.0),

            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const CameraScreen());
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'SCAN',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DTomato',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTopCarouselCard(), 

            const SizedBox(height: 16.0),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildScanActionCard(),
            ),
          ],
        ),
      ),
    );
  }
}