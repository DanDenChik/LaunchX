import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/class_provider.dart';
import 'goals_screen.dart';

class TeacherClassesScreen extends StatefulWidget {
  @override
  _TeacherClassesScreenState createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ClassProvider>(context, listen: false).fetchTeacherClasses()
    );
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Classes'),
      ),
      body: classProvider.classes.isEmpty
          ? Center(child: Text('No classes found'))
          : ListView.builder(
            itemCount: classProvider.classes.length,
            itemBuilder: (context, index) {
              final classItem = classProvider.classes[index];
              return ListTile(
                title: Text(classItem['name']),
                subtitle: Text('Students: ${classItem['students'].length}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalsScreen(classId: classItem['id'].toString()),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}