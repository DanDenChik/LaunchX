import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'goals_screen.dart';
import 'teacher_classes_screen.dart';

class GoalsLandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.userType == 'student') {
      return GoalsScreen();
    } else if (authProvider.userType == 'teacher') {
      return TeacherClassesScreen();
    } else {
      return Scaffold(
        body: Center(
          child: Text('Unauthorized'),
        ),
      );
    }
  }
}