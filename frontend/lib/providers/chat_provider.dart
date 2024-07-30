import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _existingChats = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _messages = [];
  String? _selectedUserId;

  String? _selectedUserAvatarUrl; 
  String? _selectedUserName;

  String? get selectedUserAvatarUrl => _selectedUserAvatarUrl; 
  String? get selectedUserName => _selectedUserName;

  List<Map<String, dynamic>> get existingChats => _existingChats;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  List<Map<String, dynamic>> get messages => _messages;
  String? get selectedUserId => _selectedUserId;

  Future<void> fetchExistingChats() async {
    try {
      _existingChats = await _apiService.getExistingChats();
      notifyListeners();
    } catch (e) {
      print('Error fetching existing chats: $e');
    }
  }

  Future<void> searchUsers(String query) async {
    try {
      _searchResults = await _apiService.searchUsers(query);
      notifyListeners();
    } catch (e) {
      print('Error searching users: $e');
    }
  }

  void clearSearch() {
    _searchResults.clear();
    notifyListeners();
  }

  Future<void> fetchMessages() async {
    try {
      _messages = await _apiService.getMessages(userId: _selectedUserId);
      notifyListeners();
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage(String content) async {
    if (_selectedUserId == null) return;
    try {
      await _apiService.sendMessage(content, _selectedUserId!);
      await fetchMessages();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void selectUser(String userId, String userName, String userAvatarUrl) {
    _selectedUserId = userId;
    _selectedUserName = userName;
    _selectedUserAvatarUrl = userAvatarUrl;
    fetchMessages();
  }
}