import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoggedIn = false;
  String? _userType;
  String? _userId;
  String? _userEmail;

  String? get userEmail => _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get userType => _userType;
  String? get userId => _userId;

  Future<void> initializeAuth() async {
    await checkLoginStatus();
    notifyListeners();
  }

  Map<String, dynamic>? _profile;

  Map<String, dynamic>? get profile => _profile;

  Future<void> fetchProfile() async {
    try {
      if (_userType == 'student') {
        _profile = await _apiService.getStudentProfile();
      } else if (_userType == 'teacher') {
        _profile = await _apiService.getTeacherProfile();
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final tokens = await _apiService.login(username, password);
      await _apiService.setToken(tokens['access']);
      _isLoggedIn = true;
      await _fetchUserDetails();
      notifyListeners();
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userDetails = await _apiService.getUserDetails();
      _userType = userDetails['user_type'];
      _userId = userDetails['id'].toString();
    } catch (e) {
      print('Error fetching user details: $e');
      rethrow;
    }
  }

  Future<void> register(String fullName, String username, String password,
      String passwordConfirmation, String email, String userType) async {
    try {
      await _apiService.register(
          fullName, username, password, passwordConfirmation, email, userType);
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      print("Checking login status...");
      final token = await _apiService.getToken();
      print("Token retrieved: $token");
      _isLoggedIn = token != null && token.isNotEmpty;
      if (_isLoggedIn) {
        await _fetchUserDetails();
      }
      print("Is logged in: $_isLoggedIn");
      notifyListeners();
    } catch (e) {
      print("Error checking login status: $e");
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<void> updateAvatar(File imageFile) async {
    try {
      final updatedProfile = await _apiService.updateAvatar(imageFile);
      _profile = updatedProfile;
      notifyListeners();
    } catch (e) {
      print('Error updating avatar: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    print("Logging out...");
    await _apiService.clearToken();
    _isLoggedIn = false;
    _userType = null;
    _userId = null;
    print("Logged out. Is logged in: $_isLoggedIn");
    notifyListeners();
  }
}
