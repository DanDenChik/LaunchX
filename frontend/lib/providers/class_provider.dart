import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ClassProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _classes = [];

  List<Map<String, dynamic>> get classes => _classes;

  Future<void> fetchTeacherClasses() async {
    try {
      _classes = await _apiService.getTeacherClasses();
      notifyListeners();
    } catch (e) {
      print('Fetch teacher classes error: $e');
      rethrow;
    }
  }
}
