import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchExistingChats();
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    Provider.of<ChatProvider>(context, listen: false).clearSearch();
  }

  void _performSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        Provider.of<ChatProvider>(context, listen: false).searchUsers(query);
      } else {
        Provider.of<ChatProvider>(context, listen: false).clearSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for new chat',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: _performSearch,
              )
            : Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _stopSearch();
                } else {
                  _startSearch();
                }
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          if (!_isSearching && chatProvider.existingChats.isNotEmpty) ...[
            ...chatProvider.existingChats.map((user) => _buildUserListTile(user, chatProvider)),
          ],
          if (_isSearching) ...[
            if (chatProvider.searchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No users found'),
              )
            else
              ...chatProvider.searchResults.map((user) => _buildUserListTile(user, chatProvider)),
          ],
        ],
      ),
    );
  }

  Widget _buildUserListTile(Map<String, dynamic> user, ChatProvider chatProvider) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user['avatar_url'] != null && user['avatar_url'].isNotEmpty
          ? NetworkImage(user['avatar_url'])
          : null,
        child: user['avatar_url'] == null || user['avatar_url'].isEmpty
          ? Text(user['full_name']?.isNotEmpty == true 
              ? user['full_name']![0] 
              : (user['username']?.isNotEmpty == true ? user['username'][0] : ''))
          : null,
      ),
      title: Text(user['full_name'] ?? user['username'] ?? 'Unknown User'),
      subtitle: Text(user['user_type'] ?? ''),
      onTap: () {
        chatProvider.selectUser(
          user['id']?.toString() ?? '',
          user['full_name'] ?? user['username'] ?? 'Unknown User',
          user['avatar_url'] ?? '',
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      },
    );
  }
}