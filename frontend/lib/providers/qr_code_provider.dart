import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

class QRCodeProvider with ChangeNotifier {
  String? _qrCodePath;

  String? get qrCodePath => _qrCodePath;

  Future<void> generateAndSaveQRCode(String userId) async {
    final qrPainter = QrPainter(
      data: userId,
      version: QrVersions.auto,
    );

    const paintSize = Size(200, 200);
    final imageBuffer = await qrPainter.toImageData(
        paintSize.width.toInt() as double,
        format: ui.ImageByteFormat.png);
    final pngBytes = imageBuffer!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/qr_code.png');
    await file.writeAsBytes(pngBytes);

    _qrCodePath = file.path;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qr_code_path', _qrCodePath!);

    notifyListeners();
  }

  Future<void> loadQRCode() async {
    final prefs = await SharedPreferences.getInstance();
    _qrCodePath = prefs.getString('qr_code_path');
    notifyListeners();
  }
}
