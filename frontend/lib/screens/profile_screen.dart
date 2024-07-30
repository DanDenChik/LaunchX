import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/goal_provider.dart';
import 'class_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchProfile();
      Provider.of<GoalProvider>(context, listen: false).fetchStudentGoals();
    });
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    await Provider.of<AuthProvider>(context, listen: false).fetchProfile();
    await Provider.of<GoalProvider>(context, listen: false).fetchStudentGoals();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File imageFile = File(image.path);
        setState(() {
          _isLoading = true;
        });
        await Provider.of<AuthProvider>(context, listen: false)
            .updateAvatar(imageFile);
        await _loadProfile();
      }
    } catch (e) {
      print('Error updating avatar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update avatar: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);

    if (_isLoading || authProvider.profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    capitalize(authProvider.userType!),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _updateAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: authProvider.profile!['user']
                                      ['avatar_url'] !=
                                  null
                              ? NetworkImage(
                                  authProvider.profile!['user']['avatar_url'])
                              : AssetImage('assets/profile_placeholder.png')
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child:
                                Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    authProvider.profile!['user']['full_name'] ?? 'No Name',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    authProvider.profile!['user']['email'] ?? 'No Email',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (authProvider.userType == 'student')
              _buildStudentProfile(authProvider, goalProvider)
            else if (authProvider.userType == 'teacher')
              _buildTeacherProfile(context, authProvider)
          ],
        ),
      ),
    );
  }

  Widget _buildStudentProfile(
    AuthProvider authProvider, GoalProvider goalProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard('Streak', '${authProvider.profile!['streak']} days'),
        SizedBox(height: 10),
        _buildInfoCard(
            'Completed Goals', '${authProvider.profile!['completed_goals']}'),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTeacherProfile(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          child: Text('My Classes'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClassListScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
