import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ClassListScreen extends StatefulWidget {
  @override
  _ClassListScreenState createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final classes = await _apiService.getTeacherClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching classes: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Classes'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? Center(child: Text('No classes found'))
              : ListView.builder(
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final classItem = _classes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(classItem['name']),
                        subtitle: Text('Students: ${classItem['students'].length}'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ClassDetailScreen(classId: classItem['id']),
                          //   ),
                          // );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}