// lib/production/presentation/study/presentation/pages/study_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({Key? key}) : super(key: key);

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  Timer? _timer;
  Timer? _aiAnalysisTimer;
  int _elapsedSeconds = 0;
  int _focusedSeconds = 0;
  bool _isStudyActive = false;

  String? _pdfPath;
  PdfViewerController? _pdfViewerController;

  final List<String> _infoBubbles = [
    "Bu PDF'deki anahtar kelimelerden biri 'yapay zeka' gibi görünüyor. Daha fazlasını öğrenmek ister misin?",
    "Sayfanın bu bölümünde 'makine öğrenimi' kavramı açıklanıyor. Önemli bir tanım!",
    "Derin öğrenme, yapay sinir ağları ile ilgilidir. Bu konuya odaklanmak sana fayda sağlayabilir.",
    "Bu paragraf 'büyük veri'nin önemini vurguluyor. Veri bilimi için kritik bir unsur.",
    "Okuduğun bölümde YZ'nin hangi alanlarda kullanıldığına dair ipuçları var. Tekrar göz atmalısın.",
  ];
  int _infoBubbleIndex = 0;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _aiAnalysisTimer?.cancel();
    _pdfViewerController?.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdfPath = result.files.single.path;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF seçimi iptal edildi.')),
      );
    }
  }

  void _startStudy() {
    if (_pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce bir PDF dosyası seçin.')),
      );
      return;
    }

    // Kamera izin isteme simülasyonu
    _showCameraPermissionSimulation();

    setState(() {
      _isStudyActive = true;
      _elapsedSeconds = 0;
      _focusedSeconds = 0;
      _infoBubbleIndex = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        // Daha dinamik odaklanma simülasyonu: %85 odaklanma oranı
        if (_elapsedSeconds % 10 != 0 || _elapsedSeconds % 10 == 9) { // Örneğin her 10 saniyede 1 saniye odaklanmayı bırakmış gibi
          _focusedSeconds++;
        }
      });
    });

    _aiAnalysisTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_isStudyActive) {
        _showInfoBubble();
      }
    });
  }

  void _endStudy() {
    _timer?.cancel();
    _aiAnalysisTimer?.cancel();
    setState(() {
      _isStudyActive = false;
    });
    _showStudyReport();
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _showInfoBubble() {
    if (_infoBubbles.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_infoBubbles[_infoBubbleIndex]),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.blueAccent.withAlpha((255 * 0.8).round()),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    _infoBubbleIndex = (_infoBubbleIndex + 1) % _infoBubbles.length;
  }

  // Kamera izin isteme simülasyonu metodu
  void _showCameraPermissionSimulation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.white),
            SizedBox(width: 10),
            Text('Kamera izni isteniyor... Lütfen izin verin.'),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green.withAlpha((255 * 0.9).round()),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showStudyReport() {
    double focusPercentage = _elapsedSeconds > 0
        ? (_focusedSeconds / _elapsedSeconds) * 100
        : 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Etüt Özeti'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Toplam Çalışma Süresi: ${_formatDuration(_elapsedSeconds)}'),
              Text('Odaklanma Süresi (Simüle): ${_formatDuration(_focusedSeconds)}'),
              Text('Odaklanma Oranı: ${focusPercentage.toStringAsFixed(1)}%'),
              const Text('Takıldığı Sayfalar: Henüz Geliştirilmedi'),
              const Text('Genel Verimlilik Skoru: Henüz Geliştirilmedi'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isStudyActive ? 'Etüt Devam Ediyor' : 'Etüt Başlat'),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_isStudyActive) // Etüt aktifken göster
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCameraPreviewPlaceholder(), // Sağ üstte kamera yer tutucusu
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_isStudyActive && _pdfPath == null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: _pickPdfFile,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('PDF Seç', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),

          if (_pdfPath != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfPdfViewer.file(
                  File(_pdfPath!),
                  controller: _pdfViewerController,
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: _isStudyActive
                    ? const CircularProgressIndicator()
                    : const Text(
                  'Çalışmak için bir PDF seçin.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Text(
                  'Etüt Süresi: ${_formatDuration(_elapsedSeconds)}',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                Text(
                  'Odaklanma (Simüle): ${_formatDuration(_focusedSeconds)}',
                  style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_isStudyActive) {
                      _endStudy();
                    } else {
                      _startStudy();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isStudyActive ? Colors.redAccent : Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 25),
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _isStudyActive ? 'Etütü Bitir' : 'Etüt Başlat',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kamera Önizlemesi Yer Tutucu Widget'ı
  Widget _buildCameraPreviewPlaceholder() {
    return Container(
      width: 70, // Küçük bir kare
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, color: Colors.white, size: 30),
            Text(
              'CANLI',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}