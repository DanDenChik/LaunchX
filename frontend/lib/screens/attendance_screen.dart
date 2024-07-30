import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AttendanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final apiService = Provider.of<ApiService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Attendance')),
      body: Center(
        child: authProvider.userType == 'student'
            ? StudentQRCode(apiService: apiService)
            : TeacherQRScanner(apiService: apiService),
      ),
    );
  }
}

class StudentQRCode extends StatelessWidget {
  final ApiService apiService;

  StudentQRCode({required this.apiService});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return FutureBuilder<String?>(
      future: apiService.getQRCode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('QR code not available. Please contact support.');
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Center(
                  child: Text(
                    'Show this QR code to your teacher to mark attendance',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                )),
                const SizedBox(height: 20),
                QrImageView(
                  data: authProvider.profile!['user']['email']!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
            ]),
          );
        }
      },
    );
  }
}

class TeacherQRScanner extends StatefulWidget {
  final ApiService apiService;

  TeacherQRScanner({required this.apiService});

  @override
  _TeacherQRScannerState createState() => _TeacherQRScannerState();
}

class _TeacherQRScannerState extends State<TeacherQRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: Text(isScanning ? 'Stop Scanning' : 'Start Scanning'),
          onPressed: () {
            setState(() {
              isScanning = !isScanning;
            });
          },
        ),
        SizedBox(height: 20),
        if (isScanning)
          Container(
            height: 300,
            width: 300,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        controller.pauseCamera();
        try {
          await widget.apiService.markAttendance(scanData.code!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Attendance marked successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to mark attendance: $e')),
          );
        }
        controller.resumeCamera();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
