import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = 'https://dandenchik.pythonanywhere.com/api/';
  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    String? token = await storage.read(key: 'access_token');
    print("Retrieved token: $token");
    return token;
  }

  Future<void> setToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  Future<void> clearToken() async {
    print("Clearing token...");
    await storage.delete(key: 'access_token');
    print("Token cleared");
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/get-user/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<Map<String, dynamic>> register(
      String fullName,
      String username,
      String password,
      String passwordConfirmation,
      String email,
      String userType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName,
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'user_type': userType,
      }),
    );

    if (response.statusCode == 201) {
      final userData = json.decode(response.body);
      return userData;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<String?> getQRCode() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/get-qr-code/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['qr_code'];
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to get QR code');
    }
  }

  Future<String> generateQRCode() async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/generate-qr-code/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['qr_code'];
    } else {
      throw Exception('Failed to generate QR code');
    }
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/teacher/classes/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load classes');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['error'] ?? 'Failed to send password reset email');
      }
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<void> scanQRCode(String email) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/scan-qr-code/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to scan QR code');
    }
  }

  Future<void> markAttendance(String email) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/mark-attendance/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark attendance');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<Map<String, dynamic>>> getMessages({String? userId}) async {
    final token = await getToken();
    final url =
        userId != null ? '$baseUrl/chat/?user_id=$userId' : '$baseUrl/chat/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> sendMessage(String content, String receiverId) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/chat/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'content': content,
        'receiver': receiverId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  Future<List<Map<String, dynamic>>> getExistingChats() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/existing-chats/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load existing chats');
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/search-users/?search=$query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to search users');
    }
  }

  Future<Map<String, dynamic>> getStudentGoals() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/student/goals/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load student goals');
    }
  }

  Future<List<Map<String, dynamic>>> getTeacherClassGoals(
      String classId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/teacher/class/$classId/goals/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load teacher class goals');
    }
  }

  Future<void> addPersonalGoal(Map<String, dynamic> goalData) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/student/personal-goal/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(goalData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add personal goal');
    }
  }

  Future<void> addClassGoal(
      String classId, Map<String, dynamic> goalData) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/teacher/class/$classId/goals/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(goalData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add class goal');
    }
  }

  Future<void> updateGoal(String goalId, Map<String, dynamic> goalData) async {
    final token = await getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/goals/$goalId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(goalData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update goal');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/goals/$goalId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete goal');
    }
  }

  Future<List<Map<String, dynamic>>> getGoalStudents(String goalId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/goals/$goalId/students/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get goal students');
    }
  }

  Future<Map<String, dynamic>> getStudentProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/student/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get student profile');
    }
  }

  Future<Map<String, dynamic>> getTeacherProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/teacher/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get teacher profile');
    }
  }

  Future<List<Map<String, dynamic>>> getTeacherClasses() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/teacher/classes/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get teacher classes');
    }
  }

  Future<Map<String, dynamic>> updateAvatar(File imageFile) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/update_avatar/');

    var request = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('avatar', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      throw Exception('Failed to update avatar: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentStreaks() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/student-streak-list/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load student streaks');
    }
  }

  Future<void> breakStudentStreak(String studentId) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/break-student-streak/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'student_id': studentId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to break student streak');
    }
  }

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();
}
