import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AttendanceProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Map<String, dynamic>> _studentStreaks = [];

  AttendanceProvider(this._apiService);

  List<Map<String, dynamic>> get studentStreaks => _studentStreaks;

  Future<void> refreshStudentStreaks() async {
    try {
      _studentStreaks = await _apiService.getStudentStreaks();
      notifyListeners();
    } catch (e) {
      print('Error refreshing student streaks: $e');
    }
  }

  Future<void> breakStudentStreak(String studentId) async {
    try {
      await _apiService.breakStudentStreak(studentId);
      await refreshStudentStreaks();
    } catch (e) {
      print('Error breaking student streak: $e');
    }
  }
}