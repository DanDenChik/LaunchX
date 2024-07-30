import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class GoalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _personalGoals = [];
  List<Map<String, dynamic>> _classGoals = [];
  List<Map<String, dynamic>> _goalStudents = [];

  List<Map<String, dynamic>> get goalStudents => _goalStudents;
  List<Map<String, dynamic>> get personalGoals => _personalGoals;
  List<Map<String, dynamic>> get classGoals => _classGoals;

  Future<void> fetchStudentGoals() async {
    try {
      final response = await _apiService.getStudentGoals();
      _personalGoals =
          List<Map<String, dynamic>>.from(response['personal_goals']);
      _classGoals = List<Map<String, dynamic>>.from(response['class_goals']);
      notifyListeners();
    } catch (e) {
      print('Fetch student goals error: $e');
      rethrow;
    }
  }

  Future<void> fetchGoalStudents(String goalId) async {
    try {
      _goalStudents = await _apiService.getGoalStudents(goalId);
      notifyListeners();
    } catch (e) {
      print('Fetch goal students error: $e');
      rethrow;
    }
  }

  Future<void> fetchTeacherClassGoals(String classId) async {
    try {
      _classGoals = await _apiService.getTeacherClassGoals(classId);
      notifyListeners();
    } catch (e) {
      print('Fetch teacher class goals error: $e');
      rethrow;
    }
  }

  Future<void> addPersonalGoal(Map<String, dynamic> goal) async {
    try {
      await _apiService.addPersonalGoal(goal);
      await fetchStudentGoals();
    } catch (e) {
      print('Add personal goal error: $e');
      rethrow;
    }
  }

  Future<void> addClassGoal(String classId, Map<String, dynamic> goal) async {
    try {
      await _apiService.addClassGoal(classId, goal);
      await fetchTeacherClassGoals(classId);
    } catch (e) {
      print('Add class goal error: $e');
      rethrow;
    }
  }

  Future<void> updateGoal(String goalId, Map<String, dynamic> goalData, {required bool isPersonal}) async {
    try {
      await _apiService.updateGoal(goalId, goalData);
      if (isPersonal) {
        await fetchStudentGoals();
      } else {
        final updatedGoals = _classGoals.map((goal) {
          if (goal['id'].toString() == goalId) {
            return {...goal, ...goalData};
          }
          return goal;
        }).toList();
        _classGoals = updatedGoals;
        notifyListeners();
      }
    } catch (e) {
      print('Update goal error: $e');
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId, {required bool isPersonal}) async {
    try {
      await _apiService.deleteGoal(goalId);
      if (isPersonal) {
        _personalGoals.removeWhere((goal) => goal['id'].toString() == goalId);
      } else {
        _classGoals.removeWhere((goal) => goal['id'].toString() == goalId);
      }
      notifyListeners();
    } catch (e) {
      print('Delete goal error: $e');
      rethrow;
    }
  }
}
